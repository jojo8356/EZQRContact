import 'package:drift/drift.dart';
import 'package:qr_code_app/data/db/database.dart';

/// Repository for event rows. Handles create, activate/deactivate, list.
class EventRepository {
  /// Creates a repository backed by the given database.
  const EventRepository(this._db);

  final QRDatabase _db;

  /// Inserts a new event and returns its id.
  Future<int> create({
    required String name,
    String? startDate,
    String? endDate,
  }) =>
      _db.into(_db.events).insert(
            EventsCompanion.insert(
              name: name,
              startDate: Value(startDate),
              endDate: Value(endDate),
              createdAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );

  /// Returns all events ordered newest-first.
  Future<List<Event>> getAll() =>
      (_db.select(_db.events)
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .get();

  /// Watches all events reactively.
  Stream<List<Event>> watchAll() =>
      (_db.select(_db.events)
            ..orderBy([
              (t) => OrderingTerm.asc(t.isActive),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  /// Returns the currently active event, or null if none.
  Future<Event?> getActive() =>
      (_db.select(_db.events)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();

  /// Activates [id] and deactivates all others in a single transaction.
  Future<void> activate(int id) => _db.transaction(() async {
        await _db.update(_db.events).write(
              const EventsCompanion(isActive: Value(false)),
            );
        await (_db.update(_db.events)..where((t) => t.id.equals(id)))
            .write(const EventsCompanion(isActive: Value(true)));
      });

  /// Deactivates all events.
  Future<void> deactivateAll() => _db.update(_db.events).write(
        const EventsCompanion(isActive: Value(false)),
      );
}
