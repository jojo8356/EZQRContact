import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows the markdown-rendered first-run guide as a dialog. Persists a
/// "seen" flag in SharedPreferences after the first display unless
/// [fromButton] is true (manual re-open from the settings page).
Future<void> showGuidePopup(
  BuildContext context, {
  bool fromButton = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seenGuide') ?? false;
  final lang = PlatformDispatcher.instance.locale.languageCode;

  if (!seen || fromButton) {
    final data = await rootBundle.loadString('assets/GUIDEME.$lang.md');
    if (!context.mounted) return;

    unawaited(showDialog<void>(
      context: context,
      builder: (_) => AnimatedBuilder(
        animation: darkProv,
        builder: (context, _) {
          final theme = Theme.of(context);
          return AlertDialog(
            backgroundColor: currentColors['popup-background'],
            actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            content: Markdown(
              data: data,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyLarge?.copyWith(
                  color: currentColors['popup-text'],
                ),
                h1: theme.textTheme.headlineLarge?.copyWith(
                  color: currentColors['popup-h1'],
                ),
                h2: theme.textTheme.titleLarge?.copyWith(
                  color: currentColors['popup-h2'],
                ),
                listBullet: theme.textTheme.bodyLarge?.copyWith(
                  color: currentColors['popup-text'],
                ),
              ),
            ),
            actions: [cancelButton(context, currentColors)],
          );
        },
      ),
    ));

    if (!fromButton) {
      await prefs.setBool('seenGuide', true);
    }
  }
}
