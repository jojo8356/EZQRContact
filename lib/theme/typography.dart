import 'package:flutter/material.dart';

/// Font family names registered in `pubspec.yaml`.
abstract final class AppFonts {
  /// Geometric sans — UI, buttons, body, nav.
  static const String ui = 'Outfit';

  /// Soft optical serif — heroes, names, onboarding titles.
  static const String display = 'Fraunces';
}

/// Builds the ENCRE [TextTheme] against the active [colors] map.
TextTheme buildAppTextTheme(Map<String, Color> colors) {
  final ink = colors['text'] ?? const Color(0xFF1A1612);
  final muted = colors['text-muted'] ?? const Color(0xFF6F675C);

  TextStyle outfit({
    required double size,
    required FontWeight weight,
    double height = 1.25,
    double tracking = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.ui,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking,
      color: color ?? ink,
    );
  }

  TextStyle fraunces({
    required double size,
    required FontWeight weight,
    double height = 1.2,
    double tracking = -0.3,
    FontStyle style = FontStyle.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.display,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: tracking,
      color: color ?? ink,
    );
  }

  return TextTheme(
    displayLarge: fraunces(size: 32, weight: FontWeight.w600, height: 1.15),
    displayMedium: fraunces(size: 28, weight: FontWeight.w600),
    headlineLarge: fraunces(size: 22, weight: FontWeight.w600, height: 1.25),
    headlineMedium: fraunces(size: 20, weight: FontWeight.w600),
    titleLarge: outfit(size: 18, weight: FontWeight.w700, tracking: -0.3),
    titleMedium: outfit(size: 16, weight: FontWeight.w600),
    titleSmall: outfit(
      size: 11,
      weight: FontWeight.w600,
      tracking: 1.4,
      height: 1.2,
      color: muted,
    ),
    bodyLarge: outfit(size: 15, weight: FontWeight.w400, height: 1.45),
    bodyMedium: outfit(size: 14, weight: FontWeight.w400, height: 1.4),
    bodySmall: outfit(
      size: 12,
      weight: FontWeight.w500,
      height: 1.35,
      tracking: 0.2,
      color: muted,
    ),
    labelLarge: outfit(size: 15, weight: FontWeight.w600, tracking: 0.2),
    labelMedium: outfit(size: 12, weight: FontWeight.w600),
    labelSmall: outfit(
      size: 11,
      weight: FontWeight.w600,
      tracking: 0.3,
      height: 1.1,
    ),
  );
}
