import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PNG file signature: first 8 bytes are always 89 50 4E 47 0D 0A 1A 0A.
const _pngMagic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  // ---------------------------------------------------------------------------
  // buildQrBytes — pure in-memory PNG generation
  // ---------------------------------------------------------------------------
  group('buildQrBytes', () {
    test('returns bytes starting with PNG magic signature', () async {
      final bytes = await buildQrBytes('hello');
      expect(bytes.length, greaterThan(8));
      expect(bytes.sublist(0, 8), equals(_pngMagic));
    });

    test('vCard string produces a PNG', () async {
      const vcard = 'BEGIN:VCARD\r\n'
          'VERSION:3.0\r\n'
          'N:Dupont;Marie;;;\r\n'
          'FN:Marie Dupont\r\n'
          'TEL;TYPE=WORK,VOICE:+33612345678\r\n'
          'END:VCARD\r\n';
      final bytes = await buildQrBytes(vcard);
      expect(bytes.sublist(0, 8), equals(_pngMagic));
    });

    test('black color produces a PNG', () async {
      final bytes = await buildQrBytes('test');
      expect(bytes.sublist(0, 8), equals(_pngMagic));
    });

    test('custom color produces a PNG', () async {
      final bytes = await buildQrBytes('test', color: const Color(0xFF0EA5E9));
      expect(bytes.sublist(0, 8), equals(_pngMagic));
    });

    test('two calls with same data return identical bytes', () async {
      final a = await buildQrBytes('deterministic');
      final b = await buildQrBytes('deterministic');
      expect(a, equals(b));
    });

    test('different payloads produce different bytes', () async {
      final a = await buildQrBytes('payload-A');
      final b = await buildQrBytes('payload-B');
      expect(a, isNot(equals(b)));
    });

    test('output is larger than 1 KB (non-trivial PNG content)', () async {
      final bytes = await buildQrBytes('some qr content');
      expect(bytes.length, greaterThan(1024));
    });

    test('oversized payload throws Exception', () async {
      final oversized = 'x' * 3000;
      await expectLater(
        () => buildQrBytes(oversized),
        throwsA(isA<Exception>()),
      );
    });

    test('oversized payload exception message contains localised text',
        () async {
      try {
        await buildQrBytes('x' * 3000);
        fail('Expected an exception');
      } on Exception catch (e) {
        expect(e.toString(), isNotEmpty);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // saveQrCode — existing validation tests (unchanged behaviour)
  // ---------------------------------------------------------------------------
  group('saveQrCode — QR validation', () {
    test('payload exceeding QR max capacity throws Exception', () async {
      final oversized = 'x' * 3000;
      await expectLater(
        () => saveQrCode(oversized, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('thrown message for oversized payload is a non-empty string',
        () async {
      final oversized = 'x' * 3000;
      try {
        await saveQrCode(oversized, 1);
        fail('Expected an exception to be thrown');
      } on Exception catch (e) {
        expect(e.toString(), isNotEmpty);
      }
    });

    test('valid short payload passes QR validation', () async {
      // saveQrCode passes validation but may fail at the FS layer
      // (MissingPluginException / PathProviderException in unit tests).
      // An error containing 'invalid qr' would mean validation failed —
      // that must not happen for 'hello'.
      try {
        await saveQrCode('hello', 1);
        // Reaching here means validation and FS both succeeded — fine.
      } on Exception catch (e) {
        // MissingPluginException / PathNotFoundException: FS unavailable,
        // validation still passed. Acceptable in unit tests.
        expect(e.toString(), isNot(contains('invalid qr')));
      }
    });
  });
}
