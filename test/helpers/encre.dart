import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/app_theme.dart';

/// ENCRE [ThemeData] from the live palette (light or dark).
ThemeData encreTheme() {
  return buildAppTheme(
    colors: currentColors,
    isDark: darkProv.isDarkMode,
  );
}

/// Named routes the floating navbar may push in widget tests.
Map<String, WidgetBuilder> encreTestRoutes() {
  return {
    '/options': (_) => const Scaffold(),
    '/collection': (_) => const Scaffold(),
    '/history': (_) => const Scaffold(),
    '/settings': (_) => const Scaffold(),
  };
}

/// [MaterialApp] wired to ENCRE tokens so component tests see copper, Outfit
/// and the paper surfaces instead of the Flutter starter theme.
Widget encreApp({required Widget home}) {
  return MaterialApp(
    theme: encreTheme(),
    home: home,
    routes: encreTestRoutes(),
  );
}
