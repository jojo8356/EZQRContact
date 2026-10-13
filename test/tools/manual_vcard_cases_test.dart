import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Automated payload checks for docs/manual-test.md §§1, 2, 11, 12.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await VCardSettingsProvider.init();
  });

  tearDown(() async {
    await VCardSettingsProvider.setUseVCard4(false);
  });

  group('manual 1.1 — nominal vCard 3.0', () {
    test('all filled fields appear with WORK/HOME types', () {
      final out = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        org: 'Acme Corp',
        job: 'DT',
        telWork: '+33612345678',
        telHome: '+33123456789',
        email: 'marie.dupont@acme.fr',
        adrWork: '12 rue de la Paix, 75001 Paris',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('BEGIN:VCARD\r\n'));
      expect(out, contains('VERSION:3.0\r\n'));
      expect(out, contains('N:Dupont;Marie;;;\r\n'));
      expect(out, contains('FN:Marie Dupont\r\n'));
      expect(out, contains('ORG:Acme Corp\r\n'));
      expect(out, contains('TITLE:DT\r\n'));
      expect(out, contains('TEL;TYPE=WORK,VOICE:+33612345678\r\n'));
      expect(out, contains('TEL;TYPE=HOME,VOICE:+33123456789\r\n'));
      expect(out, contains('EMAIL;TYPE=INTERNET:marie.dupont@acme.fr\r\n'));
      expect(out, contains('ADR;TYPE=WORK:'));
      expect(out, contains('12 rue de la Paix, 75001 Paris'));
      expect(out, endsWith('END:VCARD\r\n'));
    });
  });

  group('manual 1.3 — name + email only', () {
    test('skips TEL/ORG/ADR when empty', () {
      final out = VCard(
        nom: 'Martin',
        email: 'a@b.com',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('N:Martin;;;;\r\n'));
      expect(out, contains('FN:Martin\r\n'));
      expect(out, contains('EMAIL;TYPE=INTERNET:a@b.com\r\n'));
      expect(out, isNot(contains('TEL')));
      expect(out, isNot(contains('ORG:')));
      expect(out, isNot(contains('ADR')));
    });
  });

  group('manual 2.1 / 2.3 — vCard 4.0 vs 3.0 payload', () {
    test('4.0 uses lowercase TYPE and VALUE=uri:tel:', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      final out = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        telWork: '+33612345678',
        email: 'marie.dupont@acme.fr',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('VERSION:4.0\r\n'));
      expect(
        out,
        contains('TEL;TYPE=work,voice;VALUE=uri:tel:+33612345678'),
      );
      expect(out, contains('EMAIL:marie.dupont@acme.fr'));
      expect(out, isNot(contains('EMAIL;TYPE=INTERNET:')));
    });

    test('toggle OFF restores 3.0 WORK,VOICE', () async {
      await VCardSettingsProvider.setUseVCard4(true);
      await VCardSettingsProvider.setUseVCard4(false);
      final out = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        telWork: '+33612345678',
        email: 'marie.dupont@acme.fr',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('VERSION:3.0\r\n'));
      expect(out, contains('TEL;TYPE=WORK,VOICE:+33612345678'));
      expect(out, contains('EMAIL;TYPE=INTERNET:marie.dupont@acme.fr'));
    });
  });

  group('manual 11 — sanitisation', () {
    test('11.1 semicolon stripped from family name', () {
      final out = VCard(
        nom: 'Dupont;Injection',
        prenom: 'Marie',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('N:DupontInjection;Marie;;;\r\n'));
      expect(out, isNot(contains('Dupont;Injection')));
    });

    test('11.2 CR/LF stripped from org', () {
      final out = VCard(
        nom: 'Dupont',
        org: 'Acme\nCorp',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('ORG:AcmeCorp\r\n'));
    });

    test(r'11.2 literal \n sequence stripped from org', () {
      final out = VCard(
        nom: 'Dupont',
        org: r'Acme\nCorp',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('ORG:AcmeCorp\r\n'));
    });

    test('11.3 name of only semicolons collapses to empty N', () {
      final out = VCard(
        nom: ';;;',
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('N:;;;;\r\n'));
      expect(out, contains('BEGIN:VCARD'));
      expect(out, contains('END:VCARD\r\n'));
    });
  });

  group('manual 12 — line folding', () {
    test('long ADR is folded with CRLF SPACE and round-trips', () {
      const addr =
          'Bâtiment Horizon, 250 avenue des Champs-Élysées, '
          'Bureau 42, 75008 Paris, France';
      final out = VCard(
        nom: 'Dupont',
        prenom: 'Marie',
        adrWork: addr,
        rev: '20261013T000000Z',
      ).toVCard();
      expect(out, contains('\r\n '));
      final parsed = VCard.parse(out);
      expect(parsed.adrWork, contains('Bâtiment Horizon'));
      expect(parsed.adrWork, contains('75008 Paris'));
      expect(parsed.adrWork, isNot(contains('\n')));
    });
  });
}
