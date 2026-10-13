import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/qr_decode.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _simple = 'https://github.com/jojo8356/EZQRContact';

const _fixtureDir = 'test/fixtures/zxing_blackbox';

class _Quality {
  const new(
    this.name, {
    required this.jpegQuality,
    required this.tiltDeg,
    required this.blurRadius,
    required this.grainAmplitude,
  });

  final String name;
  final int jpegQuality;
  final double tiltDeg;
  final int blurRadius;
  final int grainAmplitude;
}

/// Ladder modelled on BoofCV / ZXing photo categories: clean capture,
/// mild JPEG, typical phone gallery, harsh print-ad shot.
const _qualities = <_Quality>[
  _Quality(
    'clean',
    jpegQuality: 95,
    tiltDeg: 0,
    blurRadius: 0,
    grainAmplitude: 0,
  ),
  _Quality(
    'mild',
    jpegQuality: 85,
    tiltDeg: 3,
    blurRadius: 0,
    grainAmplitude: 6,
  ),
  _Quality(
    'medium',
    jpegQuality: 72,
    tiltDeg: 6,
    blurRadius: 1,
    grainAmplitude: 8,
  ),
  _Quality(
    'harsh',
    jpegQuality: 50,
    tiltDeg: 10,
    blurRadius: 1,
    grainAmplitude: 12,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
    await VCardSettingsProvider.init();
  });

  group('photo quality ladder', () {
    for (final q in _qualities) {
      test('simple QR survives a ${q.name} desk photo', () async {
        final photo = embedQrInNoisyPhoto(
          await buildQrBytes(_simple),
          jpegQuality: q.jpegQuality,
          tiltDeg: q.tiltDeg,
          blurRadius: q.blurRadius,
          grainAmplitude: q.grainAmplitude,
        );
        expect(decodeQrFromBytes(photo), _simple);
      });
    }

    test('vCard QR survives a harsh desk photo', () async {
      final payload = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        telWork: '+33612345678',
        email: 'marie.dupont@acme.fr',
        rev: '20261012T000000Z',
      ).toVCard();
      final photo = embedQrInNoisyPhoto(
        await buildQrBytes(payload),
        jpegQuality: 50,
        tiltDeg: 10,
        blurRadius: 1,
        grainAmplitude: 12,
      );
      final text = decodeQrFromBytes(photo);
      expect(text, isNotNull);
      expect(VCard.isVCard(text!), isTrue);
      expect(text, contains('Marie Dupont'));
    });
  });

  // Phone photo of a QR on a monitor: LCD moiré, RGB fringe, tilt.
  group('screen photos (tilted, noisy)', () {
    test('simple QR on a screen at +7° with moiré', () async {
      final photo = embedQrOnScreenPhoto(
        await buildQrBytes(_simple),
        tiltDeg: 7,
      );
      expect(decodeQrFromBytes(photo), _simple);
    });

    test('simple QR on a screen at -9° with moiré', () async {
      final photo = embedQrOnScreenPhoto(
        await buildQrBytes(_simple),
        tiltDeg: -9,
        seed: 11,
      );
      expect(decodeQrFromBytes(photo), _simple);
    });

    test('vCard QR on a tilted screen', () async {
      final payload = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        telWork: '+33612345678',
        email: 'marie.dupont@acme.fr',
        rev: '20261012T000000Z',
      ).toVCard();
      final photo = embedQrOnScreenPhoto(
        await buildQrBytes(payload),
        tiltDeg: 6,
      );
      final text = decodeQrFromBytes(photo);
      expect(text, isNotNull);
      expect(VCard.isVCard(text!), isTrue);
    });
  });

  group('user gallery JPEGs', () {
    final dir = Directory('test/fixtures/screen_photos');
    final jpgs = <File>[];
    if (dir.existsSync()) {
      jpgs.addAll(
        dir.listSync().whereType<File>().where((f) {
          final n = f.path.toLowerCase();
          return n.endsWith('.jpg') || n.endsWith('.jpeg');
        }),
      );
      jpgs.sort((a, b) => a.path.compareTo(b.path));
    }
    for (final jpg in jpgs) {
      final name = jpg.uri.pathSegments.last;
      test('decodes $name', () {
        final got = decodeQrFromBytes(jpg.readAsBytesSync());
        expect(got, isNotNull, reason: name);
        expect(got!.isNotEmpty, isTrue);
      });
    }
  });

  // Photographed / print-ad samples from ZXing's Java blackbox corpus.
  // Packed rasters (qrcode-2/1) and tiny rotated finders (qrcode-6)
  // are Java-detector cases zxing2 0.2.4 does not cover; omitted.
  group('ZXing blackbox fixtures', () {
    final dir = Directory(_fixtureDir);
    final pngs = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    test('fixture corpus is present', () {
      expect(pngs, isNotEmpty);
    });

    for (final png in pngs) {
      final name = png.uri.pathSegments.last;
      test('decodes $name', () {
        final txt = File(png.path.replaceAll('.png', '.txt'));
        expect(txt.existsSync(), isTrue, reason: txt.path);
        final expected = txt.readAsStringSync().trim();
        final got = decodeQrFromBytes(png.readAsBytesSync());
        expect(got, expected);
      });
    }
  });
}
