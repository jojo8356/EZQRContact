import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/qr_decode.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _simple = 'https://github.com/jojo8356/EZQRContact';

VCard _marie() {
  return VCard(
    nom: 'Dupont',
    prenom: 'Marie',
    telWork: '+33612345678',
    email: 'marie.dupont@acme.fr',
    rev: '20261012T000000Z',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
    await VCardSettingsProvider.init();
  });

  test('decodes a generated simple QR PNG', () async {
    final png = await buildQrBytes(_simple);
    expect(decodeQrFromBytes(png), _simple);
  });

  test('decodes a generated vCard QR PNG', () async {
    final payload = _marie().toVCard();
    final png = await buildQrBytes(payload);
    final text = decodeQrFromBytes(png);
    expect(text, isNotNull);
    expect(text, contains('BEGIN:VCARD'));
    expect(text, contains('Marie Dupont'));
    expect(VCard.isVCard(text!), isTrue);
  });

  test('decodes a QR that is not cropped (photo-like scene)', () async {
    final png = await buildQrBytes(_simple);
    final photo = embedQrInScene(png);
    final qrImg = img.decodePng(png);
    final photoImg = img.decodePng(photo);
    expect(qrImg, isNotNull);
    expect(photoImg, isNotNull);
    expect(photoImg!.width, greaterThan(qrImg!.width));
    expect(photoImg.height, greaterThan(qrImg.height));
    expect(decodeQrFromBytes(photo), _simple);
  });

  test('decodes a JPEG photo of a QR', () async {
    final png = embedQrInScene(await buildQrBytes(_simple));
    final decoded = img.decodePng(png);
    expect(decoded, isNotNull);
    final jpeg = Uint8List.fromList(img.encodeJpg(decoded!, quality: 85));
    expect(decodeQrFromBytes(jpeg), _simple);
  });

  test('decodeQrFromFile falls back to ZXing on a photo file', () async {
    final png = embedQrInScene(await buildQrBytes(_simple));
    final dir = await Directory.systemTemp.createTemp('ezqr-decode');
    final path = '${dir.path}/photo.png';
    await File(path).writeAsBytes(png);
    addTearDown(() async {
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    });
    expect(await decodeQrFromFile(path), _simple);
  });

  test('returns null for an image with no QR', () {
    final blank = img.Image(width: 64, height: 64);
    img.fill(blank, color: img.ColorRgb8(200, 200, 200));
    final bytes = Uint8List.fromList(img.encodePng(blank));
    expect(decodeQrFromBytes(bytes), isNull);
  });
}
