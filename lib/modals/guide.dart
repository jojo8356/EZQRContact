import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showGuidePopup(
  BuildContext context, {
  bool fromButton = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seenGuide') ?? false;
  final lang = PlatformDispatcher.instance.locale.languageCode;

  if (!seen || fromButton) {
    final data = await rootBundle.loadString('assets/GUIDEME.$lang.md');
    if (!context.mounted) return;

    final darkMode = DarkModeProvider();

    showDialog(
      context: context,
      builder: (_) => AnimatedBuilder(
        animation: darkMode,
        builder: (context, _) {
          final isDark = darkMode.isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? Colors.blueGrey : Colors.white,
            actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            content: Markdown(
              data: data,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: isDark ? Colors.white : Colors.black),
                h1: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                h2: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                listBullet: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Fermer",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!fromButton) {
      await prefs.setBool('seenGuide', true);
    }
  }
}
