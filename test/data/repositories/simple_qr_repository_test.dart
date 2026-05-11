// Hide drift's `isNull` / `isNotNull` SQL expression builders so we use
// the matcher package versions in `expect(...)` calls.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/data/repositories/simple_qr_repository.dart';

void main() {
  late QRDatabase db;
  late SimpleQRRepository repo;

  SimpleQRsCompanion sample({
    String text = 'https://example.com',
    String? path,
  }) =>
      SimpleQRsCompanion(
        qrText: Value(text),
        path: path == null ? const Value.absent() : Value(path),
      );

  setUp(() {
    db = QRDatabase.forTesting(NativeDatabase.memory());
    repo = SimpleQRRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert returns a positive generated id', () async {
    final id = await repo.insert(sample());
    expect(id, greaterThan(0));
  });

  test('getAllActive returns only non-deleted qrs, newest first',
      () async {
    final id1 = await repo.insert(sample(text: 'A'));
    await repo.insert(sample(text: 'B'));
    await repo.insert(sample(text: 'C'));
    await repo.softDelete(id1);

    final result = await repo.getAllActive();
    expect(result.length, 2);
    expect(result.first.qrText, 'C');
  });

  test('getById returns the matching qr, or null when missing',
      () async {
    final id = await repo.insert(sample(text: 'foo'));
    final row = await repo.getById(id);
    expect(row, isNotNull);
    expect(row!.qrText, 'foo');

    expect(await repo.getById(9999), isNull);
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
    final id1 = await repo.insert(sample(text: 'A'));
    await repo.insert(sample(text: 'B'));
    await repo.softDelete(id1);

    final deleted = await repo.getDeleted();
    expect(deleted.length, 1);
    expect(deleted.first.qrText, 'A');
  });

  test('updatePath stores and getPath reads it back', () async {
    final id = await repo.insert(sample());
    await repo.updatePath(id, '/tmp/x.png');
    expect(await repo.getPath(id), '/tmp/x.png');
  });

  test('isDeleted reflects soft delete state', () async {
    final id = await repo.insert(sample());
    expect(await repo.isDeleted(id), false);
    await repo.softDelete(id);
    expect(await repo.isDeleted(id), true);
  });

  test('isDeleted throws for unknown ids', () async {
    expect(() => repo.isDeleted(9999), throwsStateError);
  });
}
