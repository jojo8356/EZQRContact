import 'package:drift/drift.dart';

import 'package:qr_code_app/data/db/database.dart';

/// Type-safe repository for VCard rows in the Drift database. Mirrors the
/// behavior of the legacy `QRDatabase` sqflite layer (`lib/tools/db/db.dart`)
/// while exposing a typed Drift API. Story 1.1d will switch the app from
/// the legacy `QRDatabase` to this repository.
class VCardRepository {

  /// Creates a repository bound to [_db].
  VCardRepository(this._db);
  final QRDatabase _db;

  /// Inserts a new VCard row. Returns the auto-generated id.
  Future<int> insert(VCardsCompanion companion) =>
      _db.into(_db.vCards).insert(companion);

  /// Returns all non-deleted VCards, newest first.
  Future<List<VCardRow>> getAllActive() => (_db.select(_db.vCards)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
        ]))
      .get();

  /// Watches all non-deleted VCards, newest first. Emits on every DB change.
  Stream<List<VCardRow>> watchActive() => (_db.select(_db.vCards)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
        ]))
      .watch();

  /// Watches non-deleted VCards whose nom or prenom contains [query]
  /// (case-insensitive LIKE). Used for debounced name search (story 4-6).
  Stream<List<VCardRow>> watchSearch(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.vCards)
          ..where(
            (t) =>
                t.deleted.equals(false) &
                (t.nom.like(pattern) | t.prenom.like(pattern)),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Watches non-deleted VCards linked to [eventId]. Used by the event filter
  /// in the collection view (story 4-5).
  Stream<List<VCardRow>> watchByEvent(int eventId) =>
      (_db.select(_db.vCards)
            ..where(
              (t) =>
                  t.deleted.equals(false) & t.eventId.equals(eventId),
            )
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ]))
          .watch();

  /// Returns a VCard by id, or null if it does not exist.
  Future<VCardRow?> getById(int id) =>
      (_db.select(_db.vCards)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Finds a VCard by [nom] and/or [prenom]. Returns null if no match. If
  /// both are null, returns null. Matches the legacy `verifContact` semantics.
  Future<VCardRow?> findByName({String? nom, String? prenom}) async {
    if (nom == null && prenom == null) return null;
    final query = _db.select(_db.vCards);
    if (nom != null && prenom != null) {
      query.where((t) => t.nom.equals(nom) & t.prenom.equals(prenom));
    } else if (nom != null) {
      query.where((t) => t.nom.equals(nom));
    } else {
      query.where((t) => t.prenom.equals(prenom!));
    }
    return query.getSingleOrNull();
  }

  /// Merges [newData] into an existing VCard sharing nom/prenom. Only
  /// fills the existing record's empty fields, never overwriting non-empty
  /// values. Matches the legacy `modifContact` semantics.
  /// [newData] must include `nom` and `prenom`.
  Future<void> mergeIfExists(VCardsCompanion newData) async {
    if (!newData.nom.present || !newData.prenom.present) {
      throw ArgumentError('mergeIfExists requires nom and prenom');
    }
    final existing = await findByName(
      nom: newData.nom.value,
      prenom: newData.prenom.value,
    );
    if (existing == null) return;

    final merged = existing.copyWith(
      nom2: _pickEmpty(existing.nom2, newData.nom2),
      prefixe: _pickEmpty(existing.prefixe, newData.prefixe),
      suffixe: _pickEmpty(existing.suffixe, newData.suffixe),
      org: _pickEmpty(existing.org, newData.org),
      job: _pickEmpty(existing.job, newData.job),
      photo: _pickEmpty(existing.photo, newData.photo),
      telWork: _pickEmpty(existing.telWork, newData.telWork),
      telHome: _pickEmpty(existing.telHome, newData.telHome),
      adrWork: _pickEmpty(existing.adrWork, newData.adrWork),
      adrHome: _pickEmpty(existing.adrHome, newData.adrHome),
      email: _pickEmpty(existing.email, newData.email),
      rev: _pickEmpty(existing.rev, newData.rev),
    );

    await (_db.update(_db.vCards)..where((t) => t.id.equals(existing.id)))
        .write(merged.toCompanion(true));
  }

  /// Returns [newValue].value when [oldValue] is empty and [newValue] is
  /// present and non-empty, otherwise keeps [oldValue]. Used by
  /// [mergeIfExists].
  String _pickEmpty(String oldValue, Value<String> newValue) {
    if (oldValue.isNotEmpty) return oldValue;
    if (!newValue.present) return oldValue;
    final candidate = newValue.value;
    return candidate.isEmpty ? oldValue : candidate;
  }

  /// Clones a VCard. The new row has `clone=true` and a fresh id. Returns
  /// the new id. Throws if the source id does not exist.
  Future<int> clone(int id) async {
    final source = await getById(id);
    if (source == null) {
      throw StateError('VCard $id not found');
    }
    final companion = source.toCompanion(true).copyWith(
          id: const Value.absent(), // let AUTOINCREMENT assign a new id
          clone: const Value(true),
        );
    return _db.into(_db.vCards).insert(companion);
  }

  /// Soft-deletes a VCard (sets `deleted=true` and `dateDeleted=<today>`).
  /// Returns the number of rows updated (1 if found, 0 otherwise).
  Future<int> softDelete(int id) {
    return (_db.update(_db.vCards)..where((t) => t.id.equals(id))).write(
      VCardsCompanion(
        deleted: const Value(true),
        dateDeleted: Value(_today()),
      ),
    );
  }

  /// Returns the `clone` flag of a VCard. Throws if not found.
  Future<bool> isClone(int id) async {
    final row = await getById(id);
    if (row == null) {
      throw StateError('VCard $id not found');
    }
    return row.clone;
  }

  /// Updates the `path` field of a VCard. Returns the number of rows updated.
  Future<int> updatePath(int id, String path) =>
      (_db.update(_db.vCards)..where((t) => t.id.equals(id)))
          .write(VCardsCompanion(path: Value(path)));

  /// Returns the `path` field of a VCard or null if the row does not exist
  /// or path is null.
  Future<String?> getPath(int id) async {
    final row = await getById(id);
    return row?.path;
  }

  /// Returns all soft-deleted VCards, most recently deleted first.
  Future<List<VCardRow>> getDeleted() => (_db.select(_db.vCards)
        ..where((t) => t.deleted.equals(true))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.dateDeleted,
                mode: OrderingMode.desc,
              ),
        ]))
      .get();

  /// Returns the `deleted` flag of a VCard. Throws if not found.
  Future<bool> isDeleted(int id) async {
    final row = await getById(id);
    if (row == null) {
      throw StateError('VCard $id not found');
    }
    return row.deleted;
  }

  /// Returns the highest VCard id, or null if the table is empty.
  Future<int?> getLastId() async {
    final row = await (_db.select(_db.vCards)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  /// Today as an ISO 8601 date string `YYYY-MM-DD` (matches the legacy
  /// `getDateDays()` in `lib/tools/tools.dart`).
  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
