import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VCardSettingsProvider.init();
  });

  group('VCardSettingsProvider — init', () {
    test('defaults useVCard4 to false when no pref stored', () {
      expect(VCardSettingsProvider.useVCard4, isFalse);
    });

    test('reads a pre-stored true value from SharedPrefs', () async {
      SharedPreferences.setMockInitialValues({'use_vcard4': true});
      await VCardSettingsProvider.init();
      expect(VCardSettingsProvider.useVCard4, isTrue);
    });
  });

  group('VCardSettingsProvider — setUseVCard4', () {
    test('setUseVCard4(true) sets getter to true immediately', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      expect(VCardSettingsProvider.useVCard4, isTrue);
    });

    test('setUseVCard4(true) persists to SharedPrefs key use_vcard4', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('use_vcard4'), isTrue);
    });

    test('setUseVCard4(false) resets getter to false and persists', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      await VCardSettingsProvider.setUseVCard4(false);
      expect(VCardSettingsProvider.useVCard4, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('use_vcard4'), isFalse);
    });

    test('fresh init() after setUseVCard4(true) reads back true', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      // Re-init without clearing prefs — persisted value must survive.
      await VCardSettingsProvider.init();
      expect(VCardSettingsProvider.useVCard4, isTrue);
    });
  });

  // Manuel 2.2 — Toggle ON > force-quit > relance > toggle reste ON
  group('VCardSettingsProvider — persistance après kill', () {
    test(
      'toggle ON survit à un force-quit et reste ON après relance',
      () async {
        // 1. Utilisateur active le toggle
        await VCardSettingsProvider.setUseVCard4(true);

        // 2. Capture les prefs persistées avant de simuler le kill
        final prefs = await SharedPreferences.getInstance();
        final snapshot = <String, Object>{
          'use_vcard4': prefs.getBool('use_vcard4')!,
        };

        // 3. Simule le kill : mémoire effacée → static reset
        SharedPreferences.setMockInitialValues({});
        await VCardSettingsProvider.init();
        expect(
          VCardSettingsProvider.useVCard4,
          isFalse,
          reason: 'contrôle : état mémoire effacé comme après kill',
        );

        // 4. Simule la relance avec prefs sauvegardées
        SharedPreferences.setMockInitialValues(snapshot);
        await VCardSettingsProvider.init();

        // 5. Le toggle doit être ON
        expect(
          VCardSettingsProvider.useVCard4,
          isTrue,
          reason: 'le format vCard 4.0 doit survivre au force-quit',
        );
      },
    );
  });
}
