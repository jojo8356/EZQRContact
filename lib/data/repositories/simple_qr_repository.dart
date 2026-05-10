import 'package:drift/drift.dart';

import 'package:qr_code_app/data/db/database.dart';

/// Type-safe repository for SimpleQR rows in the Drift database. Mirrors
/// the behavior of the legacy `QRDatabase` sqflite layer for simple text
/// QRs (URLs, free text). Story 1.1d will switch the app from the legacy
/// `QRDatabase` to this repository.
class SimpleQRRepository {
  final QRDatabase _db;

  SimpleQRRepository(this._db);

  /// Inserts a new SimpleQR row. The SQL column is named `text`, but on
  /// the Dart side it is exposed as `qrText` to avoid colliding with
  /// `Table.text` (see lib/data/db/tables/simple_qrs.dart). Returns the
  /// generated id.
  Future<int> insert(SimpleQRsCompanion companion) =>
      _db.into(_db.simpleQRs).insert(companion);

  /// Returns all non-deleted SimpleQRs, newest first.
  Future<List<SimpleQRRow>> getAllActive() => (_db.select(_db.simpleQRs)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
        ]))
      .get();

  /// Returns a SimpleQR by id, or null if it does not exist.
  Future<SimpleQRRow?> getById(int id) =>
      (_db.select(_db.simpleQRs)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Soft-deletes a SimpleQR (sets `deleted=true` and `dateDeleted=<today>`).
  /// Returns the number of rows updated.
  Future<int> softDelete(int id) {
    return (_db.update(_db.simpleQRs)..where((t) => t.id.equals(id))).write(
      SimpleQRsCompanion(
        deleted: const Value(true),
        dateDeleted: Value(_today()),
      ),
    );
  }

  /// Updates the `path` field of a SimpleQR.
  Future<int> updatePath(int id, String path) =>
      (_db.update(_db.simpleQRs)..where((t) => t.id.equals(id)))
          .write(SimpleQRsCompanion(path: Value(path)));

  /// Returns the `path` field of a SimpleQR, or null.
  Future<String?> getPath(int id) async {
    final row = await getById(id);
    return row?.path;
  }

  /// Returns all soft-deleted SimpleQRs, most recently deleted first.
  Future<List<SimpleQRRow>> getDeleted() => (_db.select(_db.simpleQRs)
        ..where((t) => t.deleted.equals(true))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.dateDeleted,
                mode: OrderingMode.desc,
              ),
        ]))
      .get();

  /// Returns the `deleted` flag of a SimpleQR. Throws if not found.
  Future<bool> isDeleted(int id) async {
    final row = await getById(id);
    if (row == null) {
      throw StateError('SimpleQR $id not found');
    }
    return row.deleted;
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
