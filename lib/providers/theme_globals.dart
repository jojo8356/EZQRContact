import 'dart:ui';

import 'package:qr_code_app/colors.dart';
import 'package:qr_code_app/providers/darkmode.dart';

/// Shared [DarkModeProvider] singleton used across the app.
final DarkModeProvider darkProv = DarkModeProvider();

/// Returns the active [ThemeModeType] derived from `darkProv.isDarkMode`.
ThemeModeType get currentTheme =>
    darkProv.isDarkMode ? ThemeModeType.blackMode : ThemeModeType.whiteMode;

/// Returns the color palette of the currently active theme.
Map<String, Color> get currentColors => appColorsEnum[currentTheme]!;
