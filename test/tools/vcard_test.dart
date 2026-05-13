import 'dart:convert';

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

  group('VCard.parse() — dual-version (Story 2.2)', () {
    test('iCloud-style vCard 3.0 export (Mac Contacts)', () {
      // Apple Contacts → Export vCard produces 3.0 with item* groupings,
      // ENCODING=b photos, and X-ABLabel. We don't need the X-ABLabels —
      // just the core fields routing correctly.
      const vcard =
          'BEGIN:VCARD\r\n'
          'VERSION:3.0\r\n'
          'N:Polsinelli;Johan;;;\r\n'
          'FN:Johan Polsinelli\r\n'
          'ORG:Cycloth;\r\n'
          'TITLE:Founder\r\n'
          'TEL;type=CELL;type=VOICE;type=pref:+33611111111\r\n'
          'TEL;type=WORK;type=VOICE:+33422222222\r\n'
          'item1.ADR;type=HOME;type=pref:;;15 rue Garibaldi;Lyon;;69007;FR\r\n'
          'item1.X-ABLabel:_\$!<HomeAddress>!\$_\r\n'
          'EMAIL;type=INTERNET;type=HOME;type=pref:johan@example.com\r\n'
          'REV:2026-05-11T10:00:00Z\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Polsinelli');
      expect(v.prenom, 'Johan');
      expect(v.org, 'Cycloth;');
      expect(v.job, 'Founder');
      expect(v.telWork, '+33422222222');
      expect(v.telHome, '+33611111111');
      expect(v.adrHome, contains('15 rue Garibaldi'));
      expect(v.email, 'johan@example.com');
    });

    test('Google Contacts vCard 3.0 export', () {
      // Google Contacts → Export emits 3.0 with TYPE=WORK and TYPE=CELL,
      // PHOTO;ENCODING=b;TYPE=JPEG for embedded photos.
      const vcard =
          'BEGIN:VCARD\r\n'
          'VERSION:3.0\r\n'
          'N:Doe;Jane;;;\r\n'
          'FN:Jane Doe\r\n'
          'ORG:Acme Corp\r\n'
          'TITLE:CEO\r\n'
          'EMAIL;TYPE=INTERNET:jane.doe@acme.com\r\n'
          'TEL;TYPE=CELL:+15551234567\r\n'
          'TEL;TYPE=WORK:+15559876543\r\n'
          'ADR;TYPE=WORK:;;1 Infinite Loop;Cupertino;CA;95014;USA\r\n'
          'PHOTO;ENCODING=b;TYPE=JPEG:/9j/4AAQSkZJRg==\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Doe');
      expect(v.prenom, 'Jane');
      expect(v.org, 'Acme Corp');
      expect(v.job, 'CEO');
      expect(v.telWork, '+15559876543');
      expect(v.telHome, '+15551234567');
      expect(v.adrWork, contains('1 Infinite Loop'));
      expect(v.email, 'jane.doe@acme.com');
      expect(v.photo, startsWith('data:image/jpeg;base64,'));
      expect(v.photo, contains('/9j/4AAQSkZJRg=='));
    });

    test('Outlook vCard 2.1 export', () {
      // Older Outlook / Windows Address Book emit 2.1 with TEL;WORK
      // (no TYPE= prefix) and CHARSET=UTF-8 on some fields. We don't
      // implement QUOTED-PRINTABLE → fixture uses ASCII only.
      const vcard =
          'BEGIN:VCARD\r\n'
          'VERSION:2.1\r\n'
          'N:Smith;John;;;\r\n'
          'FN:John Smith\r\n'
          'ORG:Outlook Inc.\r\n'
          'TITLE:Manager\r\n'
          'TEL;WORK;VOICE:+442011112222\r\n'
          'TEL;CELL;VOICE:+447900111222\r\n'
          'EMAIL;PREF;INTERNET:john.smith@outlook.test\r\n'
          'ADR;WORK:;;221B Baker Street;London;;NW1 6XE;UK\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Smith');
      expect(v.prenom, 'John');
      expect(v.org, 'Outlook Inc.');
      expect(v.telWork, '+442011112222');
      expect(v.telHome, '+447900111222');
      expect(v.email, 'john.smith@outlook.test');
      expect(v.adrWork, contains('221B Baker Street'));
    });

    test('EZQRContact 3.0 round-trip', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await VCardSettingsProvider.init();
      final original = VCard(
        nom: 'Polsinelli',
        prenom: 'Johan',
        org: 'Cycloth',
        job: 'Fondateur',
        telWork: '+33611111111',
        telHome: '+33622222222',
        adrHome: '15 rue Garibaldi 69007 Lyon',
        email: 'johan@cycloth.com',
        photo: 'data:image/jpeg;base64,/9j/4AAQAB==',
        rev: '20260511T100000Z',
      );
      final parsed = VCard.parse(original.toVCard());
      expect(parsed.nom, original.nom);
      expect(parsed.prenom, original.prenom);
      expect(parsed.org, original.org);
      expect(parsed.job, original.job);
      expect(parsed.telWork, original.telWork);
      expect(parsed.telHome, original.telHome);
      expect(parsed.adrHome, contains('15 rue Garibaldi'));
      expect(parsed.email, original.email);
      expect(parsed.photo, startsWith('data:image/jpeg;base64,'));
    });

    test('EZQRContact 4.0 round-trip (useVCard4=true)', () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'use_vcard4': true},
      );
      await VCardSettingsProvider.init();
      addTearDown(() async => VCardSettingsProvider.setUseVCard4(false));

      final original = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        telHome: '+33611111111',
        email: 'jane@doe.com',
        rev: '20260511T100000Z',
      );
      final out = original.toVCard();
      expect(out, contains('VERSION:4.0'));
      expect(out, contains('VALUE=uri:tel:'));

      final parsed = VCard.parse(out);
      expect(parsed.nom, 'Doe');
      expect(parsed.prenom, 'Jane');
      // The 4.0 emits tel:+33...; parser strips the URI scheme.
      expect(parsed.telHome, '+33611111111');
      expect(parsed.email, 'jane@doe.com');
    });

    test('vCard 4.0 with TEL;VALUE=uri:tel: prefix', () {
      const vcard =
          'BEGIN:VCARD\r\n'
          'VERSION:4.0\r\n'
          'N:Doe;Jane;;;\r\n'
          'FN:Jane Doe\r\n'
          'TEL;TYPE=work,voice;VALUE=uri:tel:+33611111111\r\n'
          'EMAIL:jane@doe.com\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.telWork, '+33611111111');
      expect(v.email, 'jane@doe.com');
    });

    test('line unfolding RFC 6350 §3.2 (continuation lines)', () {
      // A PHOTO base64 split onto 3 physical lines (folded with " " after
      // CRLF). The unfolder must reconstruct the single logical line
      // before parsing.
      const vcard =
          'BEGIN:VCARD\r\n'
          'VERSION:3.0\r\n'
          'N:Long;Photo;;;\r\n'
          'FN:Photo Long\r\n'
          'PHOTO;ENCODING=b;TYPE=JPEG:/9j/4AAQSkZJRgABAQAAAQABAAD/2w\r\n'
          ' BDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsO\r\n'
          ' CwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAg==\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Long');
      expect(v.prenom, 'Photo');
      expect(v.photo, startsWith('data:image/jpeg;base64,'));
      // The full base64 (with no spaces left over) must be reconstructed.
      expect(v.photo, contains('/9j/4AAQSkZJRgABAQAAAQABAAD/2w'));
      expect(v.photo, contains('BDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgK'));
      expect(v.photo, isNot(contains(' ')));
    });

    test('VERSION header absent → defaults to 3.0 best-effort', () {
      const vcard =
          'BEGIN:VCARD\r\n'
          'N:Doe;Jane;;;\r\n'
          'FN:Jane Doe\r\n'
          'TEL;TYPE=WORK:+33611111111\r\n'
          'END:VCARD\r\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Doe');
      expect(v.telWork, '+33611111111');
    });

    test('mixed LF terminators (no CR) still parse', () {
      const vcard =
          'BEGIN:VCARD\n'
          'VERSION:3.0\n'
          'N:Doe;Jane;;;\n'
          'FN:Jane Doe\n'
          'EMAIL:jane@doe.com\n'
          'END:VCARD\n';
      final v = VCard.parse(vcard);
      expect(v.nom, 'Doe');
      expect(v.prenom, 'Jane');
      expect(v.email, 'jane@doe.com');
    });
  });

  group('VCard.clean() — sanitization hardening (Story 2.3)', () {
    final v = VCard();

    test('null input → empty string', () {
      expect(v.clean(null), '');
    });

    test('empty input → empty string', () {
      expect(v.clean(''), '');
    });

    test('plain ASCII passes through unchanged', () {
      expect(v.clean('Hello World'), 'Hello World');
    });

    test('strips semicolons (vCard component separator)', () {
      expect(v.clean('Mar;tin Dupont'), 'Martin Dupont');
    });

    test('strips LF line breaks (would inject new content lines)', () {
      expect(v.clean('Mar;tin\nDupont'), 'MartinDupont');
    });

    test('strips CRLF and bare CR', () {
      expect(v.clean('A\r\nB\rC'), 'ABC');
    });

    test('strips NUL byte and other C0 controls', () {
      expect(v.clean('foo barbaz'), 'foobarbaz');
    });

    test('preserves TAB (U+0009) — valid in vCard text-value', () {
      expect(v.clean('A\tB'), 'A\tB');
    });

    test('strips DEL (U+007F)', () {
      expect(v.clean('foobar'), 'foobar');
    });

    test('preserves emojis (supplementary plane)', () {
      expect(v.clean('Johan 🚀'), 'Johan 🚀');
      expect(v.clean('Mary Poppins ✨'), 'Mary Poppins ✨');
    });

    test('preserves accents and CJK', () {
      expect(v.clean('Émilie Müller 中文'), 'Émilie Müller 中文');
    });

    test('drops unpaired surrogate halves', () {
      // Build a string with an unpaired high surrogate. Dart accepts it
      // in a String literal; clean() must drop it.
      final lone = String.fromCharCode(0xD800);
      expect(v.clean('A${lone}B'), 'AB');
    });

    test('drops U+FFFE and U+FFFF non-characters', () {
      final fffe = String.fromCharCode(0xFFFE);
      final ffff = String.fromCharCode(0xFFFF);
      expect(v.clean('A${fffe}B${ffff}C'), 'ABC');
    });

    test('SQL-like injection attempt remains a literal string (no escape)',
        () {
      // Just a string — clean() doesn't escape, but doesn't break either.
      expect(v.clean("'; DROP TABLE users;--"), "' DROP TABLE users--");
    });

    test('HTML/script-like input is preserved literally', () {
      // We don't render HTML, so we keep the chars as-is. They appear
      // verbatim in the QR — that's intentional for fidelity.
      expect(v.clean('<script>alert(1)</script>'), '<script>alert(1)</script>');
    });

    test('mixed malicious payload: semicolons, newlines, NUL, surrogates', () {
      final lone = String.fromCharCode(0xD801);
      final raw = 'A;\nB\rC D${lone}EF';
      expect(v.clean(raw), 'ABCDEF');
    });

    test('only-malicious input collapses to empty', () {
      expect(v.clean(';;\n\r '), '');
    });

    test('semicolons inside vCard generation are sanitized away', () {
      final vc = VCard(
        nom: 'Du;pont',
        prenom: 'Jea\nn',
        rev: '20260101T000000Z',
      );
      final out = vc.toVCard();
      // The N line should be `N:Dupont;Jean;;;` after sanitization (no
      // extra `;` to break the 5-component contract).
      expect(out, contains('N:Dupont;Jean;;;\r\n'));
      // No bare LF must survive — searched by line: every `\n` must be
      // preceded by `\r`.
      for (var i = 0; i < out.length; i++) {
        if (out.codeUnitAt(i) == 0x0A) {
          expect(out.codeUnitAt(i - 1), 0x0D, reason: 'bare LF at $i');
        }
      }
    });

    // Regression — manual test 11.2: literal \n pasted from clipboard.
    test(r'literal \n sequence in org is stripped from vCard output', () {
      final vc = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        // r'\n' = backslash + n (two chars), as pasted from clipboard.
        org: r'Acme\nCorp',
        rev: '20260101T000000Z',
      );
      expect(vc.toVCard(), contains('ORG:AcmeCorp\r\n'));
    });

    test(r'literal \r\n sequence in org is stripped from vCard output', () {
      final vc = VCard(
        nom: 'Doe',
        prenom: 'Jane',
        org: 'Acme\r\nCorp',
        rev: '20260101T000000Z',
      );
      expect(vc.toVCard(), contains('ORG:AcmeCorp\r\n'));
    });

    test(r'clean strips literal \n escape sequence', () {
      final v = VCard();
      // Raw string: backslash + n, not a newline.
      expect(v.clean(r'Acme\nCorp'), 'AcmeCorp');
    });

    test(r'clean strips literal \r escape sequence', () {
      final v = VCard();
      expect(v.clean(r'Acme\rCorp'), 'AcmeCorp');
    });
  });

  // ---------------------------------------------------------------------------
  // Manual test 12 — Line folding on long fields (RFC 2425 §5.8.1)
  // ---------------------------------------------------------------------------
  group('VCard.toVCard() — line folding', () {
    const longAddr =
        'Bâtiment Horizon, 250 avenue des Champs-Élysées, '
        'Bureau 42, 75008 Paris, France';

    VCard vc() => VCard(
          nom: 'Doe',
          prenom: 'Jane',
          adrWork: longAddr,
          rev: '20260101T000000Z',
        );

    test('long ADR line is folded (CRLF + space continuation present)', () {
      expect(vc().toVCard(), contains('\r\n '));
    });

    test('no physical line exceeds 75 octets', () {
      final out = vc().toVCard();
      // Split on CRLF to get physical lines; the final empty segment
      // after the last CRLF is harmless.
      for (final line in out.split('\r\n')) {
        final len = utf8.encode(line).length;
        expect(len, lessThanOrEqualTo(75),
            reason: 'line too long ($len octets): $line');
      }
    });

    test('unfolding recovers the full address without byte loss', () {
      final out = vc().toVCard();
      // RFC 2425 unfold: remove every CRLF followed by a single space.
      final unfolded = out.replaceAll('\r\n ', '');
      expect(unfolded, contains(longAddr));
    });

    test('same guarantees hold for vCard 4.0', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      final out = vc().toVCard();
      await VCardSettingsProvider.setUseVCard4(false);

      expect(out, contains('\r\n '));
      for (final line in out.split('\r\n')) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75));
      }
      expect(out.replaceAll('\r\n ', ''), contains(longAddr));
    });
  });

  // ---------------------------------------------------------------------------
  // Story 5-1 / 5-2 — X-EZQR-VISUAL encode + decode
  // ---------------------------------------------------------------------------
  group('X-EZQR-VISUAL property (story 5-1 / 5-2)', () {
    const visualJson =
        '{"primaryColor":"#6600FF","layout":"minimal","logoBase64":"abc123"}';

    VCard vcWithVisual() => VCard(
          nom: 'Doe',
          prenom: 'Jane',
          rev: '20260101T000000Z',
          visualConfigJson: visualJson,
        );

    test('toVCard() embeds X-EZQR-VISUAL line with logo stripped', () {
      final out = vcWithVisual().toVCard();
      expect(out, contains('X-EZQR-VISUAL:'));
      // Logo must NOT appear in the embedded payload.
      final line = out
          .split('\r\n')
          .map((l) => l.replaceAll('\r\n ', ''))
          .firstWhere((l) => l.startsWith('X-EZQR-VISUAL:'));
      final encoded = line.substring('X-EZQR-VISUAL:'.length);
      // Strip any folding whitespace carried into the value.
      final cleaned = encoded.replaceAll(' ', '');
      final decoded = utf8.decode(base64Decode(cleaned));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      expect(map.containsKey('logoBase64'), isFalse);
      expect(map['primaryColor'], '#6600FF');
      expect(map['layout'], 'minimal');
    });

    test('VCard.parse() decodes X-EZQR-VISUAL into visual_config', () {
      final vcard = vcWithVisual();
      final raw = vcard.toVCard();
      final parsed = VCard.parse(raw);
      expect(parsed.visualConfigJson, isNotNull);
      final map = jsonDecode(parsed.visualConfigJson!) as Map<String, dynamic>;
      expect(map['primaryColor'], '#6600FF');
      expect(map['layout'], 'minimal');
    });

    test('VCard.parse() sets visual_config to null when X-EZQR-VISUAL absent',
        () {
      final plain = VCard(nom: 'X', prenom: 'Y', rev: '20260101T000000Z');
      final parsed = VCard.parse(plain.toVCard());
      expect(parsed.visualConfigJson, isNull);
    });

    test('VCard.parse() silently ignores malformed X-EZQR-VISUAL value', () {
      const broken =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Doe;Jane;;;\r\n'
          'FN:Jane Doe\r\nX-EZQR-VISUAL:!!!not-base64!!!\r\n'
          'REV:20260101T000000Z\r\nEND:VCARD\r\n';
      expect(() => VCard.parse(broken), returnsNormally);
      final parsed = VCard.parse(broken);
      expect(parsed.visualConfigJson, isNull);
    });
  });
}
