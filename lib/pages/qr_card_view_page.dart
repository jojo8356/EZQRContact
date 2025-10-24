import 'package:flutter/material.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/components/qr_card_list.dart';
import '../tools/db/db.dart';

class Collection extends StatefulWidget {
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
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => loading = true);

    final simpleQRs = await QRDatabase().getAllSimpleQR();
    final vcards = await QRDatabase().getAllVCards();

    final merged = [
      ...simpleQRs.map((e) => {'type': 'simple', 'data': e}),
      ...vcards.map((e) => {'type': 'vcard', 'data': e}),
    ];

    setState(() {
      allItems = merged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(
              "QR List",
              style: TextStyle(
                color: darkMode.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : allItems.isEmpty
              ? Center(
                  child: Text(
                    LangProvider.get('empty'),
                    style: TextStyle(
                      color: darkMode.isDarkMode ? Colors.white : Colors.black,
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
