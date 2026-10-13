import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/collection_select_bar.dart';
import 'package:qr_code_app/components/collection_sync_bar.dart';
import 'package:qr_code_app/components/empty_state.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_card.dart';
import 'package:qr_code_app/components/qr_card_list.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/pages/pdf_export_page.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/import_contact.dart';

/// Main "collection" page. Lists every saved QR/VCard with reactive Drift
/// stream. Provides debounced name search and optional event filter (4-5/4-6).
class Collection extends StatefulWidget {
  /// Creates the collection page.
  const new({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _selectedEventId;
  List<Event> _events = [];
  Timer? _debounce;
  bool _selectMode = false;
  final Set<String> _selected = <String>{};
  final Map<String, Map<String, dynamic>> _selectedItems = {};
  List<Map<String, dynamic>> _listedItems = const [];

  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = QRDatabase().watchAllItems();
    unawaited(_loadEvents());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final db = QRDatabase();
    final rows = await db.select(db.events).get();
    if (mounted) setState(() => _events = rows);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
        _selectedEventId = null;
        _stream = QRDatabase().watchAllItems(search: query);
      });
    });
  }

  void _onEventSelected(int? eventId) {
    _searchCtrl.clear();
    setState(() {
      _selectedEventId = eventId;
      _searchQuery = '';
      _stream = QRDatabase().watchAllItems(eventId: eventId);
    });
  }

  Future<void> _importAll() async {
    await importAllDeviceContacts(context);
  }

  Future<void> _exportAll() async {
    await exportAllVCards(context);
  }

  void _exitSelect() {
    setState(() {
      _selectMode = false;
      _selected.clear();
      _selectedItems.clear();
    });
  }

  String? _itemKey(Map<String, dynamic> item) {
    final data = item['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final id = data['id'];
    if (id is! int) {
      return null;
    }
    return collectionItemKey(
      isVCard: item['type'] == 'vcard',
      id: id,
    );
  }

  void _onHoldSelect(Map<String, dynamic> item) {
    final key = _itemKey(item);
    if (key == null) {
      return;
    }
    setState(() {
      _selectMode = true;
      _selected.add(key);
      _selectedItems[key] = item;
    });
  }

  void _onToggleSelect(Map<String, dynamic> item) {
    final key = _itemKey(item);
    if (key == null) {
      return;
    }
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
        _selectedItems.remove(key);
      } else {
        _selected.add(key);
        _selectedItems[key] = item;
      }
    });
  }

  void _selectAllListed() {
    setState(() {
      for (final item in _listedItems) {
        final key = _itemKey(item);
        if (key != null) {
          _selected.add(key);
          _selectedItems[key] = item;
        }
      }
    });
  }

  Future<void> _exportSelected() async {
    final vcards = <Map<String, dynamic>>[];
    final simples = <Map<String, dynamic>>[];
    for (final item in _selectedItems.values) {
      final data = item['data'];
      if (data is! Map<String, dynamic>) {
        continue;
      }
      if (item['type'] == 'simple') {
        simples.add(data);
      } else {
        vcards.add(data);
      }
    }
    if (!mounted) {
      return;
    }
    await saveCollectionZip(
      context,
      vcards: vcards,
      simples: simples,
    );
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) {
      return;
    }
    final lang = LangProvider.section('pages.collection');
    final confirm = ((lang['select_delete_confirm'] as String?) ??
            'Supprimer %s QR ?')
        .replaceFirst('%s', '${_selected.length}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: currentColors['bg'],
          content: Text(
            confirm,
            style: TextStyle(color: currentColors['text']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                LangProvider.getString('close'),
                style: TextStyle(color: currentColors['text-muted']),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                (lang['select_delete'] as String?) ?? 'Supprimer',
                style: TextStyle(color: currentColors['danger']),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) {
      return;
    }
    var deleted = 0;
    for (final item in _selectedItems.values) {
      final data = item['data'];
      if (data is! Map<String, dynamic>) {
        continue;
      }
      final id = data['id'];
      if (id is! int) {
        continue;
      }
      await deleteQR(isVCard: item['type'] == 'vcard', id: id);
      deleted += 1;
    }
    if (!mounted) {
      return;
    }
    _exitSelect();
    final done = ((lang['select_deleted'] as String?) ?? '%s QR supprimés')
        .replaceFirst('%s', '$deleted');
    showToast(context: context, title: done, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.collection');

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        Widget? suffixIcon;
        if (_searchQuery.isNotEmpty) {
          suffixIcon = IconButton(
            icon: Icon(
              Icons.clear,
              color: currentColors['text-muted'],
            ),
            onPressed: () {
              _searchCtrl.clear();
              _onSearchChanged('');
            },
          );
        }
        Widget? fab;
        if (!_selectMode) {
          fab = FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const PdfExportPage()),
            ),
            tooltip: 'Export PDF',
            child: const Icon(Icons.picture_as_pdf_outlined),
          );
        }
        return PopScope(
          canPop: !_selectMode,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            if (_selectMode) {
              _exitSelect();
            }
          },
          child: Scaffold(
          backgroundColor: currentColors['bg'],
          appBar: AppBarCustom(lang['title'] as String),
          floatingActionButton: fab,
          body: Column(
            children: [
              const ActiveEventBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: currentColors['text']),
                  decoration: InputDecoration(
                    hintText: lang['search_hint'] as String,
                    hintStyle: TextStyle(color: currentColors['text-muted']),
                    prefixIcon: Icon(
                      Icons.search,
                      color: currentColors['text-muted'],
                    ),
                    suffixIcon: suffixIcon,
                    filled: true,
                    fillColor: currentColors['surface'],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              if (!_selectMode)
                CollectionSyncBar(
                  onImport: () {
                    unawaited(_importAll());
                  },
                  onExport: () {
                    unawaited(_exportAll());
                  },
                ),
              if (_events.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      _EventChip(
                        label: lang['filter_all_events'] as String,
                        selected: _selectedEventId == null,
                        onSelected: () => _onEventSelected(null),
                      ),
                      ..._events.map(
                        (e) => _EventChip(
                          label: e.name,
                          selected: _selectedEventId == e.id,
                          onSelected: () => _onEventSelected(e.id),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? [];
                    _listedItems = items;
                    if (items.isEmpty) {
                      if (_selectMode) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          if (_selectMode) {
                            _exitSelect();
                          }
                        });
                      }
                      final home = LangProvider.getMap('home');
                      return EmptyState(
                        icon: Icons.style_outlined,
                        title: LangProvider.getString('empty'),
                        body: home['empty_collection'] as String?,
                        actionLabel: LangProvider.getMap(
                          'menu',
                        )['scanner'] as String?,
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const QRScannerPage(),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: QRCardListView(
                            allItems: items,
                            refreshData: () async {},
                            selectMode: _selectMode,
                            selectedKeys: _selected,
                            onHoldSelect: _onHoldSelect,
                            onToggleSelect: _onToggleSelect,
                          ),
                        ),
                        if (_selectMode)
                          CollectionSelectBar(
                            count: _selected.length,
                            onCancel: _exitSelect,
                            onSelectAll: _selectAllListed,
                            onDelete: () {
                              unawaited(_deleteSelected());
                            },
                            onExport: () {
                              unawaited(_exportSelected());
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const Navbar(currentRoute: '/collection'),
        ),
        );
      },
    );
  }
}

class _EventChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    var labelColor = currentColors['text'];
    if (selected) {
      labelColor = currentColors['on-button'];
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        backgroundColor: currentColors['surface-raised'],
        selectedColor: currentColors['button-color'],
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: currentColors['on-button'],
        side: BorderSide(color: currentColors['border']!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rXs),
        ),
      ),
    );
  }
}
