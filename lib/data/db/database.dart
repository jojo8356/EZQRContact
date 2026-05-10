import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/tables/events.dart';
import 'package:qr_code_app/data/db/tables/simple_qrs.dart';
import 'package:qr_code_app/data/db/tables/vcards.dart';
import 'package:qr_code_app/data/repositories/simple_qr_repository.dart';
import 'package:qr_code_app/data/repositories/vcard_repository.dart';
import 'package:qr_code_app/tools/contacts.dart';

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
  static final QRDatabase _instance = QRDatabase._internal();

  /// Test-only constructor. Inject any [QueryExecutor] (typically
  /// `NativeDatabase.memory()` from `package:drift/native.dart`).
  QRDatabase.forTesting(super.executor);

  factory QRDatabase() => _instance;

  QRDatabase._internal()
      : super(
          SqfliteQueryExecutor.inDatabaseFolder(
            path: 'qr_app.db',
            singleInstance: true,
          ),
        );

  late final VCardRepository vcards = VCardRepository(this);
  late final SimpleQRRepository simpleQrs = SimpleQRRepository(this);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
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
          }
        },
      );

  Future<void> _backupDatabaseIfPossible() async {
    try {
      final dbDir = await sqflite.getDatabasesPath();
      final src = File(p.join(dbDir, 'qr_app.db'));
      if (!await src.exists()) return;
      final dst = File(p.join(dbDir, 'qr_app.db.backup'));
      await src.copy(dst.path);
      if (kDebugMode) {
        debugPrint('[QRDatabase] backup written to ${dst.path}');
      }
    } catch (e) {
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

  Future<int> insertSimpleQR(String text, String? path) {
    return simpleQrs.insert(SimpleQRsCompanion(
      qrText: Value(text),
      path: path == null ? const Value.absent() : Value(path),
    ));
  }

  Future<int> insertVCard(Map<String, dynamic> data) {
    final clean = Map<String, dynamic>.from(data)..remove('id');
    return vcards.insert(_mapToVCardCompanion(clean));
  }

  Future<List<Map<String, dynamic>>> getAllSimpleQR() async {
    final rows = await simpleQrs.getAllActive();
    return rows.map(_simpleQrToLegacyMap).toList();
  }

  Future<List<Map<String, dynamic>>> getAllVCards() async {
    final rows = await vcards.getAllActive();
    return rows.map(_vcardToLegacyMap).toList();
  }

  Future<void> deleteSimpleQR(int id) async {
    await simpleQrs.softDelete(id);
  }

  Future<void> deleteVCard(int id) async {
    await vcards.softDelete(id);
  }

  Future<bool> isClone(int id) => vcards.isClone(id);

  Future<int> updateVCardPath(int id, String path) =>
      vcards.updatePath(id, path);

  Future<void> updateSimpleQRPath(int id, String path) async {
    await simpleQrs.updatePath(id, path);
  }

  Future<String?> getPathFromSimpleQR(int id) => simpleQrs.getPath(id);

  Future<String?> getPathFromVCard(int id) => vcards.getPath(id);

  Future<Map<String, dynamic>?> getVCardById(int id) async {
    final row = await vcards.getById(id);
    return row == null ? null : _vcardToLegacyMap(row);
  }

  Future<Map<String, dynamic>?> verifContact({
    String? nom,
    String? prenom,
  }) async {
    final row = await vcards.findByName(nom: nom, prenom: prenom);
    return row == null ? null : _vcardToLegacyMap(row);
  }

  Future<void> modifContact(Map<String, dynamic> newContact) async {
    await vcards.mergeIfExists(_mapToVCardCompanion(newContact));
  }

  Future<int?> getLastVCardId() async {
    final id = await vcards.getLastId();
    return id ?? 0;
  }

  Future<int> cloneVCard(int id) async {
    final newId = await vcards.clone(id);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$newId.jpg';
    await vcards.updatePath(newId, path);
    return newId;
  }

  Future<List<Map<String, dynamic>>> getDeletedSimpleQR() async {
    final rows = await simpleQrs.getDeleted();
    return rows.map(_simpleQrToLegacyMap).toList();
  }

  Future<List<Map<String, dynamic>>> getDeletedVCards() async {
    final rows = await vcards.getDeleted();
    return rows.map(_vcardToLegacyMap).toList();
  }

  Future<bool> isDeletedVCard(int id) => vcards.isDeleted(id);

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
  );
}

// ---------------------------------------------------------------------------
// Top-level helpers (kept from the legacy lib/tools/db/db.dart for source
// compatibility).
// ---------------------------------------------------------------------------

Future<void> deleteQR(bool isVCard, int id) async {
  if (isVCard) {
    await QRDatabase().deleteVCard(id);
  } else {
    await QRDatabase().deleteSimpleQR(id);
  }
}

Future<int> createSimpleQR(String txt) async {
  final db = QRDatabase();
  final id = await db.insertSimpleQR(txt, null);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await db.updateSimpleQRPath(id, path);
  return id;
}

Future<int> createVCard(Map<String, dynamic> vcardData) async {
  final db = QRDatabase();
  vcardData['clone'] = '0';
  final id = await db.insertVCard(vcardData);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await saveQrCode(path, id);
  await db.updateVCardPath(id, path);
  return id;
}

Future<int> createContact(Map<String, dynamic> vcardData) async {
  await PhoneContacts.add(vcardData);
  return await createVCard(vcardData);
}

Future<bool> compare2VCard(dynamic vcard1, dynamic vcard2) async {
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

Future<List<Map<String, dynamic>>> getAllDeletedQRs() async {
  final db = QRDatabase();
  final deletedSimple = await db.getDeletedSimpleQR();
  final deletedVCard = await db.getDeletedVCards();
  return [
    ...deletedSimple.map((e) => {'type': 'simple', 'data': e}),
    ...deletedVCard.map((e) => {'type': 'vcard', 'data': e}),
  ];
}

// `getDateDays` was previously imported from tools/tools.dart by the legacy
// db.dart. We keep referring to it via the existing import so callers do
// not need to change. The import above brings it into scope without a
// re-export to avoid pollution; if a caller used to do
// `import 'package:qr_code_app/tools/db/db.dart' show getDateDays;` they
// should now import it directly from `tools/tools.dart`.
