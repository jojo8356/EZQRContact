import 'package:drift/drift.dart';

/// Drift table definition for the `events` table. Each row groups VCards
/// captured during a specific event (conference, meetup, etc).
class Events extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Human-readable event name.
  TextColumn get name => text()();

  /// ISO-8601 start date, null when the event is open-ended.
  TextColumn get startDate => text().nullable().named('start_date')();

  /// ISO-8601 end date, null when the event is open-ended.
  TextColumn get endDate => text().nullable().named('end_date')();

  /// True for the currently selected/active event used by capture flows.
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false)).named('is_active')();

  /// ISO-8601 timestamp of row creation.
  TextColumn get createdAt => text().named('created_at')();
}
