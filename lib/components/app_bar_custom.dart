import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarCustom(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        final isDark = darkMode.isDarkMode;
        return AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          title: Text(
            title,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
