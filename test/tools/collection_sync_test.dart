import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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

  group('exportFileSlug', () {
    test('uses prenom and nom in lowercase ascii', () {
      expect(
        exportFileSlug({'prenom': 'Marie', 'nom': 'Dupont'}),
        'marie-dupont',
      );
    });

    test('falls back to org then text', () {
      expect(exportFileSlug({'org': 'Acme Corp'}), 'acme-corp');
      expect(exportFileSlug({'text': 'hello world'}), 'hello-world');
    });

    test('strips accents and punctuation', () {
      expect(
        exportFileSlug({'prenom': 'Émilie', 'nom': 'Müller!'}),
        'milie-mller',
      );
    });
  });

  group('buildCollectionZip', () {
    test('contains contacts.vcf, per-card vcf, png, photo and simple txt',
        () async {
      const png = <int>[0x89, 0x50, 0x4E, 0x47];
      final photo = 'data:image/png;base64,${base64Encode(png)}';
      final zipBytes = await buildCollectionZip(
        vcards: [
          {
            'id': 12,
            'nom': 'Dupont',
            'prenom': 'Marie',
            'email': 'marie@acme.fr',
            'photo': photo,
            'path': '/tmp/12.png',
            'rev': '20261013T000000Z',
          },
        ],
        simples: [
          {
            'id': 3,
            'text': 'tzst',
            'path': '/tmp/3.png',
          },
        ],
        readBytes: (path) async {
          return Uint8List.fromList(png);
        },
      );
      expect(zipBytes.length, greaterThan(30));
      final decoded = ZipDecoder().decodeBytes(zipBytes);
      final names = <String>{};
      for (final f in decoded.files) {
        names.add(f.name);
      }
      expect(names, contains('contacts.vcf'));
      expect(names, contains('texts.txt'));
      expect(names, contains('index.txt'));
      expect(names, contains('vcards/12-marie-dupont.vcf'));
      expect(names, contains('vcards/12-marie-dupont.png'));
      expect(names, contains('vcards/12-marie-dupont-photo.png'));
      expect(names, contains('text/3-tzst.txt'));
      expect(names, contains('text/3-tzst.png'));

      ArchiveFile? allVcf;
      ArchiveFile? texts;
      ArchiveFile? simple;
      ArchiveFile? index;
      for (final f in decoded.files) {
        if (f.name == 'contacts.vcf') {
          allVcf = f;
        }
        if (f.name == 'texts.txt') {
          texts = f;
        }
        if (f.name == 'text/3-tzst.txt') {
          simple = f;
        }
        if (f.name == 'index.txt') {
          index = f;
        }
      }
      expect(allVcf, isNotNull);
      expect(
        utf8.decode(allVcf!.content as List<int>),
        contains('Marie Dupont'),
      );
      expect(simple, isNotNull);
      expect(utf8.decode(simple!.content as List<int>), 'tzst');
      expect(texts, isNotNull);
      expect(utf8.decode(texts!.content as List<int>), 'tzst');
      expect(index, isNotNull);
      expect(utf8.decode(index!.content as List<int>), contains('text_qrs: 1'));
    });

    test('zip of only text QRs has no contacts.vcf', () async {
      final zipBytes = await buildCollectionZip(
        vcards: const [],
        simples: [
          {'id': 3, 'text': 'tzst'},
        ],
      );
      final decoded = ZipDecoder().decodeBytes(zipBytes);
      final names = <String>{};
      for (final f in decoded.files) {
        names.add(f.name);
      }
      expect(names, contains('texts.txt'));
      expect(names, contains('text/3-tzst.txt'));
      expect(names, isNot(contains('contacts.vcf')));
    });
  });
}
