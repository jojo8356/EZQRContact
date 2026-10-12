import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/pages/scan_result_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/qr_decode.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../helpers/encre.dart';

const _vcardQr = 'BEGIN:VCARD\r\n'
    'VERSION:3.0\r\n'
    'N:Dupont;Marie;;;\r\n'
    'FN:Marie Dupont\r\n'
    'TEL;TYPE=WORK,VOICE:+33612345678\r\n'
    'EMAIL;TYPE=INTERNET:marie.dupont@acme.fr\r\n'
    'END:VCARD';

const _simpleQr = 'https://github.com/jojo8356/EZQRContact';

Future<void> _openImport(
  WidgetTester tester, {
  required QrFromImagePage import,
}) async {
  await tester.pumpWidget(
    encreApp(
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

Future<void> _tapPick(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('import-pick-image')));
  for (var i = 0; i < 8; i++) {
    await tester.pump();
  }
  // showToast arms a 3 s PausableTimer that outlives the tree.
  toastification.dismissAll();
  await tester.pump();
  // MaterialPageRoute reverse transition is 300 ms.
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
    await VCardSettingsProvider.init();
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() {
    toastification.dismissAll();
    darkProv.forceSetDarkMode(false);
  });

  group('QrFromImagePage — rendering', () {
    testWidgets('page renders without throwing inside MaterialApp',
        (tester) async {
      await tester.pumpWidget(encreApp(home: const QrFromImagePage()));
      await tester.pumpAndSettle();
      expect(find.byType(QrFromImagePage), findsOneWidget);
    });

    testWidgets('ENCRE paper card + primary copper AppButton', (tester) async {
      await tester.pumpWidget(encreApp(home: const QrFromImagePage()));
      await tester.pumpAndSettle();
      expect(find.byType(PaperCard), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);

      final btn = tester.widget<AppButton>(find.byType(AppButton));
      expect(btn.variant, AppButtonVariant.primary);
      expect(btn.onPressed, isNotNull);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, const Color(0xFFC45C26));
    });
  });

  // docs/manual-test.md §4 — gallery import
  group('manual 4.1 — image with a vCard QR', () {
    testWidgets(
      'parses, saves, and opens the scanned contact',
      (tester) async {
        Map<String, dynamic>? saved;
        await _openImport(
          tester,
          import: QrFromImagePage(
            pickImage: () async => XFile('gallery-vcard.png'),
            analyzeImage: (path) async => _vcardQr,
            saveVCard: (data) async {
              saved = data;
              return 7;
            },
          ),
        );

        await _tapPick(tester);

        expect(saved, isNotNull);
        expect(saved!['nom'], 'Dupont');
        expect(saved!['prenom'], 'Marie');
        expect(find.byType(ScanResultPage), findsOneWidget);
        expect(find.text('Marie Dupont'), findsOneWidget);
      },
    );
  });

  group('manual 4.2 — image with a plain-text QR', () {
    testWidgets(
      'saves a SimpleQR and pops back to the list',
      (tester) async {
        final saved = <String>[];
        await _openImport(
          tester,
          import: QrFromImagePage(
            pickImage: () async => XFile('gallery-url.png'),
            analyzeImage: (path) async => _simpleQr,
            saveSimpleQr: (text) async {
              saved.add(text);
              return 3;
            },
          ),
        );

        await _tapPick(tester);

        expect(saved, equals([_simpleQr]));
        expect(find.byType(QrFromImagePage), findsNothing);
        expect(find.byType(ScanResultPage), findsNothing);
        expect(find.text('Collection'), findsOneWidget);
      },
    );
  });

  group('manual 4.3 — image without a QR', () {
    testWidgets(
      'shows the no-QR SnackBar and stays on the import page',
      (tester) async {
        var savedV = 0;
        var savedS = 0;
        await _openImport(
          tester,
          import: QrFromImagePage(
            pickImage: () async => XFile('landscape.jpg'),
            analyzeImage: (path) async => null,
            saveVCard: (data) async {
              savedV += 1;
              return 1;
            },
            saveSimpleQr: (text) async {
              savedS += 1;
              return 1;
            },
          ),
        );

        await _tapPick(tester);

        expect(savedV, 0);
        expect(savedS, 0);
        expect(find.byType(QrFromImagePage), findsOneWidget);
        expect(find.byType(ScanResultPage), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('No QR code found in this image'),
          findsOneWidget,
        );
      },
    );
  });

  // Generate a real PNG (and a photo-like scene), decode with ZXing, import.
  group('generate then import', () {
    testWidgets(
      'simple QR photo is decoded and saved as SimpleQR',
      (tester) async {
        final png = embedQrInScene(await buildQrBytes(_simpleQr));
        final saved = <String>[];
        await _openImport(
          tester,
          import: QrFromImagePage(
            pickImage: () async => XFile('simple-photo.png'),
            analyzeImage: (_) async => decodeQrFromBytes(png),
            saveSimpleQr: (text) async {
              saved.add(text);
              return 1;
            },
          ),
        );

        await _tapPick(tester);

        expect(saved, equals([_simpleQr]));
        expect(find.byType(QrFromImagePage), findsNothing);
      },
    );

    testWidgets(
      'vCard QR photo is decoded, parsed, and opened',
      (tester) async {
        final payload = VCard(
          nom: 'Dupont',
          prenom: 'Marie',
          telWork: '+33612345678',
          email: 'marie.dupont@acme.fr',
          rev: '20261012T000000Z',
        ).toVCard();
        final png = embedQrInScene(await buildQrBytes(payload));
        Map<String, dynamic>? saved;
        await _openImport(
          tester,
          import: QrFromImagePage(
            pickImage: () async => XFile('vcard-photo.png'),
            analyzeImage: (_) async => decodeQrFromBytes(png),
            saveVCard: (data) async {
              saved = data;
              return 7;
            },
          ),
        );

        await _tapPick(tester);

        expect(saved, isNotNull);
        expect(saved!['nom'], 'Dupont');
        expect(saved!['prenom'], 'Marie');
        expect(find.byType(ScanResultPage), findsOneWidget);
        expect(find.text('Marie Dupont'), findsOneWidget);
      },
    );
  });
}
