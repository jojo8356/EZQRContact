import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Wraps [SettingsPage] with the routes its bottom navigation bar may push.
Widget _buildApp() {
  return MaterialApp(
    home: const SettingsPage(),
    routes: {
      '/settings': (_) => const SettingsPage(),
      '/options': (_) => const Scaffold(),
      '/collection': (_) => const Scaffold(),
      '/history': (_) => const Scaffold(),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
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

    testWidgets('tapping dark-mode ElevatedButton flips isDarkMode to true',
        (tester) async {
      await pumpSettingsPage(tester);

      final buttons = find.byType(ElevatedButton);
      expect(buttons.evaluate(), isNotEmpty);

      await tester.tap(buttons.last);
      // pumpAndSettle pumps 100 ms frames until no pending callbacks.
      // The Ticker records _startTime on its first tick (elapsed = 0) then
      // needs ~300 ms more, so ~4 frames of 100 ms each before it stops.
      await tester.pumpAndSettle();
      expect(darkProv.isDarkMode, isTrue);
    });
  });
}
