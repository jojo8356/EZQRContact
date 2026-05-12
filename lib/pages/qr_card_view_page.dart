import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_card_list.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/perf.dart';

/// Main "collection" page listing every saved QR / VCard via [QRCardListView].
class Collection extends StatefulWidget {
  /// Creates the collection page.
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Map<String, dynamic>> allItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshData());
  }

  Future<void> _refreshData() async {
    Perf.start('page.collection.refresh');
    setState(() => loading = true);

    final results = await Future.wait([
      QRDatabase().getAllSimpleQR(),
      QRDatabase().getAllVCards(),
    ]);
    final simpleQRs = results[0];
    final vcards = results[1];

    final merged = [
      ...simpleQRs.map((e) => {'type': 'simple', 'data': e}),
      ...vcards.map((e) => {'type': 'vcard', 'data': e}),
    ];

    setState(() {
      allItems = merged;
      loading = false;
    });
    Perf.end('page.collection.refresh');
    Perf.mark('page.collection.ready (${merged.length} items)');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: currentColors['bg'],
          appBar: const AppBarCustom('QR List'),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : allItems.isEmpty
              ? Center(
                  child: Text(
                    LangProvider.getString('empty'),
                    style: TextStyle(
                      color: currentColors['text'],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : QRCardListView(allItems: allItems, refreshData: _refreshData),
          bottomNavigationBar: const Navbar(currentRoute: '/collection'),
        );
      },
    );
  }
}
