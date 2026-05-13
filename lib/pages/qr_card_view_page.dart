import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_card_list.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/pages/pdf_export_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Main "collection" page. Lists every saved QR/VCard with reactive Drift
/// stream. Provides debounced name search and optional event filter (4-5/4-6).
class Collection extends StatefulWidget {
  /// Creates the collection page.
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _selectedEventId;
  List<Event> _events = [];
  Timer? _debounce;

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

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.collection');

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: currentColors['bg'],
          appBar: AppBarCustom(lang['title'] as String),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const PdfExportPage()),
            ),
            backgroundColor: currentColors['button-color'],
            foregroundColor: Colors.white,
            tooltip: 'Export PDF',
            child: const Icon(Icons.picture_as_pdf),
          ),
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
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: currentColors['text-muted'],
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
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
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          LangProvider.getString('empty'),
                          style: TextStyle(
                            color: currentColors['text'],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return QRCardListView(
                      allItems: items,
                      refreshData: () async {},
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const Navbar(currentRoute: '/collection'),
        );
      },
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        backgroundColor: currentColors['surface'],
        selectedColor: currentColors['button-color'],
        labelStyle: TextStyle(
          color: selected ? Colors.white : currentColors['text'],
          fontSize: 12,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }
}
