// Live generate→import: raster a SimpleQR and a vCard QR, wrap each in a
// noisy full-frame desk JPEG, then run the production gallery decoder
// (ML Kit then ZXing) through QrFromImagePage. Does not inject analyzeImage.
//
//   flutter test integration_test/generate_and_import_test.dart
//   ./scripts/test_generate_import.sh
//   ./scripts/test_generate_import.sh <device-id>

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/pages/scan_result_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/tools/qr_decode.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:toastification/toastification.dart';

const _simple = 'https://github.com/jojo8356/EZQRContact';

Widget _app({required Widget home}) {
  return MaterialApp(
    theme: buildAppTheme(
      colors: currentColors,
      isDark: darkProv.isDarkMode,
    ),
    home: home,
  );
}

Future<void> _openImport(
  WidgetTester tester, {
  required QrFromImagePage import,
}) async {
  await tester.pumpWidget(
    _app(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Collection')),
            body: Center(
              child: TextButton(
                key: const Key('open-import'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => import),
                  );
                },
                child: const Text('open-import'),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('open-import')));
  await tester.pumpAndSettle();
}

Future<void> _tapPickUntil(
  WidgetTester tester, {
  required bool Function() done,
}) async {
  await tester.tap(find.byKey(const Key('import-pick-image')));
  await tester.pump();
  final until = DateTime.now().add(const Duration(seconds: 15));
  while (!done() && DateTime.now().isBefore(until)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  toastification.dismissAll();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<String> _writeScene(String name, Uint8List png) async {
  final dir = await Directory.systemTemp.createTemp('ezqr-gen-import');
  final path = '${dir.path}/$name';
  await File(path).writeAsBytes(png);
  return path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LangProvider.init(lang: 'en');
    await VCardSettingsProvider.init();
    darkProv.forceSetDarkMode(false);
  });

  tearDown(() {
    toastification.dismissAll();
  });

  testWidgets(
    'generated simple QR photo imports as SimpleQR',
    (tester) async {
      final photo = embedQrInNoisyPhoto(await buildQrBytes(_simple));
      final path = await _writeScene('simple-desk.jpg', photo);
      addTearDown(() => File(path).parent.delete(recursive: true));

      final saved = <String>[];
      await _openImport(
        tester,
        import: QrFromImagePage(
          pickImage: () async => XFile(path),
          saveSimpleQr: (text) async {
            saved.add(text);
            return 1;
          },
        ),
      );

      await _tapPickUntil(tester, done: () => saved.isNotEmpty);

      expect(saved, equals([_simple]));
      expect(find.byType(QrFromImagePage), findsNothing);
      expect(find.text('Collection'), findsOneWidget);
    },
  );

  testWidgets(
    'generated vCard QR photo imports as a contact',
    (tester) async {
      final payload = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        telWork: '+33612345678',
        email: 'marie.dupont@acme.fr',
        rev: '20261012T000000Z',
      ).toVCard();
      final photo = embedQrInNoisyPhoto(await buildQrBytes(payload));
      final path = await _writeScene('vcard-desk.jpg', photo);
      addTearDown(() => File(path).parent.delete(recursive: true));

      Map<String, dynamic>? saved;
      await _openImport(
        tester,
        import: QrFromImagePage(
          pickImage: () async => XFile(path),
          saveVCard: (data) async {
            saved = data;
            return 7;
          },
        ),
      );

      await _tapPickUntil(tester, done: () => saved != null);

      expect(saved, isNotNull);
      expect(saved!['nom'], 'Dupont');
      expect(saved!['prenom'], 'Marie');
      expect(find.byType(ScanResultPage), findsOneWidget);
      expect(find.text('Marie Dupont'), findsOneWidget);
    },
  );
}
