import 'package:drift/drift.dart';
import 'package:qr_code_app/data/db/tables/events.dart';

class VCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withDefault(const Constant(''))();
  TextColumn get prenom => text().withDefault(const Constant(''))();
  TextColumn get nom2 => text().withDefault(const Constant(''))();
  TextColumn get prefixe => text().withDefault(const Constant(''))();
  TextColumn get suffixe => text().withDefault(const Constant(''))();
  TextColumn get org => text().withDefault(const Constant(''))();
  TextColumn get job => text().withDefault(const Constant(''))();
  TextColumn get photo => text().withDefault(const Constant(''))();
  TextColumn get telWork =>
      text().withDefault(const Constant('')).named('tel_work')();
  TextColumn get telHome =>
      text().withDefault(const Constant('')).named('tel_home')();
  TextColumn get adrWork =>
      text().withDefault(const Constant('')).named('adr_work')();
  TextColumn get adrHome =>
      text().withDefault(const Constant('')).named('adr_home')();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get rev => text().withDefault(const Constant(''))();
  TextColumn get path => text().nullable()();
  BoolColumn get clone => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get dateDeleted => text().nullable().named('date_deleted')();

  // V2 additions. Story 1.1d will run the migration to add these columns
  // to existing v1 databases. Defined here so the schema is the v2 target
  // from the start.
  TextColumn get visualConfig =>
      text().nullable().named('visual_config')();
  IntColumn get eventId =>
      integer().nullable().named('event_id').references(Events, #id)();
  TextColumn get capturedAt =>
      text().nullable().named('captured_at')();

  @override
  String get tableName => 'VCard'; // Match the v1 sqflite table name
}
