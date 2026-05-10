// Hide drift's `isNull` / `isNotNull` SQL expression builders so we use
// the matcher package versions in `expect(...)` calls.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/data/repositories/vcard_repository.dart';

void main() {
  late QRDatabase db;
  late VCardRepository repo;

  VCardsCompanion sample({
    String nom = 'Dupont',
    String prenom = 'Marie',
    String org = 'Acme',
    String email = 'marie@example.com',
    String telWork = '',
    String adrWork = '',
    String job = '',
    String photo = '',
    bool clone = false,
  }) {
    return VCardsCompanion(
      nom: Value(nom),
      prenom: Value(prenom),
      org: Value(org),
      email: Value(email),
      telWork: Value(telWork),
      adrWork: Value(adrWork),
      job: Value(job),
      photo: Value(photo),
      clone: Value(clone),
    );
  }

  setUp(() {
    db = QRDatabase.forTesting(NativeDatabase.memory());
    repo = VCardRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert returns a positive generated id', () async {
    final id = await repo.insert(sample());
    expect(id, greaterThan(0));
  });

  test('getAllActive returns only non-deleted vcards, newest first',
      () async {
    final id1 = await repo.insert(sample(nom: 'A'));
    final id2 = await repo.insert(sample(nom: 'B'));
    await repo.insert(sample(nom: 'C'));
    await repo.softDelete(id1);

    final result = await repo.getAllActive();
    expect(result.length, 2);
    // Newest first: the C row (highest id) should be at position 0.
    expect(result.first.nom, 'C');
    expect(result.last.id, id2);
  });

  test('getById returns the matching vcard, or null when missing',
      () async {
    final id = await repo.insert(sample());
    final row = await repo.getById(id);
    expect(row, isNotNull);
    expect(row!.nom, 'Dupont');

    final missing = await repo.getById(9999);
    expect(missing, isNull);
  });

  test('findByName matches on nom + prenom', () async {
    await repo.insert(sample(nom: 'A', prenom: 'X'));
    await repo.insert(sample(nom: 'B', prenom: 'Y'));

    final found = await repo.findByName(nom: 'A', prenom: 'X');
    expect(found, isNotNull);
    expect(found!.prenom, 'X');

    final notFound = await repo.findByName(nom: 'A', prenom: 'Z');
    expect(notFound, isNull);
  });

  test('findByName returns null when both args are null', () async {
    final result = await repo.findByName();
    expect(result, isNull);
  });

  test('mergeIfExists fills empty fields, keeps non-empty ones',
      () async {
    await repo.insert(sample(
      nom: 'Martin',
      prenom: 'Jean',
      org: 'OldCo',
      telWork: '',
      job: '',
    ));

    await repo.mergeIfExists(sample(
      nom: 'Martin',
      prenom: 'Jean',
      org: 'NewCo', // should NOT overwrite (existing non-empty)
      telWork: '0600000000', // should fill (existing empty)
      job: 'CTO', // should fill (existing empty)
    ));

    final row = await repo.findByName(nom: 'Martin', prenom: 'Jean');
    expect(row, isNotNull);
    expect(row!.org, 'OldCo'); // preserved
    expect(row.telWork, '0600000000'); // filled
    expect(row.job, 'CTO'); // filled
  });

  test('mergeIfExists is a no-op when no matching record exists',
      () async {
    await repo.mergeIfExists(sample(nom: 'Ghost', prenom: 'X'));
    final rows = await repo.getAllActive();
    expect(rows, isEmpty);
  });

  test('clone creates a new vcard with clone=true and a new id',
      () async {
    final originalId = await repo.insert(sample(nom: 'Original'));
    final cloneId = await repo.clone(originalId);

    expect(cloneId, isNot(equals(originalId)));
    expect(await repo.isClone(originalId), false);
    expect(await repo.isClone(cloneId), true);
  });

  test('softDelete sets deleted=true and dateDeleted', () async {
    final id = await repo.insert(sample());
    final updated = await repo.softDelete(id);
    expect(updated, 1);

    final row = await repo.getById(id);
    expect(row!.deleted, true);
    expect(row.dateDeleted, isNotNull);
    expect(row.dateDeleted, matches(r'^\d{4}-\d{2}-\d{2}$'));
  });

  test('getDeleted returns only soft-deleted rows', () async {
    final id1 = await repo.insert(sample(nom: 'A'));
    await repo.insert(sample(nom: 'B'));
    await repo.softDelete(id1);

    final deleted = await repo.getDeleted();
    expect(deleted.length, 1);
    expect(deleted.first.nom, 'A');
  });

  test('updatePath stores and getPath reads it back', () async {
    final id = await repo.insert(sample());
    await repo.updatePath(id, '/tmp/x.png');
    expect(await repo.getPath(id), '/tmp/x.png');
  });

  test('getLastId returns the highest id, or null when empty',
      () async {
    expect(await repo.getLastId(), isNull);

    await repo.insert(sample(nom: 'A'));
    final id2 = await repo.insert(sample(nom: 'B'));
    expect(await repo.getLastId(), id2);
  });

  test('isClone and isDeleted throw for unknown ids', () async {
    expect(() => repo.isClone(9999), throwsStateError);
    expect(() => repo.isDeleted(9999), throwsStateError);
  });
}
