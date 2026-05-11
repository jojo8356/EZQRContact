import 'package:drift/drift.dart';

/// Drift table definition for the `SimpleQR` SQLite table. Holds plain-text
/// QR codes (URLs, free text) that aren't structured contacts.
@DataClassName('SimpleQRRow')
class SimpleQRs extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Encoded QR payload. Dart uses `qrText` to avoid colliding with the
  /// Drift `Table.text` builder method; the SQL column stays `text`.
  TextColumn get qrText => text().named('text')();

  /// Path to the rendered QR PNG on disk, null until generated.
  TextColumn get path => text().nullable()();

  /// True when the row was soft-deleted by the user.
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  /// ISO-8601 timestamp of soft-deletion, null when active.
  TextColumn get dateDeleted => text().nullable().named('date_deleted')();

  @override
  String get tableName => 'SimpleQR'; // Match the v1 sqflite table name
}
