import 'dart:ui';

import 'package:flutter/material.dart' show Color;
import 'package:qr_code_app/colors.dart';
import 'package:qr_code_app/providers/darkmode.dart';

/// Shared [DarkModeProvider] singleton used across the app.
final DarkModeProvider darkProv = DarkModeProvider();

/// Returns the active [ThemeModeType] derived from `darkProv.isDarkMode`.
ThemeModeType get currentTheme =>
    darkProv.isDarkMode ? ThemeModeType.blackMode : ThemeModeType.whiteMode;

/// Returns a color palette interpolated between light and dark according to
/// [DarkModeProvider.themeT]. During the 300 ms transition every intermediate
/// value is returned; at the endpoints the static palettes are used directly.
Map<String, Color> get currentColors {
  final t = darkProv.themeT;
  if (t <= 0.0) return appColorsEnum[ThemeModeType.whiteMode]!;
  if (t >= 1.0) return appColorsEnum[ThemeModeType.blackMode]!;
  final light = appColorsEnum[ThemeModeType.whiteMode]!;
  final dark = appColorsEnum[ThemeModeType.blackMode]!;
  return {
    for (final key in light.keys) key: Color.lerp(light[key], dark[key], t)!,
  };
}
