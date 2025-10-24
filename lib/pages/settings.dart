import 'package:flutter/material.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/modals/social_networks.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final darkMode = DarkModeProvider();
  String _selectedLang = LangProvider.currentLanguage();
  List<String> _langs = [];
  Map<String, dynamic> get lang => LangProvider.get('options');

  late final VoidCallback _langListener;

  @override
  void initState() {
    super.initState();
    _loadLangs();

    // 🔹 définir le listener
    _langListener = () {
      if (!mounted) return; // ne pas setState si le widget est disposé
      setState(() {
        _selectedLang = LangProvider.currentLanguage();
      });
    };

    // 🔹 ajouter le listener
    LangProvider.notifier.addListener(_langListener);
  }

  @override
  void dispose() {
    // 🔹 retirer le listener pour éviter fuite mémoire
    LangProvider.notifier.removeListener(_langListener);
    super.dispose();
  }

  // charger les langues disponibles
  Future<void> _loadLangs() async {
    final langs = await LangProvider.getAll();
    setState(() {
      _langs = langs;
      if (!_langs.contains(_selectedLang)) {
        _selectedLang = _langs.first;
      }
    });
  }

  // boutons de la page
  List<Map<String, dynamic>> get buttons => [
    {
      "label": lang['guide'],
      "icon": Icons.book,
      "action": (BuildContext context) async =>
          await showGuidePopup(context, fromButton: true),
    },
    {
      "label": lang['about'],
      "icon": Icons.person,
      "action": (BuildContext context) async => await showSharePopup(context),
    },
    {
      "label": lang['mode'],
      "icon": Icons.brightness_6,
      "action": (BuildContext context) {
        darkMode.toggle();
        setState(() {}); // refresh UI
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: _langs.isEmpty
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // selector de langue avec ValueListenableBuilder
                    ValueListenableBuilder<String>(
                      valueListenable: LangProvider.notifier,
                      builder: (context, value, child) {
                        return DropdownButton<String>(
                          value: _selectedLang,
                          items: _langs
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: (newValue) async {
                            if (newValue != null) {
                              await LangProvider.changeLanguage(newValue);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // boutons
                    ...buttons.map((btn) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkMode.isDarkMode
                                ? Colors.purple
                                : Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          icon: Icon(
                            btn["icon"] as IconData?,
                            color: Colors.white,
                          ),
                          label: Text(
                            btn["label"] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () => (btn["action"] as Function)(context),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const Navbar(currentRoute: '/settings'),
    );
  }
}
