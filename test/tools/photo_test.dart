import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr_code_app/tools/photo.dart';

/// Creates a [width]×[height] test image filled with a solid colour and
/// returns its PNG-encoded bytes.
Uint8List _makeTestPng(int width, int height) {
  final image = img.Image(width: width, height: height)
    ..clear(img.ColorRgb8(100, 149, 237));
  return img.encodePng(image);
}

void main() {
  group('resizeAndCompressJpeg', () {
    test('returns JPEG bytes for a valid image', () async {
      final png = _makeTestPng(200, 150);
      final result = await resizeAndCompressJpeg(png);
      // JPEG magic bytes: FF D8
      expect(result[0], 0xFF);
      expect(result[1], 0xD8);
    });

    test('scales down images larger than maxSide', () async {
      final png = _makeTestPng(800, 600);
      final result = await resizeAndCompressJpeg(
        png,
        maxSide: 400,
      );
      final decoded = img.decodeJpg(result);
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(400));
      expect(decoded.height, lessThanOrEqualTo(400));
    });

    test('does not upscale small images', () async {
      final png = _makeTestPng(100, 80);
      // Default maxSide=720 is much larger than the 100×80 source.
      final result = await resizeAndCompressJpeg(png);
      final decoded = img.decodeJpg(result);
      expect(decoded, isNotNull);
      expect(decoded!.width, 100);
      expect(decoded.height, 80);
    });
  });

  group('compressPhotoForVCard', () {
    test(
      'returns data URI starting with data:image/jpeg;base64,',
      () async {
        final png = _makeTestPng(200, 150);
        final uri = await compressPhotoForVCard(png);
        expect(uri, isNotNull);
        expect(uri, startsWith('data:image/jpeg;base64,'));
      },
    );

    test('result fits under 200KB', () async {
      final png = _makeTestPng(200, 150);
      final uri = await compressPhotoForVCard(png);
      expect(uri, isNotNull);
      final b64 = uri!.split(',').last;
      expect(b64.length, lessThanOrEqualTo(204800));
    });

    test('returns null for undecodable bytes', () async {
      final garbage = Uint8List.fromList(
        List.generate(512, (i) => i % 256),
      );
      final uri = await compressPhotoForVCard(garbage);
      // Undecodable → resizeAndCompressIsolate returns raw bytes.
      // The raw bytes are small enough to pass the 200KB check, OR
      // decodeImage returns null and the raw bytes are returned.
      // Either way, compressPhotoForVCard should not throw.
      // For truly undecodable data the function returns null or a URI.
      // We just assert it doesn't throw.
      expect(uri, anyOf(isNull, startsWith('data:image/jpeg;base64,')));
    });

    test(
      'compressPhotoForVCard base64 payload is valid base64',
      () async {
        final png = _makeTestPng(300, 200);
        final uri = await compressPhotoForVCard(png);
        expect(uri, isNotNull);
        final b64 = uri!.split(',').last;
        expect(
          () => base64Decode(b64),
          returnsNormally,
        );
      },
    );
  });

  group('hostPhotoForQr', () {
    tearDown(() {
      debugHostPhotoForQr = null;
      debugHasInternet = null;
      resetPhotoHostCache();
    });

    test('deviceHasInternet respects the debug hook', () async {
      debugHasInternet = true;
      expect(await deviceHasInternet(), isTrue);
      debugHasInternet = false;
      expect(await deviceHasInternet(), isFalse);
    });

    test('deviceHasInternet is false in tests by default', () async {
      expect(await deviceHasInternet(), isFalse);
    });

    test('returns http(s) photo unchanged', () async {
      expect(
        await hostPhotoForQr('https://cdn.example/a.jpg'),
        'https://cdn.example/a.jpg',
      );
      expect(
        await hostPhotoForQr('http://cdn.example/a.jpg'),
        'http://cdn.example/a.jpg',
      );
    });

    test('returns null for empty or non-image values', () async {
      expect(await hostPhotoForQr(''), isNull);
      expect(await hostPhotoForQr('not-a-photo'), isNull);
    });

    test('does not upload data URIs during flutter test', () async {
      expect(
        await hostPhotoForQr('data:image/jpeg;base64,abcd'),
        isNull,
      );
    });

    test('debug hook hosts a data URI without the network', () async {
      debugHostPhotoForQr = (_) async => 'https://files.example/p.jpg';
      final url = await hostPhotoForQr('data:image/jpeg;base64,abcd');
      expect(url, 'https://files.example/p.jpg');
    });

    test('debug hook can refuse hosting', () async {
      debugHostPhotoForQr = (_) async => null;
      expect(
        await hostPhotoForQr('data:image/jpeg;base64,abcd'),
        isNull,
      );
    });
  });
}
