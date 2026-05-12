import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal asset-manifest stub listing the two bundled language files.
const _kFakeManifest =
    '{"assets/langs/en.json":["assets/langs/en.json"],'
    '"assets/langs/fr.json":["assets/langs/fr.json"]}';

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
    darkProv.setDarkMode(false);
    // Install a mock asset handler that intercepts `AssetManifest.json` so
    // [LangProvider.getAll] can populate the language list without the real
    // Flutter-generated manifest (not present in unit tests).
    // PlatformAssetBundle sends the key as raw UTF-8 bytes and expects raw
    // UTF-8 bytes back. Returning null for other keys delegates to the real
    // platform handler which serves the actual lang JSON assets.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List());
      if (key == 'AssetManifest.json') {
        final bytes = utf8.encode(_kFakeManifest);
        final result = ByteData(bytes.length);
        for (var i = 0; i < bytes.length; i++) {
          result.setUint8(i, bytes[i]);
        }
        return result;
      }
      return null;
    });
  });

  tearDown(() {
    darkProv.setDarkMode(false);
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
      // AppBarCustom renders a standard Flutter AppBar internally.
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

      // The last ElevatedButton corresponds to the "mode" (dark-mode) button
      // per the order defined in the settings page buttons list.
      final buttons = find.byType(ElevatedButton);
      expect(buttons.evaluate(), isNotEmpty);

      await tester.tap(buttons.last);
      await tester.pump();
      expect(darkProv.isDarkMode, isTrue);
    });
  });
}
