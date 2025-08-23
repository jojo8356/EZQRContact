import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/import_contact.dart';
import 'package:qr_code_app/components/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/db.dart';
import 'tools.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allItems = [];
  List<bool> expandedList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGuidePopup(); // 👈 affiche le guide après le build
    });
  }

  Widget closeButton(BuildContext context) => TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('Close'),
  );

  Future<void> showGuidePopup() async {
    final prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seenGuide') ?? false;

    if (kDebugMode) seen = false; // toujours montrer en debug

    if (!seen) {
      final data = await rootBundle.loadString('assets/GUIDEME.md');
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR Code Texte'),
          content: Markdown(data: data, shrinkWrap: true),
          actions: [closeButton(context)],
        ),
      );
    }
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
      expandedList = List.generate(allItems.length, (_) => false);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Easy QR Contact App")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          MenuActions(
            refreshData: _refreshData,
            importContacts: (ctx) async {
              await importContacts(this);
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : allItems.isEmpty
                ? const Center(child: Text("No QR code found"))
                : ListView.builder(
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      final titleText = getTitleAndPhoto(item);
                      final data = item['data'] as Map<String, dynamic>;
                      final isVCard = item['type'] == 'vcard';
                      String photo = data['photo'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 3,
                        child: Column(
                          children: [
                            ListTile(
                              leading: buildItemAvatar(isVCard, photo),
                              title: Text(
                                titleText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  expandedList[index] = !expandedList[index];
                                });
                              },
                            ),
                            OptionsQR(
                              isVCard: isVCard,
                              data: data,
                              expanded: expandedList[index],
                              onRefresh: _refreshData,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
