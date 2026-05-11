import 'package:flutter/material.dart';

/// Singleton DarkMode avec notifier
class DarkModeProvider extends ChangeNotifier {

  /// Returns the singleton instance.
  factory DarkModeProvider() => _instance;

  DarkModeProvider._internal();
  static final DarkModeProvider _instance = DarkModeProvider._internal();
  bool _isDarkMode = false;

  /// True when dark mode is currently active.
  bool get isDarkMode => _isDarkMode;

  /// Flips the active mode and notifies listeners.
  void toggle() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Sets dark mode to [value] and notifies listeners.
  // ignore: avoid_positional_boolean_parameters
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
