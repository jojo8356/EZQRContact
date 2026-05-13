import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_card.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/perf.dart';

/// Page listing the soft-deleted QR / VCard rows ("trash" view).
class HistoryPage extends StatefulWidget {
  /// Creates the page.
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> deletedItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDeletedItems());
  }

  Future<void> _loadDeletedItems() async {
    Perf.start('page.history.load');
    setState(() => loading = true);

    final merged = await getAllDeletedQRs();

    setState(() {
      deletedItems = merged;
      loading = false;
    });
    Perf.end('page.history.load');
    Perf.mark('page.history.ready (${merged.length} items)');
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.history');
    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: AppBarCustom(lang['title'] as String),
      body: Column(
        children: [
          const ActiveEventBanner(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : deletedItems.isEmpty
                ? Center(child: Text(LangProvider.getString('empty')))
                : ListView.builder(
                    itemCount: deletedItems.length,
                    itemBuilder: (context, index) {
                      final item = deletedItems[index];
                      final data = item['data'] as Map<String, dynamic>;
                      final isVCard = item['type'] == 'vcard';

                      return QRCard(
                        data: data,
                        isVCard: isVCard,
                        onRefresh: () async {},
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const Navbar(currentRoute: '/history'),
    );
  }
}
