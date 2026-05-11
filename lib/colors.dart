import 'package:flutter/material.dart';

/// Discriminator for the available theme palettes.
enum ThemeModeType {
  /// Light theme palette.
  whiteMode,

  /// Dark theme palette.
  blackMode,
}

/// Color palettes used across the app, keyed by [ThemeModeType] and then
/// by semantic role (`bg`, `text`, `popup-*`, `button-color`, ...).
final Map<ThemeModeType, Map<String, Color>> appColorsEnum = {
  ThemeModeType.whiteMode: {
    'popup-text': Colors.black,
    'popup-h1': Colors.black,
    'popup-h2': Colors.black87,
    'popup-background': Colors.white,
    'button-color': Colors.blue,
    'bg': Colors.white,
    'text': Colors.black,
  },
  ThemeModeType.blackMode: {
    'popup-text': Colors.white,
    'popup-h1': Colors.white,
    'popup-h2': Colors.white70,
    'popup-background': Colors.blueGrey,
    'button-color': const Color(0xFF0369A1),
    'bg': Colors.black,
    'text': Colors.white,
  },
};
