import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/import_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await VCardSettingsProvider.init();
  });

  group('contactNameKey', () {
    test('joins trimmed lowercase prenom and nom', () {
      expect(
        contactNameKey({'prenom': ' Marie ', 'nom': 'DUPONT'}),
        'marie|dupont',
      );
    });

    test('empty names return empty key', () {
      expect(contactNameKey({'prenom': '', 'nom': '  '}), '');
      expect(contactNameKey({}), '');
    });

    test('prenom only is still a key', () {
      expect(contactNameKey({'prenom': 'Marie'}), 'marie|');
    });
  });

  group('contactsToImport', () {
    test('drops nameless rows', () {
      final out = contactsToImport(
        [
          {'prenom': '', 'nom': ''},
          {'prenom': 'Marie', 'nom': 'Dupont'},
        ],
        const [],
      );
      expect(out, hasLength(1));
      expect(out.first['prenom'], 'Marie');
    });

    test('skips names already in the collection', () {
      final out = contactsToImport(
        [
          {'prenom': 'Marie', 'nom': 'Dupont'},
          {'prenom': 'Jean', 'nom': 'Martin'},
        ],
        [
          {'prenom': 'marie', 'nom': 'dupont'},
        ],
      );
      expect(out, hasLength(1));
      expect(out.first['prenom'], 'Jean');
    });

    test('skips duplicates inside the incoming list', () {
      final out = contactsToImport(
        [
          {'prenom': 'Marie', 'nom': 'Dupont'},
          {'prenom': 'MARIE', 'nom': 'Dupont'},
        ],
        const [],
      );
      expect(out, hasLength(1));
    });
  });

  group('vcardsToVcf', () {
    test('concatenates BEGIN/END blocks', () {
      final vcf = vcardsToVcf([
        {
          'nom': 'Dupont',
          'prenom': 'Marie',
          'email': 'marie@acme.fr',
          'rev': '20261013T000000Z',
        },
        {
          'nom': 'Martin',
          'prenom': 'Jean',
          'rev': '20261013T000000Z',
        },
      ]);
      expect('BEGIN:VCARD'.allMatches(vcf), hasLength(2));
      expect('END:VCARD'.allMatches(vcf), hasLength(2));
      expect(vcf, contains('FN:Marie Dupont'));
      expect(vcf, contains('FN:Jean Martin'));
      expect(vcf, contains('EMAIL;TYPE=INTERNET:marie@acme.fr'));
    });

    test('empty list yields empty document', () {
      expect(vcardsToVcf(const []), isEmpty);
    });
  });
}
