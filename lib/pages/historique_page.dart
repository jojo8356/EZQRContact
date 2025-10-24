import 'package:flutter/material.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/components/qr_card.dart';
import '../tools/db/db.dart';

class HistoryPage extends StatefulWidget {
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
    _loadDeletedItems();
  }

  Future<void> _loadDeletedItems() async {
    setState(() => loading = true);

    final merged = await getAllDeletedQRs();

    setState(() {
      deletedItems = merged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeProvider();
    final lang = LangProvider.get('pages')['history'];
    return Scaffold(
      backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          lang['title'],
          style: TextStyle(
            color: darkMode.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : deletedItems.isEmpty
          ? Center(child: Text(LangProvider.get('empty')))
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
      bottomNavigationBar: const Navbar(currentRoute: '/history'),
    );
  }
}
