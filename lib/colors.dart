import 'package:flutter/material.dart';

/// Discriminator for the available theme palettes.
enum ThemeModeType {
  /// Light theme palette.
  whiteMode,

  /// Dark theme palette.
  blackMode,
}

/// Color palettes used across the app, keyed by [ThemeModeType] and then
/// by semantic role. Values follow Tailwind's zinc/gray/sky scales so the
/// dark palette avoids pure black and the light palette avoids pure black
/// text (both improve legibility and reduce eye strain).
final Map<ThemeModeType, Map<String, Color>> appColorsEnum = {
  ThemeModeType.whiteMode: {
    'bg':               const Color(0xFFFFFFFF), // white
    'surface':          const Color(0xFFF9FAFB), // gray-50  — cards, inputs
    'text':             const Color(0xFF111827), // gray-900
    'text-muted':       const Color(0xFF6B7280), // gray-500 — subtitles
    'button-color':     const Color(0xFF2563EB), // blue-600
    'popup-background': const Color(0xFFFFFFFF), // white
    'popup-text':       const Color(0xFF111827), // gray-900
    'popup-h1':         const Color(0xFF111827), // gray-900
    'popup-h2':         const Color(0xFF4B5563), // gray-600
  },
  ThemeModeType.blackMode: {
    'bg':               const Color(0xFF09090B), // zinc-950 — near-black
    'surface':          const Color(0xFF18181B), // zinc-900 — cards, inputs
    'text':             const Color(0xFFF4F4F5), // zinc-100
    'text-muted':       const Color(0xFFA1A1AA), // zinc-400 — subtitles
    'button-color':     const Color(0xFF0EA5E9), // sky-500  — visible on dark
    'popup-background': const Color(0xFF27272A), // zinc-800
    'popup-text':       const Color(0xFFF4F4F5), // zinc-100
    'popup-h1':         const Color(0xFFFAFAFA), // zinc-50
    'popup-h2':         const Color(0xFFA1A1AA), // zinc-400
  },
};
