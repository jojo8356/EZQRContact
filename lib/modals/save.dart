import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Prompts the user for a filename, then saves [originalPath] as a PNG
/// via the platform file picker. Defaults the name to a timestamp.
Future<void> showSaveDialog(BuildContext context, String originalPath) async {
  final nameController = TextEditingController(
    text: 'QR_${DateTime.now().millisecondsSinceEpoch}',
  );
  String? fileName;
  final lang = LangProvider.section('pages.QR.save');

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang['title'] as String),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: lang['input deco'] as String?,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        cancelButton(context, currentColors),
        ElevatedButton(
          onPressed: () {
            fileName = nameController.text.trim();
            Navigator.pop(context);
          },
          child: Text(lang['button'] as String),
        ),
      ],
    ),
  );

  // Sauvegarder seulement si on a choisi un nom
  if (fileName != null && fileName!.isNotEmpty) {
    unawaited(saveFile(originalPath, fileName!));
  }
}
