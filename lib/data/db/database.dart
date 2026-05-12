import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/tables/events.dart';
import 'package:qr_code_app/data/db/tables/simple_qrs.dart';
import 'package:qr_code_app/data/db/tables/vcards.dart';
import 'package:qr_code_app/data/repositories/simple_qr_repository.dart';
import 'package:qr_code_app/data/repositories/vcard_repository.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/perf.dart';
import 'package:qr_code_app/tools/vcard.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

/// Drift-backed database for EZQRContact.
///
/// This class is the single entry point for persistence. It is a singleton
/// (use the factory `QRDatabase()`), keeps the same external API as the
/// legacy sqflite `QRDatabase` class so existing call sites do not break,
/// and exposes the new typed repositories via `db.vcards` and `db.simpleQrs`
/// for new code.
@DriftDatabase(tables: [SimpleQRs, VCards, Events])
class QRDatabase extends _$QRDatabase {

  /// Returns the singleton [QRDatabase] instance backed by sqflite.
  factory QRDatabase() => _instance;

  /// Test-only constructor. Inject any [QueryExecutor] (typically
  /// `NativeDatabase.memory()` from `package:drift/native.dart`).
  // The `matching_super_parameters` lint wants this to mirror the super
  // ctor's `e` param name, but `executor` is the meaningful API contract
  // for callers; keep the descriptive name.
  // ignore: matching_super_parameters
  QRDatabase.forTesting(super.executor);

  QRDatabase._internal()
      : super(
          SqfliteQueryExecutor.inDatabaseFolder(
            path: 'qr_app.db',
            // Explicit even though it's the current default: prevents
            // multiple sqflite handles to qr_app.db across hot-restart
            // and isolates (would surface as "database is locked").
            // ignore: avoid_redundant_argument_values
            singleInstance: true,
          ),
        );
  static final QRDatabase _instance = QRDatabase._internal();

  /// Typed repository for VCard rows.
  late final VCardRepository vcards = VCardRepository(this);

