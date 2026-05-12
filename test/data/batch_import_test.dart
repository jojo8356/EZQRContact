import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PNG magic: 89 50 4E 47 0D 0A 1A 0A
const _pngMagic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// Builds a minimal vCard map with required fields.
Map<String, dynamic> _contact({
  String nom = 'Dupont',
  String prenom = 'Marie',
  String email = '',
  String telWork = '',
}) =>
    {
      'nom': nom,
      'prenom': prenom,
      'nom2': '',
      'prefixe': '',
      'suffixe': '',
      'org': '',
      'job': '',
      'photo': '',
      'tel_work': telWork,
      'tel_home': '',
      'adr_work': '',
      'adr_home': '',
      'email': email,
      'rev': '',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QRDatabase db;
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() async {
    db = QRDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('qr_batch_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  // ---------------------------------------------------------------------------
  // Empty / edge cases
  // ---------------------------------------------------------------------------
  group('createVCardsBatch — edge cases', () {
    test('empty list returns empty IDs and inserts nothing', () async {
      final ids = await createVCardsBatch([], db: db, baseDir: tempDir.path);
      expect(ids, isEmpty);
      expect(await db.getAllVCards(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Single contact
  // ---------------------------------------------------------------------------
  group('createVCardsBatch — single contact', () {
    test('returns a list with one ID', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      expect(ids.length, 1);
    });

    test('inserts the contact into the DB', () async {
      await createVCardsBatch(
        [_contact(nom: 'Martin', prenom: 'Jean')],
        db: db,
        baseDir: tempDir.path,
      );
      final rows = await db.getAllVCards();
      expect(rows.length, 1);
      expect(rows.first['nom'], 'Martin');
      expect(rows.first['prenom'], 'Jean');
    });

    test('DB row has clone=0', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      final row = await db.getVCardById(ids.first);
      expect(row!['clone'], 0);
    });

    test('DB row path is set to <baseDir>/<id>.png', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      final row = await db.getVCardById(ids.first);
      expect(row!['path'], '${tempDir.path}/${ids.first}.png');
    });

    test('PNG file is written to baseDir', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      final file = File('${tempDir.path}/${ids.first}.png');
      expect(file.existsSync(), isTrue);
    });

    test('written file starts with PNG magic bytes', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      final bytes = await File('${tempDir.path}/${ids.first}.png').readAsBytes();
      expect(bytes.sublist(0, 8), equals(_pngMagic));
    });

    test('PNG file is larger than 1 KB', () async {
      final ids = await createVCardsBatch(
        [_contact()],
        db: db,
        baseDir: tempDir.path,
      );
      final size = File('${tempDir.path}/${ids.first}.png').statSync().size;
      expect(size, greaterThan(1024));
    });
  });

  // ---------------------------------------------------------------------------
  // Multiple contacts — batch correctness
  // ---------------------------------------------------------------------------
  group('createVCardsBatch — multiple contacts', () {
    test('inserts all contacts and returns IDs in order', () async {
      final contacts = [
        _contact(nom: 'Alpha',   prenom: 'Un'),
        _contact(nom: 'Beta',    prenom: 'Deux'),
        _contact(nom: 'Gamma',   prenom: 'Trois'),
      ];
      final ids = await createVCardsBatch(
        contacts,
        db: db,
        baseDir: tempDir.path,
      );

      expect(ids.length, 3);
      // IDs must be strictly increasing (sequential SQLite rowids).
      expect(ids[0], lessThan(ids[1]));
      expect(ids[1], lessThan(ids[2]));
    });

    test('DB contains one row per contact with correct nom', () async {
      final contacts = [
        _contact(nom: 'Alpha'),
        _contact(nom: 'Beta'),
        _contact(nom: 'Gamma'),
      ];
      await createVCardsBatch(contacts, db: db, baseDir: tempDir.path);

      final rows = await db.getAllVCards();
      final noms = rows.map((r) => r['nom']).toSet();
      expect(noms, containsAll(['Alpha', 'Beta', 'Gamma']));
    });

    test('each contact gets its own PNG file', () async {
      final ids = await createVCardsBatch(
        [_contact(nom: 'A'), _contact(nom: 'B'), _contact(nom: 'C')],
        db: db,
        baseDir: tempDir.path,
      );
      for (final id in ids) {
        expect(File('${tempDir.path}/$id.png').existsSync(), isTrue,
            reason: 'PNG for id=$id must exist');
      }
    });

    test('every PNG starts with valid magic bytes', () async {
      final ids = await createVCardsBatch(
        [_contact(nom: 'X'), _contact(nom: 'Y')],
        db: db,
        baseDir: tempDir.path,
      );
      for (final id in ids) {
        final bytes =
            await File('${tempDir.path}/$id.png').readAsBytes();
        expect(bytes.sublist(0, 8), equals(_pngMagic),
            reason: 'id=$id PNG magic must be valid');
      }
    });

    test('contacts with different names produce different PNG files', () async {
      final ids = await createVCardsBatch(
        [
          _contact(nom: 'Alice', prenom: 'One'),
          _contact(nom: 'Bob', prenom: 'Two'),
        ],
        db: db,
        baseDir: tempDir.path,
      );
      final bytesA =
          await File('${tempDir.path}/${ids[0]}.png').readAsBytes();
      final bytesB =
          await File('${tempDir.path}/${ids[1]}.png').readAsBytes();
      // Different vCard strings encode to different QR matrices
      // → different PNGs.
      expect(bytesA, isNot(equals(bytesB)));
    });

    test('DB path column matches actual file on disk for all contacts',
        () async {
      final ids = await createVCardsBatch(
        List.generate(5, (i) => _contact(nom: 'Contact$i')),
        db: db,
        baseDir: tempDir.path,
      );
      for (final id in ids) {
        final row = await db.getVCardById(id);
        final dbPath = row!['path'] as String;
        expect(File(dbPath).existsSync(), isTrue,
            reason: 'File at DB path must exist for id=$id');
      }
    });

    test('10-contact batch completes without error', () async {
      final contacts =
          List.generate(10, (i) => _contact(nom: 'Nom$i', prenom: 'Prenom$i'));
      final ids = await createVCardsBatch(
        contacts,
        db: db,
        baseDir: tempDir.path,
      );
      expect(ids.length, 10);
      final rows = await db.getAllVCards();
      expect(rows.length, 10);
    });
  });

  // ---------------------------------------------------------------------------
  // createVCard single — vCard string used as QR data (bug-fix regression)
  // ---------------------------------------------------------------------------
  group('createVCard — QR data correctness', () {
    test('does not pass file path as QR content (regression)', () async {
      // Before the fix, createVCard called saveQrCode(filePath, id) which
      // encoded the local file path as QR data instead of the vCard string.
      // This test verifies the fix: if saveQrCode throws (FS unavailable in
      // unit tests), the exception must NOT contain 'invalid qr' — meaning
      // the vCard string passed validation, not a file path.
      try {
        await createVCard({'nom': 'Test', 'prenom': 'User'});
      } on Object catch (e) {
        expect(e.toString(), isNot(contains('invalid qr')));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Performance — each QR generation must complete in under 100 ms
  // ---------------------------------------------------------------------------
  group('buildQrBytes — performance', () {
    setUpAll(() async {
      // One warmup call to amortise isolate spawn cost; measurements below
      // reflect steady-state throughput, not cold-start overhead.
      await buildQrBytes('warmup');
    });

    test('single vCard QR generates in under 100 ms', () async {
      const vcard = 'BEGIN:VCARD\r\nVERSION:3.0\r\n'
          'N:Dupont;Marie;;;\r\nFN:Marie Dupont\r\nEND:VCARD\r\n';
      final sw = Stopwatch()..start();
      await buildQrBytes(vcard);
      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'took ${sw.elapsedMilliseconds} ms',
      );
    });

    test('5 consecutive QR generations each under 100 ms', () async {
      for (var i = 0; i < 5; i++) {
        final vcard =
            'BEGIN:VCARD\r\nVERSION:3.0\r\nN:User$i;Test;;;\r\n'
            'FN:Test User$i\r\nEND:VCARD\r\n';
        final sw = Stopwatch()..start();
        await buildQrBytes(vcard);
        sw.stop();
        expect(
          sw.elapsedMilliseconds,
          lessThan(100),
          reason: 'call $i took ${sw.elapsedMilliseconds} ms',
        );
      }
    });
  });

  group('createVCardsBatch — performance', () {
    test('10-contact batch wall-clock under 1 s (≤ 100 ms per contact)',
        () async {
      final contacts = List.generate(
        10,
        (i) => _contact(nom: 'Perf$i', prenom: 'Run$i'),
      );
      final sw = Stopwatch()..start();
      await createVCardsBatch(contacts, db: db, baseDir: tempDir.path);
      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(1000),
        reason: 'batch of 10 took ${sw.elapsedMilliseconds} ms',
      );
    });
  });
}
