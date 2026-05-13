import 'dart:async';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/app_switch.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/modals/social_networks.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/perf.dart';


/// Settings page exposing language selection, dark-mode toggle, and links
/// to the help guide and the developer's social networks.
class SettingsPage extends StatefulWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLang = LangProvider.currentLanguage();
  List<String> _langs = [];
  bool _useVCard4 = VCardSettingsProvider.useVCard4;
  bool _reciprocalExchange = VCardSettingsProvider.reciprocalExchange;

  late final VoidCallback _langListener;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLangs());

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

  DropdownMenuItem<String> _langItem(String lang) => DropdownMenuItem(
        value: lang,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountryFlag.fromLanguageCode(
              lang,
              theme: const ImageTheme(
                width: 28,
                height: 20,
                shape: RoundedRectangle(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              lang.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Future<void> _loadLangs() async {
    Perf.start('page.settings.loadLangs');
    final langs = await LangProvider.getAll();
    setState(() {
      _langs = langs;
      if (!_langs.contains(_selectedLang)) {
        _selectedLang = _langs.first;
      }
    });
    Perf.end('page.settings.loadLangs');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final lang = LangProvider.getMap('options');

        final buttons = [
          {
            'label': lang['guide'],
            'icon': Icons.book,
            'action': (BuildContext context) async =>
                showGuidePopup(context, fromButton: true),
          },
          {
            'label': lang['about'],
            'icon': Icons.person,
            'action': (BuildContext context) async =>
                showSharePopup(context),
          },
          {
            'label': lang['mode'],
            'icon': Icons.brightness_6,
            'action': (BuildContext context) {
              darkProv.toggle(); // plus besoin de setState
            },
          },
        ];

        return Scaffold(
          appBar: AppBarCustom((lang['mode'] as String?) ?? 'Options'),
          backgroundColor: currentColors['bg'],
          body: Center(
            child: _langs.isEmpty
                ? const CircularProgressIndicator()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 80,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // section header "Apparence" / "Appearance"
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (lang['appearance'] as String?)
                                          ?? 'Apparence',
                                      style: TextStyle(
                                        color: currentColors['text'],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                // dropdown langue
                                ValueListenableBuilder<String>(
                                  valueListenable: LangProvider.notifier,
                                  builder: (context, value, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ), // 🔹 margin-bottom: 20px
                                      child: Align(
                                        child: IntrinsicWidth(
                                          child: DropdownButton<String>(
                                            value: _selectedLang,
                                            // réduit la hauteur et padding
                                            isDense: true,
                                            // supprime la ligne
                                            underline: Container(),
                                            dropdownColor: currentColors['bg'],
                                            style: TextStyle(
                                              color: currentColors['text'],
                                              fontWeight: FontWeight.bold,
                                            ),
                                            items: _langs
                                                .map(_langItem)
                                                .toList(),
                                            onChanged: (newValue) async {
                                              if (newValue != null) {
                                                await LangProvider
                                                    .changeLanguage(newValue);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // boutons
                                ...buttons.map((btn) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentColors['button-color'],
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                      ),
                                      icon: Icon(
                                        btn['icon'] as IconData?,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        btn['label'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onPressed: () =>
                                          (btn['action'] as Function)(context),
                                    ),
                                  );
                                }),
                                // section header "VCard"
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 24,
                                    bottom: 4,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (lang['vcard_section'] as String?)
                                          ?? 'VCard',
                                      style: TextStyle(
                                        color: currentColors['text'],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                // toggle vCard 4.0
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    (lang['vcard4'] as String?)
                                        ?? 'Format vCard 4.0',
                                    style: TextStyle(
                                      color: currentColors['text'],
                                    ),
                                  ),
                                  trailing: AppSwitch(
                                    value: _useVCard4,
                                    onChanged: (value) async {
                                      await VCardSettingsProvider.setUseVCard4(
                                        value,
                                      );
                                      setState(() => _useVCard4 = value);
                                    },
                                  ),
                                ),
                                // section header "Échange"
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 24,
                                    bottom: 4,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (lang['exchange_section'] as String?)
                                          ?? 'Échange',
                                      style: TextStyle(
                                        color: currentColors['text'],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    (lang['reciprocal_label'] as String?)
                                        ?? 'Proposer ma carte en retour',
                                    style: TextStyle(
                                      color: currentColors['text'],
                                    ),
                                  ),
                                  trailing: AppSwitch(
                                    value: _reciprocalExchange,
                                    onChanged: (value) async {
                                      await VCardSettingsProvider
                                          .setReciprocalExchange(value);
                                      setState(
                                        () => _reciprocalExchange = value,
                                      );
                                    },
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          bottomNavigationBar: const Navbar(currentRoute: '/settings'),
        );
      },
    );
  }
}