  /// Typed repository for SimpleQR rows.
  late final SimpleQRRepository simpleQrs = SimpleQRRepository(this);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createActiveIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from == 1 && to >= 2) {
            // Backup the v1 database before mutating the schema. If the
            // upgrade fails halfway, the user can restore qr_app.db.backup.
            await _backupDatabaseIfPossible();

            await m.addColumn(vCards, vCards.visualConfig);
            await m.addColumn(vCards, vCards.eventId);
            await m.addColumn(vCards, vCards.capturedAt);
            await m.createTable(events);

            // Normalize legacy NULLs in TEXT columns to empty strings so
            // that the Drift-generated non-null String getters can map
            // them without throwing. In v1 the schema allowed NULL for
            // every TEXT column except SimpleQR.text, and partial inserts
            // (only nom + prenom + tel) were common. We materialize the
            // implicit `e[col] ?? ''` that the legacy `VCard.fromMap` did
            // at read time. Idempotent.
            await customStatement('''
              UPDATE VCard SET
                nom = COALESCE(nom, ''),
                prenom = COALESCE(prenom, ''),
                nom2 = COALESCE(nom2, ''),
                prefixe = COALESCE(prefixe, ''),
                suffixe = COALESCE(suffixe, ''),
                org = COALESCE(org, ''),
                job = COALESCE(job, ''),
                photo = COALESCE(photo, ''),
                tel_work = COALESCE(tel_work, ''),
                tel_home = COALESCE(tel_home, ''),
                adr_work = COALESCE(adr_work, ''),
                adr_home = COALESCE(adr_home, ''),
                email = COALESCE(email, ''),
                rev = COALESCE(rev, ''),
                clone = COALESCE(clone, 0),
                deleted = COALESCE(deleted, 0)
            ''');
          }
          if (from <= 2 && to >= 3) {
            await _createActiveIndexes();
          }
        },
      );

  // Covering indexes for the hot path: WHERE deleted=0 ORDER BY id DESC.
  // IF NOT EXISTS makes this idempotent (safe to call from onCreate too).
  Future<void> _createActiveIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_simple_qr_active'
      ' ON SimpleQR(deleted, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vcard_active'
      ' ON VCard(deleted, id)',
    );
  }

  /// Forces the underlying SQLite connection open so that the first real
  /// query doesn't pay the cold-open penalty (~400 ms). Call once from
  /// main() right after runApp().
  Future<void> warmUp() => customSelect('SELECT 1').get();

  Future<void> _backupDatabaseIfPossible() async {
    try {
      final dbDir = await sqflite.getDatabasesPath();
      final src = File(p.join(dbDir, 'qr_app.db'));
      if (!src.existsSync()) return;
      final dst = File(p.join(dbDir, 'qr_app.db.backup'));
      await src.copy(dst.path);
      if (kDebugMode) {
        debugPrint('[QRDatabase] backup written to ${dst.path}');
      }
      // Catch-all is required: sqflite.getDatabasesPath() throws StateError
      // (a subclass of Error, not Exception) when the platform binding is
      // missing (e.g. unit tests).
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Best-effort backup: tolerate any failure (missing platform binding,
      // permission denied, disk full, etc.) so DB open never throws.
      if (kDebugMode) {
        debugPrint('[QRDatabase] backup failed: $e');
      }
    }
  }

  // -----------------------------------------------------------------------
  // Legacy compat layer.
  //
  // The pre-Drift `QRDatabase` exposed Map<String, dynamic> APIs. The
  // following methods preserve those exact signatures so that pages,
  // components, and modals built before story 1.1d keep working without
  // any change. New code should use `db.vcards` / `db.simpleQrs` instead.
  // -----------------------------------------------------------------------

  /// Inserts a new SimpleQR row and returns its generated id.
  Future<int> insertSimpleQR(String text, String? path) {
    return simpleQrs.insert(SimpleQRsCompanion(
      qrText: Value(text),
      path: path == null ? const Value.absent() : Value(path),
    ));
  }

  /// Inserts a new VCard row from a legacy `Map<String, dynamic>` payload.
  Future<int> insertVCard(Map<String, dynamic> data) {
    final clean = Map<String, dynamic>.from(data)..remove('id');
    return vcards.insert(_mapToVCardCompanion(clean));
  }

  /// Returns all non-deleted SimpleQR rows as legacy maps.
  Future<List<Map<String, dynamic>>> getAllSimpleQR() async {
    Perf.start('db.getAllSimpleQR');
    final rows = await simpleQrs.getAllActive();
    final result = rows.map(_simpleQrToLegacyMap).toList();
    Perf.end('db.getAllSimpleQR');
    return result;
  }

  /// Returns all non-deleted VCard rows as legacy maps.
  Future<List<Map<String, dynamic>>> getAllVCards() async {
    Perf.start('db.getAllVCards');
    final rows = await vcards.getAllActive();
    final result = rows.map(_vcardToLegacyMap).toList();
    Perf.end('db.getAllVCards');
    return result;
  }

  /// Soft-deletes a SimpleQR row by id.
  Future<void> deleteSimpleQR(int id) async {
    await simpleQrs.softDelete(id);
  }

  /// Soft-deletes a VCard row by id.
  Future<void> deleteVCard(int id) async {
    await vcards.softDelete(id);
  }

  /// Returns true when the VCard at [id] is marked as a clone.
  Future<bool> isClone(int id) => vcards.isClone(id);

  /// Updates the file path for a VCard row.
  Future<int> updateVCardPath(int id, String path) =>
      vcards.updatePath(id, path);

  /// Updates the file path for a SimpleQR row.
  Future<void> updateSimpleQRPath(int id, String path) async {
    await simpleQrs.updatePath(id, path);
  }

  /// Returns the on-disk path of the SimpleQR image at [id].
  Future<String?> getPathFromSimpleQR(int id) => simpleQrs.getPath(id);

  /// Returns the on-disk path of the VCard image at [id].
  Future<String?> getPathFromVCard(int id) => vcards.getPath(id);

  /// Returns the VCard row at [id] as a legacy map, or null if missing.
  Future<Map<String, dynamic>?> getVCardById(int id) async {
    final row = await vcards.getById(id);
    return row == null ? null : _vcardToLegacyMap(row);
  }

  /// Looks up an existing VCard by [nom] and/or [prenom].
  Future<Map<String, dynamic>?> verifContact({
    String? nom,
    String? prenom,
  }) async {
    final row = await vcards.findByName(nom: nom, prenom: prenom);
    return row == null ? null : _vcardToLegacyMap(row);
  }

  /// Merges [newContact] fields into an existing VCard row when one matches.
  Future<void> modifContact(Map<String, dynamic> newContact) async {
    await vcards.mergeIfExists(_mapToVCardCompanion(newContact));
  }

  /// Returns the id of the most recently inserted VCard, or 0 if none.
  Future<int?> getLastVCardId() async {
    final id = await vcards.getLastId();
    return id ?? 0;
  }

  /// Duplicates a VCard row and returns the new id.
  Future<int> cloneVCard(int id) async {
    final newId = await vcards.clone(id);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$newId.jpg';
    await vcards.updatePath(newId, path);
    return newId;
  }

  /// Returns all soft-deleted SimpleQR rows as legacy maps.
  Future<List<Map<String, dynamic>>> getDeletedSimpleQR() async {
    final rows = await simpleQrs.getDeleted();
    return rows.map(_simpleQrToLegacyMap).toList();
  }

  /// Returns all soft-deleted VCard rows as legacy maps.
  Future<List<Map<String, dynamic>>> getDeletedVCards() async {
    final rows = await vcards.getDeleted();
    return rows.map(_vcardToLegacyMap).toList();
  }

  /// Returns true when the VCard at [id] is soft-deleted.
  Future<bool> isDeletedVCard(int id) => vcards.isDeleted(id);

  /// Returns true when the SimpleQR at [id] is soft-deleted.
  Future<bool> isDeletedSimpleQR(int id) => simpleQrs.isDeleted(id);
}

