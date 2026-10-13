import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/collection_select_bar.dart';
import 'package:qr_code_app/components/collection_sync_bar.dart';
import 'package:qr_code_app/components/empty_state.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_card.dart';
import 'package:qr_code_app/components/qr_card_list.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/import_contact.dart';

/// Main "collection" page. Lists every saved QR/VCard with reactive Drift
/// stream. Provides debounced name search.
class Collection extends StatefulWidget {
  /// Creates the collection page.
  const new({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
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
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
        _stream = QRDatabase().watchAllItems(search: query);
      });
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
          body: Column(
            children: [
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
