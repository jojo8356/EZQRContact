import 'package:drift/drift.dart';

class SimpleQRs extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Dart side uses `qrText` to avoid colliding with the Drift `Table.text`
  // builder method. SQL column name is kept as `text` to match v1 schema.
  TextColumn get qrText => text().named('text')();

  TextColumn get path => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get dateDeleted => text().nullable().named('date_deleted')();

  @override
  String get tableName => 'SimpleQR'; // Match the v1 sqflite table name
}

