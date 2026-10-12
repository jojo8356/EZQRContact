import 'dart:async';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/app_switch.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/components/section_label.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/modals/social_networks.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/theme/tokens.dart';
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
        final c = currentColors;
        final theme = Theme.of(context);

        Widget settingsBody = ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppTokens.s5,
                          AppTokens.s5,
                          AppTokens.s5,
                          AppTokens.s10,
                        ),
                        children: [
                          SectionLabel(
                            (lang['appearance'] as String?) ?? 'Apparence',
                          ),
                          PaperCard(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTokens.s2,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.language_rounded,
                                    color: c['navy'],
                                  ),
                                  title: Text(
                                    _selectedLang.toUpperCase(),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  trailing: ValueListenableBuilder<String>(
                                    valueListenable: LangProvider.notifier,
                                    builder: (context, value, child) {
                                      return DropdownButton<String>(
                                        value: _selectedLang,
                                        isDense: true,
                                        underline: const SizedBox.shrink(),
                                        dropdownColor: c['surface'],
                                        style: TextStyle(
                                          color: c['text'],
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: _langs.map(_langItem).toList(),
                                        onChanged: (newValue) async {
                                          if (newValue != null) {
                                            await LangProvider.changeLanguage(
                                              newValue,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.dark_mode_outlined,
                                    color: c['navy'],
                                  ),
                                  title: Text(
                                    (lang['mode'] as String?) ??
                                        'Mode sombre',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  trailing: AppSwitch(
                                    key: const Key('dark-mode-switch'),
                                    value: darkProv.isDarkMode,
                                    onChanged: (v) => darkProv.setDarkMode(v),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.menu_book_outlined,
                                    color: c['navy'],
                                  ),
                                  title: Text(
                                    lang['guide'] as String,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: c['text-muted'],
                                  ),
                                  onTap: () => unawaited(
                                    showGuidePopup(context, fromButton: true),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.alternate_email_rounded,
                                    color: c['navy'],
                                  ),
                                  title: Text(
                                    lang['about'] as String,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: c['text-muted'],
                                  ),
                                  onTap: () => unawaited(
                                    showSharePopup(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTokens.s6),
                          SectionLabel(
                            (lang['vcard_section'] as String?) ?? 'VCard',
                          ),
                          PaperCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(
                                (lang['vcard4'] as String?) ??
                                    'Format vCard 4.0',
                                style: theme.textTheme.titleMedium,
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
                          ),
                          const SizedBox(height: AppTokens.s6),
                          SectionLabel(
                            (lang['exchange_section'] as String?) ??
                                'Échange',
                          ),
                          PaperCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(
                                (lang['reciprocal_label'] as String?) ??
                                    'Proposer ma carte en retour',
                                style: theme.textTheme.titleMedium,
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
                          ),
                        ],
        );
        if (_langs.isEmpty) {
          settingsBody = const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBarCustom((lang['mode'] as String?) ?? 'Options'),
          backgroundColor: c['bg'],
          body: Column(
            children: [
              const ActiveEventBanner(),
              Expanded(child: settingsBody),
            ],
          ),
          bottomNavigationBar: const Navbar(currentRoute: '/settings'),
        );
      },
    );
  }
}
