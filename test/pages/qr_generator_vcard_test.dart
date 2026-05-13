import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

ByteData _buildFakeManifestBin() {
  const codec = StandardMessageCodec();
  return codec.encodeMessage(<String, Object?>{
    'assets/langs/en.json': <Object?>[],
    'assets/langs/fr.json': <Object?>[],
  })!;
}

Widget _buildApp() => MaterialApp(
  home: const GenerateVCardQRCode(),
  routes: {
    '/collection': (_) => const Scaffold(),
    '/settings': (_) => const Scaffold(),
    '/history': (_) => const Scaffold(),
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() {
    darkProv.setDarkMode(false);
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
    darkProv.setDarkMode(false);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('GenerateVCardQRCode — color picker UI', () {
    testWidgets('Appearance section label is rendered', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('Primary color label is rendered', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.text('Primary color'), findsOneWidget);
    });

    testWidgets('Color swatch GestureDetector is present', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // The color swatch is a GestureDetector containing a Container
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Color swatch defaults to black', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      // Find the color swatch container (last Container with a BoxDecoration)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final swatches = containers.where((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.color == Colors.black &&
            deco.borderRadius != null;
      });
      expect(swatches, isNotEmpty);
    });
  });
}
