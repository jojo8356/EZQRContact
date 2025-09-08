import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showGuidePopup(context) async {
  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seenGuide') ?? false;

  if (!seen) {
    final data = await rootBundle.loadString('assets/GUIDEME.md');
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        content: Markdown(data: data, shrinkWrap: true),
        actions: [closeButton(context)],
      ),
    );

    await prefs.setBool('seenGuide', true);
  }
}
