import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showDataDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final cardView = LangProvider.get('pages')['QR']['card view'];
  if (!context.mounted) return;

  final darkMode = DarkModeProvider();
  final bgColor = darkMode.isDarkMode ? Colors.black : Colors.white;
  final textColor = darkMode.isDarkMode ? Colors.white : Colors.black;

  if (isVCard) {
    final controllers = mapToControllers(data);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor, // fond adaptatif
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          cardView['vcard'],
          style: TextStyle(color: textColor), // texte adaptatif
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: VCardView(controllers: controllers),
          ),
        ),
        actions: [closeButton(context)],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor, // fond adaptatif
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        title: Text(
          cardView['simple'],
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor), // texte adaptatif
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              data['text'] ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor), // texte adaptatif
            ),
          ),
        ),
        actions: [closeButton(context)],
      ),
    );
  }
}
