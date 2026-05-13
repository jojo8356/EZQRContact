import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Minimal TickerProvider that creates standalone tickers — no State needed.
class _StandaloneTickerProvider implements TickerProvider {
  const _StandaloneTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Singleton dark-mode provider.
/// Exposes [themeT] (0.0 = light → 1.0 = dark) animated over
/// [_kDuration] when the mode changes. Notifies on every frame so that
/// [AnimatedBuilder] wrappers repaint with interpolated colors.
class DarkModeProvider extends ChangeNotifier {
  /// Returns the singleton instance.
  factory DarkModeProvider() => _instance;

  DarkModeProvider._internal();
  static final DarkModeProvider _instance = DarkModeProvider._internal();
  static const _kDuration = Duration(milliseconds: 300);

  bool _isDarkMode = false;
  double _themeT = 0; // lerp factor: 0 = light, 1 = dark

  Ticker? _ticker;
  double _animFrom = 0;
  double _animTo = 0;

  /// True when dark mode is currently active.
  bool get isDarkMode => _isDarkMode;

  /// Current lerp factor between light (0.0) and dark (1.0) palettes.
  double get themeT => _themeT;

  /// Flips the active mode and starts the transition animation.
  void toggle() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // immediate notification for isDarkMode consumers
    _startAnimation(_isDarkMode ? 1.0 : 0.0);
  }

  /// Sets dark mode to [value] and starts the transition animation.
  // ignore: avoid_positional_boolean_parameters
  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners(); // immediate notification for isDarkMode consumers
    _startAnimation(_isDarkMode ? 1.0 : 0.0);
  }

  void _startAnimation(double target) {
    _ticker?.stop();
    _ticker?.dispose();
    _animFrom = _themeT;
    _animTo = target;
    _ticker = const _StandaloneTickerProvider().createTicker(_onTick);
    unawaited(_ticker!.start());
  }

  void _onTick(Duration elapsed) {
    final progress = (elapsed.inMicroseconds / _kDuration.inMicroseconds)
        .clamp(0.0, 1.0);
    _themeT = _animFrom + (_animTo - _animFrom) * _easeInOutCubic(progress);
    notifyListeners();
    if (progress >= 1.0) {
      _themeT = _animTo;
      _ticker?.stop();
      _ticker?.dispose();
      _ticker = null;
    }
  }

  /// Instantly snaps the theme to [value] and cancels any in-progress
  /// transition. Intended for test setUp/tearDown only.
  @visibleForTesting
  // ignore: avoid_positional_boolean_parameters — matches the existing setDarkMode signature
  void forceSetDarkMode(bool value) {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _isDarkMode = value;
    _themeT = value ? 1 : 0;
    notifyListeners();
  }

  static double _easeInOutCubic(double t) => t < 0.5
      ? 4 * t * t * t
      : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;
}
