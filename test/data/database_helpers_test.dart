import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/data/db/database.dart';

void main() {
  group('getAllDeletedQRs', () {
    late QRDatabase db;

    setUp(() {
      db = QRDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('empty DB returns empty list', () async {
      final result = await getAllDeletedQRs(db);
      expect(result, isEmpty);
    });

    test('one soft-deleted SimpleQR appears with type simple and correct text',
        () async {
      final id = await db.insertSimpleQR('hello world', null);
      await db.deleteSimpleQR(id);

      final result = await getAllDeletedQRs(db);
      expect(result.length, equals(1));
      expect(result.first['type'], equals('simple'));
      expect(
        (result.first['data'] as Map<String, dynamic>)['text'],
        equals('hello world'),
      );
    });

    test('one soft-deleted VCard appears with type vcard and correct nom',
        () async {
      final id = await db.insertVCard({'nom': 'Dupont', 'prenom': 'Marie'});
      await db.deleteVCard(id);

      final result = await getAllDeletedQRs(db);
      expect(result.length, equals(1));
      expect(result.first['type'], equals('vcard'));
      expect(
        (result.first['data'] as Map<String, dynamic>)['nom'],
        equals('Dupont'),
      );
    });

    test('mixed: simple then vcard — 2 entries, simples before vcards',
        () async {
      final simpleId = await db.insertSimpleQR('qr text', null);
      await db.deleteSimpleQR(simpleId);

      final vcardId =
          await db.insertVCard({'nom': 'Martin', 'prenom': 'Jean'});
      await db.deleteVCard(vcardId);

      final result = await getAllDeletedQRs(db);
      expect(result.length, equals(2));
      expect(result[0]['type'], equals('simple'));
      expect(result[1]['type'], equals('vcard'));
    });

    test('active (non-deleted) entries are excluded', () async {
      // Insert active records (not deleted).
      await db.insertSimpleQR('active qr', null);
      await db.insertVCard({'nom': 'Active', 'prenom': 'User'});

      final result = await getAllDeletedQRs(db);
      expect(result, isEmpty);
    });
  });

  group('compare2VCard', () {
    test('equal maps return true', () async {
      final a = {'nom': 'Dupont', 'prenom': 'Marie', 'email': 'a@b.com'};
      final b = {'nom': 'Dupont', 'prenom': 'Marie', 'email': 'a@b.com'};
      expect(await compare2VCard(a, b), isTrue);
    });

    test('equal maps with different id return true (id is ignored)', () async {
      final a = {'id': 1, 'nom': 'Dupont', 'prenom': 'Marie'};
      final b = {'id': 99, 'nom': 'Dupont', 'prenom': 'Marie'};
      expect(await compare2VCard(a, b), isTrue);
    });

    test('maps differing in one field return false', () async {
      final a = {'nom': 'Dupont', 'prenom': 'Marie'};
      final b = {'nom': 'Martin', 'prenom': 'Marie'};
      expect(await compare2VCard(a, b), isFalse);
    });

    test('first arg is not a Map returns false', () async {
      expect(await compare2VCard('not-a-map', {'nom': 'x'}), isFalse);
    });

    test('second arg is not a Map returns false', () async {
      expect(await compare2VCard({'nom': 'x'}, 42), isFalse);
    });

    test('both null returns false', () async {
      expect(await compare2VCard(null, null), isFalse);
    });

    test('empty maps are equal', () async {
      expect(await compare2VCard(<String, dynamic>{}, <String, dynamic>{}),
          isTrue);
    });
  });
}
