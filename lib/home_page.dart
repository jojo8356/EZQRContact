import 'package:flutter/material.dart';
import 'package:qr_code_app/components/menu.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/modals/networks.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_card_list.dart';
import 'tools/db/db.dart';

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
      showGuidePopup(context);
    });
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
    final darkMode = DarkModeProvider();
    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(
              LangProvider.get('title'),
              style: TextStyle(
                color: darkMode.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  MenuActions(
                    refreshData: _refreshData,
                    isDarkMode: darkMode.isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Stack(
                      children: [
                        // contenu principal
                        loading
                            ? const Center(child: CircularProgressIndicator())
                            : allItems.isEmpty
                            ? Center(
                                child: Text(
                                  LangProvider.get('QR Not Found'),
                                  style: TextStyle(
                                    color: darkMode.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : QRCardListView(
                                allItems: allItems,
                                refreshData: _refreshData,
                              ),

                        // bouton gauche (Aide)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              bottom: 20,
                            ),
                            child: IconButton(
                              onPressed: () {
                                showGuidePopup(context, fromButton: true);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  darkMode.isDarkMode
                                      ? Colors.purpleAccent
                                      : Colors.pinkAccent,
                                ),
                                foregroundColor: WidgetStatePropertyAll(
                                  Colors.white,
                                ),
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.all(12),
                                ),
                                animationDuration: Duration.zero,
                              ),
                              icon: const Icon(Icons.help_outline),
                            ),
                          ),
                        ),

                        // bouton droit (Contact)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 20,
                              bottom: 20,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showSharePopup(context);
                                },
                                icon: Icon(
                                  Icons.contact_mail,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: darkMode.isDarkMode
                                    ? Colors.amber
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  darkMode.toggle();
                                },
                                icon: Icon(
                                  darkMode.isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