// ---------------------------------------------------------------------------
// Map <-> Drift conversions.
// ---------------------------------------------------------------------------

Map<String, dynamic> _vcardToLegacyMap(VCardRow row) => {
      'id': row.id,
      'nom': row.nom,
      'prenom': row.prenom,
      'nom2': row.nom2,
      'prefixe': row.prefixe,
      'suffixe': row.suffixe,
      'org': row.org,
      'job': row.job,
      'photo': row.photo,
      'tel_work': row.telWork,
      'tel_home': row.telHome,
      'adr_work': row.adrWork,
      'adr_home': row.adrHome,
      'email': row.email,
      'rev': row.rev,
      'path': row.path,
      'clone': row.clone ? 1 : 0,
      'deleted': row.deleted ? 1 : 0,
      'date_deleted': row.dateDeleted,
      'visual_config': row.visualConfig,
      'event_id': row.eventId,
      'captured_at': row.capturedAt,
    };

Map<String, dynamic> _simpleQrToLegacyMap(SimpleQRRow row) => {
      'id': row.id,
      'text': row.qrText,
      'path': row.path,
      'deleted': row.deleted ? 1 : 0,
      'date_deleted': row.dateDeleted,
    };

VCardsCompanion _mapToVCardCompanion(Map<String, dynamic> data) {
  Value<String> str(String key) {
    final v = data[key];
    return v == null ? const Value.absent() : Value(v.toString());
  }

  Value<bool> boolFromIntOrString(String key) {
    final v = data[key];
    if (v == null) return const Value.absent();
    if (v is bool) return Value(v);
    if (v is num) return Value(v != 0);
    if (v is String) {
      final n = int.tryParse(v);
      return Value(n != null && n != 0);
    }
    return const Value.absent();
  }

  return VCardsCompanion(
    nom: str('nom'),
    prenom: str('prenom'),
    nom2: str('nom2'),
    prefixe: str('prefixe'),
    suffixe: str('suffixe'),
    org: str('org'),
    job: str('job'),
    photo: str('photo'),
    telWork: str('tel_work'),
    telHome: str('tel_home'),
    adrWork: str('adr_work'),
    adrHome: str('adr_home'),
    email: str('email'),
    rev: str('rev'),
    path: data['path'] == null
        ? const Value.absent()
        : Value(data['path'].toString()),
    clone: boolFromIntOrString('clone'),
    deleted: boolFromIntOrString('deleted'),
    dateDeleted: data['date_deleted'] == null
        ? const Value.absent()
        : Value(data['date_deleted'].toString()),
    visualConfig: str('visual_config'),
  );
}

// ---------------------------------------------------------------------------
// Top-level helpers (kept from the legacy lib/tools/db/db.dart for source
// compatibility).
// ---------------------------------------------------------------------------

/// Soft-deletes a QR or VCard row by [id], dispatching on [isVCard].
Future<void> deleteQR({required bool isVCard, required int id}) async {
  if (isVCard) {
    await QRDatabase().deleteVCard(id);
  } else {
    await QRDatabase().deleteSimpleQR(id);
  }
}

/// Inserts a SimpleQR row, then updates its path to the rendered PNG file.
Future<int> createSimpleQR(String txt) async {
  final db = QRDatabase();
  final id = await db.insertSimpleQR(txt, null);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await db.updateSimpleQRPath(id, path);
  return id;
}

