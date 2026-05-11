import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await VCardSettingsProvider.init();
  });

  group('VCard.toVCard() — vCard 3.0 generation (Story 2.1)', () {
    test('emits VERSION:3.0 by default', () {
      final v = VCard(nom: 'Doe', prenom: 'Jane', rev: '20260101T000000Z');
      final out = v.toVCard();
      expect(out, contains('BEGIN:VCARD\r\n'));
      expect(out, contains('VERSION:3.0\r\n'));
      expect(out, contains('END:VCARD\r\n'));
    });

    test('every content line is terminated by CRLF', () {
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        org: 'Acme',
        job: 'CEO',
        telWork: '+33611111111',
        telHome: '+33622222222',
        adrWork: '1 rue de Paris',
        adrHome: '2 rue de Lyon',
        email: 'jane@acme.com',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      // Should not contain a bare LF that isn't preceded by CR.
      for (var i = 0; i < out.length; i++) {
        if (out.codeUnitAt(i) == 0x0A) {
          expect(i, greaterThan(0), reason: 'LF at start');
          expect(out.codeUnitAt(i - 1), 0x0D, reason: 'bare LF at offset $i');
        }
      }
      // Ends with CRLF after END:VCARD.
      expect(out.endsWith('END:VCARD\r\n'), isTrue);
    });

    test('empty optional fields are skipped (no ORG/TITLE/TEL/ADR/EMAIL)', () {
      final v = VCard(nom: 'Doe', prenom: 'Jane', rev: '20260101T000000Z');
      final out = v.toVCard();
      expect(out, isNot(contains('ORG:')));
      expect(out, isNot(contains('TITLE:')));
      expect(out, isNot(contains('TEL')));
      expect(out, isNot(contains('ADR')));
      expect(out, isNot(contains('EMAIL')));
      // N and FN must always be present (RFC 2426).
      expect(out, contains('N:Doe;Jane;'));
      expect(out, contains('FN:Jane Doe'));
    });

    test('inline data:image base64 PHOTO is included with ENCODING=b', () {
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        photo: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      expect(out, contains('PHOTO;ENCODING=b;TYPE=JPEG:/9j/4AAQSkZJRg=='));
    });

    test('PHOTO with http URL uses VALUE=URI param', () {
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        photo: 'https://example.com/jane.jpg',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      expect(out, contains('PHOTO;VALUE=URI:https://example.com/jane.jpg'));
    });

    test('vCard 3.0 uses TEL;TYPE=WORK,VOICE: not TEL;VALUE=uri:tel:', () {
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        telWork: '+33611111111',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      expect(out, contains('TEL;TYPE=WORK,VOICE:+33611111111'));
      expect(out, isNot(contains('VALUE=uri:tel:')));
    });

    test('vCard 3.0 emits EMAIL;TYPE=INTERNET prefix', () {
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        email: 'jane@acme.com',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      expect(out, contains('EMAIL;TYPE=INTERNET:jane@acme.com'));
    });

    test('lines longer than 75 octets are folded with CRLF SPACE', () {
      // Build a TITLE longer than 75 bytes to force folding.
      final longTitle = 'X' * 120;
      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        job: longTitle,
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      // The folded continuation must start with CRLF + space.
      expect(out, contains('\r\n '));
      // After unfolding, the title should round-trip.
      final lines = out
          .split('\r\n')
          .where((l) => l.isNotEmpty)
          .toList();
      // Verify no logical line exceeds the limit on disk.
      for (final line in lines) {
        expect(line.length, lessThanOrEqualTo(75 + 1),
            reason: 'line over 75 octets: "$line"');
      }
    });

    test('round-trip: 3.0 export → parse → equal canonical fields', () {
      final original = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        org: 'Acme',
        job: 'CEO',
        telWork: '+33611111111',
        telHome: '+33622222222',
        adrHome: '2 rue de Lyon',
        email: 'jane@acme.com',
        rev: '20260101T000000Z',
      );
      final parsed = VCard.parse(original.toVCard());
      expect(parsed.nom, 'Doe');
      expect(parsed.prenom, 'Jane');
      expect(parsed.org, 'Acme');
      expect(parsed.job, 'CEO');
      expect(parsed.telWork, '+33611111111');
      expect(parsed.telHome, '+33622222222');
      expect(parsed.adrHome, contains('2 rue de Lyon'));
      expect(parsed.email, 'jane@acme.com');
    });
  });

  group('VCard.toVCard() — toggle useVCard4 (Story 2.1 AC-2)', () {
    test('useVCard4=true produces VERSION:4.0', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      addTearDown(() async => VCardSettingsProvider.setUseVCard4(false));

      final v = VCard(nom: 'Doe', prenom: 'Jane', rev: '20260101T000000Z');
      final out = v.toVCard();
      expect(out, contains('VERSION:4.0\r\n'));
      expect(out, isNot(contains('VERSION:3.0')));
    });

    test('useVCard4=true uses TEL;VALUE=uri:tel: format', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      addTearDown(() async => VCardSettingsProvider.setUseVCard4(false));

      final v = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        telHome: '+33622222222',
        rev: '20260101T000000Z',
      );
      final out = v.toVCard();
      expect(out, contains('VALUE=uri:tel:+33622222222'));
    });

    test('setUseVCard4(false) re-enables 3.0', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      await VCardSettingsProvider.setUseVCard4(false);
      final v = VCard(nom: 'Doe', prenom: 'Jane', rev: '20260101T000000Z');
      expect(v.toVCard(), contains('VERSION:3.0\r\n'));
    });
  });

  group('VCardSettingsProvider — pref persistence (Story 2.1 AC-2)', () {
    test('defaults to false on first init', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await VCardSettingsProvider.init();
      expect(VCardSettingsProvider.useVCard4, isFalse);
    });

    test('reads pref on init', () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'use_vcard4': true},
      );
      await VCardSettingsProvider.init();
      expect(VCardSettingsProvider.useVCard4, isTrue);
    });

    test('setUseVCard4 persists across re-init', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await VCardSettingsProvider.init();
      await VCardSettingsProvider.setUseVCard4(true);
      // Simulate restart: a fresh init() reads the persisted value.
      await VCardSettingsProvider.init();
      expect(VCardSettingsProvider.useVCard4, isTrue);
    });
  });
}
