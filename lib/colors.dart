import 'package:flutter/material.dart';

/// Discriminator for the available theme palettes.
enum ThemeModeType {
  /// Light theme palette — warm paper.
  whiteMode,

  /// Dark theme palette — warm night ink.
  blackMode,
}

/// ENCRE palettes, keyed by [ThemeModeType] then by semantic role.
///
/// Names and hex values are specified in
/// `docs/direction-artistique.md` §7.2 / §8.1.
///
/// Legacy keys (`bg`, `surface`, `text`, `text-muted`, `button-color`,
/// `popup-*`) are preserved so existing call sites keep compiling.
final Map<ThemeModeType, Map<String, Color>> appColorsEnum = {
  ThemeModeType.whiteMode: const {
    'bg': Color(0xFFF4EFE6), // Papier
    'surface': Color(0xFFFFFCF7), // Carte
    'surface-raised': Color(0xFFEBE4D8), // Sable
    'text': Color(0xFF1A1612), // Encre
    'text-muted': Color(0xFF6F675C), // Cendre
    'button-color': Color(0xFFC45C26), // Cuivre
    'on-button': Color(0xFFFFF8F0),
    'navy': Color(0xFF1F3D4D), // Marine
    'border': Color(0xFFDDD4C6), // Ligne
    'success': Color(0xFF3D6B4F),
    'danger': Color(0xFFB42318),
    'popup-background': Color(0xFFFFFCF7),
    'popup-text': Color(0xFF1A1612),
    'popup-h1': Color(0xFF1A1612),
    'popup-h2': Color(0xFF1F3D4D),
    'shadow': Color(0xFF1A1612),
  },
  ThemeModeType.blackMode: const {
    'bg': Color(0xFF141210), // Nuit
    'surface': Color(0xFF1E1B18), // Carte nuit
    'surface-raised': Color(0xFF2A2622),
    'text': Color(0xFFF3EDE4), // Ivoire
    'text-muted': Color(0xFFA89F93),
    'button-color': Color(0xFFE07A3D), // Cuivre nuit
    'on-button': Color(0xFF1A1612),
    'navy': Color(0xFF8BB8C9),
    'border': Color(0xFF3A342E),
    'success': Color(0xFF7BC49A),
    'danger': Color(0xFFF97066),
    'popup-background': Color(0xFF1E1B18),
    'popup-text': Color(0xFFF3EDE4),
    'popup-h1': Color(0xFFF3EDE4),
    'popup-h2': Color(0xFF8BB8C9),
    'shadow': Color(0xFF000000),
  },
};