/// Inserts a VCard row from [vcardData], saves the QR image, and links it.
Future<int> createVCard(Map<String, dynamic> vcardData) async {
  final db = QRDatabase();
  vcardData['clone'] = '0';
  final id = await db.insertVCard(vcardData);
  final vcardStr = VCard.fromMap(vcardData).toVCard();
  final path = await saveQrCode(vcardStr, id);
  await db.updateVCardPath(id, path);
  return id;
}

/// Inserts [contacts] in a single DB transaction and generates all QR images
/// in parallel via [compute] isolates. Returns the inserted IDs in order.
///
/// For bulk imports this is dramatically faster than N sequential [createVCard]
/// calls: inserts are batched in one SQLite transaction, PNG encoding runs
/// concurrently across CPU cores, and file writes are parallelised.
///
/// [db] and [baseDir] are injection points for unit tests; production code
/// omits them (defaults to the singleton DB and the app documents directory).
Future<List<int>> createVCardsBatch(
  List<Map<String, dynamic>> contacts, {
  QRDatabase? db,
  String? baseDir,
}) async {
  if (contacts.isEmpty) return [];
  final database = db ?? QRDatabase();

  // One SQLite transaction avoids N separate COMMIT round-trips.
  final ids = await database.transaction(() async {
    final result = <int>[];
    for (final data in contacts) {
      result.add(await database.insertVCard({...data, 'clone': '0'}));
    }
    return result;
  });

  // Pre-compute paths (synchronous, IDs are already known).
  final dir   = baseDir ?? (await getApplicationDocumentsDirectory()).path;
  final paths = [for (final id in ids) '$dir/$id.png'];

  // Generate PNG bytes + write files concurrently. compute() runs each encode
  // in its own isolate, so all CPU cores contribute simultaneously.
  await Future.wait([
    for (var i = 0; i < contacts.length; i++)
      _genQrAndSave(contacts[i], paths[i]),
  ]);

  // One SQLite transaction for all path updates.
  await database.transaction(() async {
    for (var i = 0; i < ids.length; i++) {
      await database.updateVCardPath(ids[i], paths[i]);
    }
  });

  return ids;
}

Future<void> _genQrAndSave(Map<String, dynamic> data, String path) async {
  final bytes = await buildQrBytes(VCard.fromMap(data).toVCard());
  await File(path).writeAsBytes(bytes, flush: true);
}

/// Adds [vcardData] to the device contacts then persists it as a VCard row.
Future<int> createContact(Map<String, dynamic> vcardData) async {
  await PhoneContacts.add(vcardData);
  return createVCard(vcardData);
}

/// Returns true when two VCard maps are equal (excluding the `id` field).
/// Returns false (rather than throwing) when either input is null or not
/// a Map — defensive against legacy `dynamic` callers.
Future<bool> compare2VCard(dynamic vcard1, dynamic vcard2) async {
  if (vcard1 is! Map || vcard2 is! Map) return false;
  final map1 = Map<String, dynamic>.from(vcard1)..remove('id');
  final map2 = Map<String, dynamic>.from(vcard2)..remove('id');
  return _mapDeepEquals(map1, map2);
}

bool _mapDeepEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (a[key] != b[key]) return false;
  }
  return true;
}

/// Returns soft-deleted entries from both SimpleQR and VCard tables, each
/// tagged with a `'type'` key (`'simple'` or `'vcard'`).
///
/// The optional [db] parameter allows injecting a [QRDatabase] instance for
/// testing (e.g. an in-memory DB). When omitted the global singleton is used.
Future<List<Map<String, dynamic>>> getAllDeletedQRs([QRDatabase? db]) async {
  Perf.start('db.getAllDeletedQRs');
  final database = db ?? QRDatabase();
  final deletedSimple = await database.getDeletedSimpleQR();
  final deletedVCard = await database.getDeletedVCards();
  final result = [
    ...deletedSimple.map((e) => {'type': 'simple', 'data': e}),
    ...deletedVCard.map((e) => {'type': 'vcard', 'data': e}),
  ];
  Perf.end('db.getAllDeletedQRs');
  return result;
}

// `getDateDays` was previously imported from tools/tools.dart by the legacy
// db.dart. We keep referring to it via the existing import so callers do
// not need to change. The import above brings it into scope without a
// re-export to avoid pollution; if a caller used to do
// `import 'package:qr_code_app/tools/db/db.dart' show getDateDays;` they
// should now import it directly from `tools/tools.dart`.
