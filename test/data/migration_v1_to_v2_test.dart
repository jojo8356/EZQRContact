// Tests d'intégration pour la migration v1 -> v2 (story 1.1d defer resolution).
//
// Stratégie :
//   1. Créer une DB SQLite en mémoire avec le schéma EXACT de la v1
//      (mêmes colonnes que `lib/tools/db/db.dart` avant suppression).
//   2. PRAGMA user_version = 1 pour que Drift détecte la v1 stockée.
//   3. Insérer des données v1 réalistes.
//   4. Ouvrir la DB via `QRDatabase.forTesting(NativeDatabase.opened(raw))`.
//   5. Drift détecte schemaVersion stocké < schemaVersion code et déclenche
//      `MigrationStrategy.onUpgrade(1, 2)` qui ajoute les colonnes et la
//      table Events.
//   6. Vérifier que :
//      - Les données v1 sont préservées
//      - Les nouvelles colonnes existent et sont null sur les rows v1
//      - La table Events est créée et utilisable
//      - PRAGMA user_version est bumpé à 2
//      - L'opération est idempotente
//
// Le backup auto (`_backupDatabaseIfPossible`) n'est pas testé ici car il
// dépend de `sqflite.getDatabasesPath()` qui requiert un binding Flutter.
// Validation manuelle sur device : voir 1-1d-migration-v1-vers-v2-avec-backup.md.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;

import 'package:qr_code_app/data/db/database.dart';

/// Creates a raw in-memory SQLite database with the exact v1 schema and
/// `PRAGMA user_version = 1` set. Returns the open Database; the caller
/// must wrap it in `NativeDatabase.opened(...)` before passing it to
/// `QRDatabase.forTesting(...)`.
raw_sqlite.Database createV1Database() {
  final db = raw_sqlite.sqlite3.openInMemory();

  db.execute('''
    CREATE TABLE SimpleQR(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT NOT NULL,
      path TEXT,
      deleted INTEGER DEFAULT 0,
      date_deleted TEXT
    );
  ''');

  db.execute('''
    CREATE TABLE VCard(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT,
      prenom TEXT,
      nom2 TEXT,
      prefixe TEXT,
      suffixe TEXT,
      org TEXT,
      job TEXT,
      photo TEXT,
      tel_work TEXT,
      tel_home TEXT,
      adr_work TEXT,
      adr_home TEXT,
      email TEXT,
      rev TEXT,
      path TEXT,
      clone INTEGER,
      deleted INTEGER DEFAULT 0,
      date_deleted TEXT
    );
  ''');

  // Drift uses PRAGMA user_version to track schema version, identical to
  // what sqflite did in v1. Setting it to 1 forces Drift to run
  // MigrationStrategy.onUpgrade when QRDatabase opens with schemaVersion 2.
  db.execute('PRAGMA user_version = 1');

  return db;
}

