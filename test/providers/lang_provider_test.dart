import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void setLocale(String code) {
    binding.platformDispatcher.localeTestValue = Locale(code);
  }

  void clearLocale() {
    binding.platformDispatcher.clearLocaleTestValue();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(clearLocale);

  group('LangProvider — getter fallbacks', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await LangProvider.init(lang: 'en');
    });

    test('t() returns literal path on missing leaf', () {
      expect(
        LangProvider.t('this.path.does.not.exist'),
        equals('this.path.does.not.exist'),
      );
    });

    test('t() returns dotted path even when prefix exists', () {
      // 'options' exists but 'options.zzzz' does not — must return literal.
      expect(LangProvider.t('options.zzzz'), equals('options.zzzz'));
    });

    test('getMap() returns empty map on missing key', () {
      expect(LangProvider.getMap('definitelyMissingKey'), isEmpty);
    });

    test('getString() returns key on missing entry', () {
      expect(
        LangProvider.getString('definitely.missing'),
        equals('definitely.missing'),
      );
    });

    test('section() returns empty map on missing path', () {
      expect(LangProvider.section('not.a.real.path'), isEmpty);
    });
  });

  group('LangProvider — init + persistence', () {
    test('init() without pref uses device locale FR', () async {
      setLocale('fr');
      await LangProvider.init();
      expect(LangProvider.currentLanguage(), equals('fr'));
    });

    test('init() reads lang_override pref before device locale', () async {
      setLocale('en');
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lang_override': 'fr',
      });
      await LangProvider.init();
      expect(LangProvider.currentLanguage(), equals('fr'));
    });

    test('init(lang: ...) explicit param wins over pref', () async {
      setLocale('fr');
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lang_override': 'fr',
      });
      await LangProvider.init(lang: 'en');
      expect(LangProvider.currentLanguage(), equals('en'));
    });

    test('changeLanguage persists to SharedPreferences', () async {
      await LangProvider.init(lang: 'en');
      await LangProvider.changeLanguage('fr');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lang_override'), equals('fr'));
      expect(LangProvider.currentLanguage(), equals('fr'));
    });

    test('resetToDeviceLocale clears pref + rebascule device locale', () async {
      setLocale('en');
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lang_override': 'fr',
      });
      await LangProvider.init();
      expect(LangProvider.currentLanguage(), equals('fr'));
      await LangProvider.resetToDeviceLocale();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lang_override'), isNull);
      expect(LangProvider.currentLanguage(), equals('en'));
    });

    test('init() with unknown locale falls back to en (AC-9)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lang_override': 'zz',
      });
      await LangProvider.init();
      expect(LangProvider.currentLanguage(), equals('en'));
    });

    test('notifier fires after changeLanguage', () async {
      await LangProvider.init(lang: 'en');
      String? captured;
      void listener() {
        captured = LangProvider.notifier.value;
      }

      LangProvider.notifier.addListener(listener);
      addTearDown(() => LangProvider.notifier.removeListener(listener));
      await LangProvider.changeLanguage('fr');
      expect(captured, equals('fr'));
    });
  });
}
