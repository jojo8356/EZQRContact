import 'package:drift/drift.dart';

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get startDate => text().nullable().named('start_date')();
  TextColumn get endDate => text().nullable().named('end_date')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false)).named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
}
