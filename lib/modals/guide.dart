import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
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

    showDialog(
      context: context,
      builder: (_) => AnimatedBuilder(
        animation: darkProv,
        builder: (context, _) {
          return AlertDialog(
            backgroundColor: currentColors['popup-background'],
            actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            content: Markdown(
              data: data,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: currentColors['popup-text']),
                h1: TextStyle(
                  color: currentColors['popup-h1'],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                h2: TextStyle(
                  color: currentColors['popup-h2'],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                listBullet: TextStyle(color: currentColors['popup-text']),
              ),
            ),
            actions: [cancelButton(context, currentColors)],
          );
        },
      ),
    );

    if (!fromButton) {
      await prefs.setBool('seenGuide', true);
    }
  }
}
