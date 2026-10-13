import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_switch.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/components/section_label.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

// Flutter 3.41.6+ uses AssetManifest.bin (StandardMessageCodec binary format)
// exclusively on non-web platforms. The binary format encodes a map from asset
// path → list of variant descriptors. For our lang assets, no variants exist.
ByteData _buildFakeManifestBin() {
  const codec = StandardMessageCodec();
  return codec.encodeMessage(<String, Object?>{
    'assets/langs/en.json': <Object?>[],
    'assets/langs/fr.json': <Object?>[],
  })!;
}

/// Wraps [SettingsPage] with ENCRE theme and navbar routes.
Widget _buildApp() {
  return encreApp(home: const SettingsPage());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
    await VCardSettingsProvider.init();
  });

  setUp(() {
    darkProv.forceSetDarkMode(false);
    // Intercept the flutter/assets channel so [LangProvider.getAll] can
    // populate the language list. Flutter 3.41.6+ loads AssetManifest.bin
    // (binary codec) on non-web platforms — the old AssetManifest.json
    // key is no longer used.
    final fakeManifestBin = _buildFakeManifestBin();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List());
      if (key == 'AssetManifest.bin') return fakeManifestBin;
      return null;
    });
  });

  tearDown(() {
    darkProv.forceSetDarkMode(false);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  /// Pumps [_buildApp()] inside `runAsync` so [_SettingsPageState._loadLangs]
  /// runs in the real async zone and can complete before `pump()` redraws.
  Future<void> pumpSettingsPage(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_buildApp());
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
  }

  group('SettingsPage — rendering', () {
    testWidgets('page renders without throwing', (tester) async {
      await pumpSettingsPage(tester);
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('AppBar is present', (tester) async {
      await pumpSettingsPage(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('DropdownButton for language selection is present',
        (tester) async {
      await pumpSettingsPage(tester);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('tapping dark-mode switch flips isDarkMode to true',
        (tester) async {
      await pumpSettingsPage(tester);

      final toggle = find.byKey(const Key('dark-mode-switch'));
      expect(toggle, findsOneWidget);

      await tester.tap(toggle);
      // pumpAndSettle pumps 100 ms frames until no pending callbacks.
      // The Ticker records _startTime on its first tick (elapsed = 0) then
      // needs ~300 ms more, so ~4 frames of 100 ms each before it stops.
      await tester.pumpAndSettle();
      expect(darkProv.isDarkMode, isTrue);
    });

    testWidgets('uses AppSwitch and PaperCard, not Material Switch pills',
        (tester) async {
      await pumpSettingsPage(tester);

      expect(find.byType(AppSwitch), findsWidgets);
      expect(find.byType(PaperCard), findsWidgets);
      expect(find.byType(SectionLabel), findsWidgets);
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);
    });
  });

  // docs/manual-test.md §2.2 — Toggle ON > force-quit > relance > génère un QR
  group('manual 2.2 — vCard 4.0 persists after kill', () {
    tearDown(() async {
      await VCardSettingsProvider.setUseVCard4(false);
    });

    testWidgets(
      'toggle ON, relaunch, generated QR stays VERSION:4.0',
      (tester) async {
        await pumpSettingsPage(tester);

        final toggle = find.byKey(const Key('vcard4-switch'));
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();

        expect(VCardSettingsProvider.useVCard4, isTrue);

        // Force-quit: drop the widget tree and wipe statics (RAM). Disk
        // (SharedPreferences mock) stays. main() then calls init().
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        VCardSettingsProvider.debugResetMemory();
        expect(
          VCardSettingsProvider.useVCard4,
          isFalse,
          reason: 'RAM gone after kill',
        );
        await VCardSettingsProvider.init();

        await pumpSettingsPage(tester);
        await tester.ensureVisible(find.byKey(const Key('vcard4-switch')));
        final sw = tester.widget<AppSwitch>(
          find.byKey(const Key('vcard4-switch')),
        );
        expect(sw.value, isTrue, reason: 'toggle reste ON après relance');

        // Same payload GenerateVCardQRCode encodes into the QR.
        final qr = VCard(
          nom: 'Dupont',
          prenom: 'Marie',
          telWork: '+33612345678',
          email: 'marie.dupont@acme.fr',
          rev: '20261012T000000Z',
        ).toVCard();
        expect(qr, contains('VERSION:4.0'));
        expect(
          qr,
          contains('TEL;TYPE=work,voice;VALUE=uri:tel:+33612345678'),
        );
        expect(qr, contains('EMAIL:marie.dupont@acme.fr'));
      },
    );
  });
}
