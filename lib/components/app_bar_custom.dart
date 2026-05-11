import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Themed [AppBar] that auto-rebuilds on dark-mode changes via [darkProv].
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a custom app bar showing [title].
  const AppBarCustom(this.title, {super.key});

  /// Title text displayed in the app bar.
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return AppBar(
          backgroundColor: currentColors['bg'],
          foregroundColor: currentColors['text'],
          title: Text(title, style: TextStyle(color: currentColors['text'])),
          iconTheme: IconThemeData(color: currentColors['text']),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