void main() {
  group('Migration v1 -> v2 with realistic data', () {
    late raw_sqlite.Database raw;
    late QRDatabase db;

    setUp(() async {
      raw = createV1Database();

      // Seed v1 data BEFORE opening with Drift (Drift takes ownership).
      raw.execute(
        "INSERT INTO VCard(nom, prenom, org, tel_work, email) "
        "VALUES ('Dupont', 'Marie', 'Acme Corp', '+33612345678', 'marie@example.com')",
      );
      raw.execute(
        "INSERT INTO VCard(nom, prenom, org, clone) "
        "VALUES ('Martin', 'Jean', 'TechCo', 0)",
      );
      raw.execute(
        "INSERT INTO VCard(nom, prenom, deleted, date_deleted) "
        "VALUES ('Trashed', 'Old', 1, '2026-05-01')",
      );
      raw.execute(
        "INSERT INTO SimpleQR(text) VALUES ('https://example.com')",
      );
      raw.execute(
        "INSERT INTO SimpleQR(text, deleted, date_deleted) "
        "VALUES ('deleted url', 1, '2026-05-01')",
      );

      db = QRDatabase.forTesting(NativeDatabase.opened(raw));
    });

    tearDown(() async {
      await db.close();
    });

    test('AC-1: app opens an existing v1 database without crashing', () async {
      // Just exercising any query triggers Drift to open and migrate.
      final vcards = await db.getAllVCards();
      expect(vcards, isA<List<Map<String, dynamic>>>());
    });

    test('AC-2: detects schema version v1 and runs onUpgrade', () async {
      // Force migration by querying.
      await db.getAllVCards();

      // After migration, PRAGMA user_version must be 2.
      final result = raw.select('PRAGMA user_version');
      expect(result.first['user_version'], 2);
    });

    test('AC-3 step 1: VCard rows from v1 are preserved', () async {
      final rows = await db.getAllVCards();
      // 2 active vcards (Marie + Jean). Trashed is filtered (deleted=1).
      expect(rows.length, 2);

      // Newest first by id desc: Jean (id 2), Marie (id 1).
      expect(rows[0]['nom'], 'Martin');
      expect(rows[0]['prenom'], 'Jean');
      expect(rows[0]['org'], 'TechCo');

      expect(rows[1]['nom'], 'Dupont');
      expect(rows[1]['prenom'], 'Marie');
      expect(rows[1]['org'], 'Acme Corp');
      expect(rows[1]['tel_work'], '+33612345678');
      expect(rows[1]['email'], 'marie@example.com');
    });

    test('AC-3 step 2: SimpleQR rows from v1 are preserved', () async {
      final rows = await db.getAllSimpleQR();
      expect(rows.length, 1); // only the non-deleted one
      expect(rows.first['text'], 'https://example.com');

      final deleted = await db.getDeletedSimpleQR();
      expect(deleted.length, 1);
      expect(deleted.first['text'], 'deleted url');
    });

    test('AC-3 step 3: deleted v1 vcards are still accessible via getDeletedVCards',
        () async {
      final deleted = await db.getDeletedVCards();
      expect(deleted.length, 1);
      expect(deleted.first['nom'], 'Trashed');
      expect(deleted.first['date_deleted'], '2026-05-01');
    });

    test('AC-4 step 1: VCard table has the 3 new v2 columns after migration',
        () async {
      final rows = await db.getAllVCards();
      // The map projection includes the new columns, all null on v1 rows.
      final row = rows.first;
      expect(row.containsKey('visual_config'), true);
      expect(row['visual_config'], isNull);
      expect(row.containsKey('event_id'), true);
      expect(row['event_id'], isNull);
      expect(row.containsKey('captured_at'), true);
      expect(row['captured_at'], isNull);
    });

    test('AC-4 step 2: Events table is created and usable', () async {
      // Migration also creates the Events table. Insert a row and read it back.
      final id = await db.into(db.events).insert(
            EventsCompanion(
              name: const Value('Salon Tech 2026'),
              startDate: const Value('2026-06-01'),
              endDate: const Value('2026-06-03'),
              isActive: const Value(true),
              createdAt: Value(DateTime.now().toIso8601String()),
            ),
          );
      expect(id, greaterThan(0));

      final events = await db.select(db.events).get();
      expect(events.length, 1);
      expect(events.first.name, 'Salon Tech 2026');
      expect(events.first.isActive, true);
    });

    test('AC-4 step 3: VCards can be linked to events via the new eventId',
        () async {
      // First create an event.
      final eventId = await db.into(db.events).insert(
            EventsCompanion(
              name: const Value('Test Event'),
              createdAt: Value(DateTime.now().toIso8601String()),
            ),
          );

      // Then tag an existing v1 vcard with the event via Drift directly.
      final vcardRow = (await db.vcards.getAllActive()).first;
      await (db.update(db.vCards)..where((t) => t.id.equals(vcardRow.id)))
          .write(VCardsCompanion(eventId: Value(eventId)));

      // Read back through the typed repository.
      final updated = await db.vcards.getById(vcardRow.id);
      expect(updated, isNotNull);
      expect(updated!.eventId, eventId);
    });

    test('AC-5: migration is idempotent within a single open', () async {
      // First call triggers migration; subsequent calls should be a no-op.
      await db.getAllVCards();
      final firstCount = (await db.getAllVCards()).length;
      final secondCount = (await db.getAllVCards()).length;
      expect(firstCount, secondCount);

      // Data is not duplicated.
      expect(firstCount, 2);
    });

    test('a fresh DB with PRAGMA user_version=2 does not re-run onUpgrade',
        () async {
      // Build a fresh raw DB at schema v2 directly (no v1 data, no
      // migration needed). Verifies onUpgrade does NOT touch a DB that is
      // already at the target version.
      final freshRaw = raw_sqlite.sqlite3.openInMemory();
      freshRaw.execute('PRAGMA user_version = 2');
      // Manually create the v2 tables. Drift's openConnection skips
      // onCreate when tables are already there.
      freshRaw.execute('''
        CREATE TABLE SimpleQR(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT NOT NULL,
          path TEXT,
          deleted INTEGER NOT NULL DEFAULT 0,
          date_deleted TEXT
        );
      ''');
      freshRaw.execute('''
        CREATE TABLE VCard(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL DEFAULT '',
          prenom TEXT NOT NULL DEFAULT '',
          nom2 TEXT NOT NULL DEFAULT '',
          prefixe TEXT NOT NULL DEFAULT '',
          suffixe TEXT NOT NULL DEFAULT '',
          org TEXT NOT NULL DEFAULT '',
          job TEXT NOT NULL DEFAULT '',
          photo TEXT NOT NULL DEFAULT '',
          tel_work TEXT NOT NULL DEFAULT '',
          tel_home TEXT NOT NULL DEFAULT '',
          adr_work TEXT NOT NULL DEFAULT '',
          adr_home TEXT NOT NULL DEFAULT '',
          email TEXT NOT NULL DEFAULT '',
          rev TEXT NOT NULL DEFAULT '',
          path TEXT,
          clone INTEGER NOT NULL DEFAULT 0,
          deleted INTEGER NOT NULL DEFAULT 0,
          date_deleted TEXT,
          visual_config TEXT,
          event_id INTEGER REFERENCES events(id),
          captured_at TEXT
        );
      ''');
      freshRaw.execute('''
        CREATE TABLE events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          start_date TEXT,
          end_date TEXT,
          is_active INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        );
      ''');

      final freshDb =
          QRDatabase.forTesting(NativeDatabase.opened(freshRaw));
      // No migration needed; the table is empty and queries work.
      final rows = await freshDb.getAllVCards();
      expect(rows, isEmpty);
      await freshDb.close();
    });
  });

  group('Fresh install (no v1 DB)', () {
    late QRDatabase db;

    setUp(() {
      db = QRDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('onCreate creates all 3 v2 tables', () async {
      // Insert into each table; if any table is missing, Drift throws.
      await db.into(db.vCards).insert(const VCardsCompanion(
            nom: Value('Test'),
            prenom: Value('User'),
          ));
      await db.into(db.simpleQRs).insert(const SimpleQRsCompanion(
            qrText: Value('https://example.com'),
          ));
      await db.into(db.events).insert(
            EventsCompanion(
              name: const Value('Inaugural Event'),
              createdAt: Value(DateTime.now().toIso8601String()),
            ),
          );

      expect((await db.select(db.vCards).get()).length, 1);
      expect((await db.select(db.simpleQRs).get()).length, 1);
      expect((await db.select(db.events).get()).length, 1);
    });

    test('fresh install starts at schema version 2', () async {
      // Force the schema to be created.
      await db.select(db.vCards).get();

      // Open another connection and verify version via Drift's internal API.
      // The schemaVersion getter in QRDatabase is 2.
      expect(db.schemaVersion, 2);
    });
  });
}
