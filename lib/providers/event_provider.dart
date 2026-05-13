import 'package:flutter/foundation.dart';
import 'package:qr_code_app/data/db/database.dart';

/// Holds the currently active event. Notifies listeners on change.
/// Call [init] once at startup; then use [activeEvent] and [activate]/
/// [deactivate] to manage state.
class EventProvider extends ChangeNotifier {
  /// Returns the singleton instance.
  factory EventProvider() => _instance;

  EventProvider._();
  static final EventProvider _instance = EventProvider._();

  Event? _active;

  /// The currently active event, or null when no event is active.
  Event? get activeEvent => _active;

  /// Loads the active event from the database. Call once at app startup.
  Future<void> init() async {
    _active = await QRDatabase().eventRepo.getActive();
    notifyListeners();
  }

  /// Activates [event] (persists to DB and notifies).
  Future<void> activate(Event event) async {
    await QRDatabase().eventRepo.activate(event.id);
    _active = event;
    notifyListeners();
  }

  /// Deactivates the current event (persists to DB and notifies).
  Future<void> deactivate() async {
    await QRDatabase().eventRepo.deactivateAll();
    _active = null;
    notifyListeners();
  }
}
