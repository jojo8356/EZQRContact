// Live device test: opens Settings from the real app and exercises the
// on/off switches + language dropdown (manual-test.md §2, §9, §10).
//
// Restores the user's prefs at the end so a phone used for QA is not left
// in English / vCard 4 / dark mode.
//
//   flutter test integration_test/settings_e2e_test.dart
//   ./scripts/test_settings.sh
//   ./scripts/test_settings.sh <device-id>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/components/app_switch.dart';
import 'package:qr_code_app/main.dart' as app;
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _skipFirstRunGates() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  await prefs.setInt('guideShown', 1);
}

Future<void> _openSettings(WidgetTester tester) async {
  final outlined = find.byIcon(Icons.settings_outlined);
  if (outlined.evaluate().isNotEmpty) {
    await tester.tap(outlined);
    await tester.pumpAndSettle();
  }
  expect(find.byType(SettingsPage), findsOneWidget);
}

Future<void> _tapKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

bool _switchValue(WidgetTester tester, Key key) {
  return tester.widget<AppSwitch>(find.byKey(key)).value;
}

VCard _marie() {
  return VCard(
    nom: 'Dupont',
    prenom: 'Marie',
    telWork: '+33612345678',
    email: 'marie.dupont@acme.fr',
    rev: '20261013T000000Z',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'settings E2E — dark mode, vCard 4, reciprocal, language',
    (tester) async {
      await _skipFirstRunGates();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final origDark = darkProv.isDarkMode;
      final origV4 = VCardSettingsProvider.useVCard4;
      final origRecip = VCardSettingsProvider.reciprocalExchange;
      final origLang = LangProvider.currentLanguage();

      addTearDown(() async {
        darkProv.forceSetDarkMode(origDark);
        await VCardSettingsProvider.setUseVCard4(origV4);
        await VCardSettingsProvider.setReciprocalExchange(origRecip);
        if (LangProvider.currentLanguage() != origLang) {
          await LangProvider.changeLanguage(origLang);
        }
      });

      await _openSettings(tester);

      // --- §10.1 / 10.2 dark mode (in-session only, not persisted) ---
      const darkKey = Key('dark-mode-switch');
      if (_switchValue(tester, darkKey)) {
        await _tapKey(tester, darkKey);
        expect(darkProv.isDarkMode, isFalse);
      }
      await _tapKey(tester, darkKey);
      expect(darkProv.isDarkMode, isTrue);
      expect(_switchValue(tester, darkKey), isTrue);

      await tester.tap(find.byIcon(Icons.style_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(Collection), findsOneWidget);
      expect(
        darkProv.isDarkMode,
        isTrue,
        reason: '§10.2 dark mode stays on while navigating',
      );

      await _openSettings(tester);
      await _tapKey(tester, darkKey);
      expect(darkProv.isDarkMode, isFalse);

      // --- §2.1 / 2.3 vCard 4.0 toggle + payload ---
      const v4Key = Key('vcard4-switch');
      await tester.ensureVisible(find.byKey(v4Key));
      await tester.pumpAndSettle();
      if (_switchValue(tester, v4Key)) {
        await _tapKey(tester, v4Key);
      }
      expect(VCardSettingsProvider.useVCard4, isFalse);
      expect(_marie().toVCard(), contains('VERSION:3.0'));
      expect(
        _marie().toVCard(),
        contains('TEL;TYPE=WORK,VOICE:+33612345678'),
      );

      await _tapKey(tester, v4Key);
      expect(VCardSettingsProvider.useVCard4, isTrue);
      expect(_switchValue(tester, v4Key), isTrue);
      final v4 = _marie().toVCard();
      expect(v4, contains('VERSION:4.0'));
      expect(
        v4,
        contains('TEL;TYPE=work,voice;VALUE=uri:tel:+33612345678'),
      );
      expect(v4, contains('EMAIL:marie.dupont@acme.fr'));

      await _tapKey(tester, v4Key);
      expect(VCardSettingsProvider.useVCard4, isFalse);
      expect(_marie().toVCard(), contains('VERSION:3.0'));

      // --- reciprocal exchange switch ---
      const recipKey = Key('reciprocal-switch');
      await tester.ensureVisible(find.byKey(recipKey));
      await tester.pumpAndSettle();
      if (_switchValue(tester, recipKey)) {
        await _tapKey(tester, recipKey);
      }
      expect(VCardSettingsProvider.reciprocalExchange, isFalse);
      await _tapKey(tester, recipKey);
      expect(VCardSettingsProvider.reciprocalExchange, isTrue);
      expect(_switchValue(tester, recipKey), isTrue);
      await _tapKey(tester, recipKey);
      expect(VCardSettingsProvider.reciprocalExchange, isFalse);

      // --- §9.1 language FR ↔ EN, no restart ---
      var other = 'fr';
      if (origLang == 'fr') {
        other = 'en';
      }
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(other.toUpperCase()).last);
      await tester.pumpAndSettle();
      expect(LangProvider.currentLanguage(), other);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(origLang.toUpperCase()).last);
      await tester.pumpAndSettle();
      expect(LangProvider.currentLanguage(), origLang);
    },
  );
}
