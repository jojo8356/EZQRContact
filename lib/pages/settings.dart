import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/modals/social_networks.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLang = LangProvider.currentLanguage();
  List<String> _langs = [];

  late final VoidCallback _langListener;

  @override
  void initState() {
    super.initState();
    _loadLangs();

    // 🔹 écoute les changements de langue
    _langListener = () {
      if (!mounted) return;
      setState(() {
        _selectedLang = LangProvider.currentLanguage();
      });
    };
    LangProvider.notifier.addListener(_langListener);
  }

  @override
  void dispose() {
    LangProvider.notifier.removeListener(_langListener);
    super.dispose();
  }

  Future<void> _loadLangs() async {
    final langs = await LangProvider.getAll();
    setState(() {
      _langs = langs;
      if (!_langs.contains(_selectedLang)) {
        _selectedLang = _langs.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final lang = LangProvider.get('options');

        final buttons = [
          {
            "label": lang['guide'],
            "icon": Icons.book,
            "action": (BuildContext context) async =>
                await showGuidePopup(context, fromButton: true),
          },
          {
            "label": lang['about'],
            "icon": Icons.person,
            "action": (BuildContext context) async =>
                await showSharePopup(context),
          },
          {
            "label": lang['mode'],
            "icon": Icons.brightness_6,
            "action": (BuildContext context) {
              darkProv.toggle(); // plus besoin de setState
            },
          },
        ];

        return Scaffold(
          appBar: AppBarCustom(lang['mode'] ?? 'Options'),
          backgroundColor: currentColors['bg'],
          body: Center(
            child: _langs.isEmpty
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 dropdown langue
                        ValueListenableBuilder<String>(
                          valueListenable: LangProvider.notifier,
                          builder: (context, value, child) {
                            return DropdownButton<String>(
                              value: _selectedLang,
                              dropdownColor:
                                  currentColors['bg'], // fond du menu
                              style: TextStyle(
                                color: currentColors['text'], // texte visible
                                fontWeight: FontWeight.bold, // 🔹 texte en gras
                              ),
                              items: _langs
                                  .map(
                                    (lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(
                                        lang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ), // 🔹 option aussi en gras
                                      ),
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

                        // 🔹 boutons
                        ...buttons.map((btn) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentColors['button-color'],
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
                              onPressed: () =>
                                  (btn["action"] as Function)(context),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: const Navbar(currentRoute: '/settings'),
        );
      },
    );
  }
}
