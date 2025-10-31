import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarCustom(this.title, {super.key});

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
