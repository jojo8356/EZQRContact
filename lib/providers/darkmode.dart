import 'package:flutter/material.dart';

/// Singleton DarkMode avec notifier
class DarkModeProvider extends ChangeNotifier {
  static final DarkModeProvider _instance = DarkModeProvider._internal();
  bool _isDarkMode = false;

  DarkModeProvider._internal();

  factory DarkModeProvider() => _instance;

  bool get isDarkMode => _isDarkMode;

  void toggle() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // 🔥 notifie Flutter
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners(); // 🔥 notifie Flutter
  }
}
