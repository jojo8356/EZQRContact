import 'package:drift/drift.dart';
import 'package:qr_code_app/data/db/tables/events.dart';

// `@DataClassName('VCardRow')` avoids a name clash with the existing
// `VCard` class in lib/tools/vcard.dart (the vCard 4.0 format builder
// and parser). The DB row is a `VCardRow`, the contact representation
// for the QR code is still `VCard`.
/// Drift table definition for the `VCard` SQLite table. Holds one row per
/// contact saved as a vCard QR code. Columns named `*_work` / `*_home`
/// are mapped via `Column.named` to keep the v1 sqflite snake_case names.
@DataClassName('VCardRow')
class VCards extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Family name (vCard `N`).
  TextColumn get nom => text().withDefault(const Constant(''))();

  /// Given name (vCard `N`).
  TextColumn get prenom => text().withDefault(const Constant(''))();

  /// Additional name (vCard `N`).
  TextColumn get nom2 => text().withDefault(const Constant(''))();

  /// Honorific prefix (vCard `N`).
  TextColumn get prefixe => text().withDefault(const Constant(''))();

  /// Honorific suffix (vCard `N`).
  TextColumn get suffixe => text().withDefault(const Constant(''))();

  /// Organization name (vCard `ORG`).
  TextColumn get org => text().withDefault(const Constant(''))();

  /// Job title (vCard `TITLE`).
  TextColumn get job => text().withDefault(const Constant(''))();

  /// Photo URL or inline `data:image/...` payload (vCard `PHOTO`).
  TextColumn get photo => text().withDefault(const Constant(''))();

  /// Work phone number.
  TextColumn get telWork =>
      text().withDefault(const Constant('')).named('tel_work')();

  /// Home phone number.
  TextColumn get telHome =>
      text().withDefault(const Constant('')).named('tel_home')();

  /// Work postal address.
  TextColumn get adrWork =>
      text().withDefault(const Constant('')).named('adr_work')();

  /// Home postal address.
  TextColumn get adrHome =>
      text().withDefault(const Constant('')).named('adr_home')();

  /// Primary email address.
  TextColumn get email => text().withDefault(const Constant(''))();

  /// Revision marker (vCard `REV`).
  TextColumn get rev => text().withDefault(const Constant(''))();

  /// Path to the rendered QR PNG on disk, null until generated.
  TextColumn get path => text().nullable()();

  /// True when the row was duplicated from another via "clone".
  BoolColumn get clone => boolean().withDefault(const Constant(false))();

  /// True when the row was soft-deleted by the user.
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  /// ISO-8601 timestamp of soft-deletion, null when active.
  TextColumn get dateDeleted => text().nullable().named('date_deleted')();

  /// JSON blob holding the per-card visual customization (v2+).
  TextColumn get visualConfig =>
      text().nullable().named('visual_config')();

  /// Optional foreign key to the [Events] table (v2+).
  IntColumn get eventId =>
      integer().nullable().named('event_id').references(Events, #id)();

  /// Timestamp of the scan/import that created this row (v2+).
  TextColumn get capturedAt =>
      text().nullable().named('captured_at')();

  @override
  String get tableName => 'VCard'; // Match the v1 sqflite table name
}
