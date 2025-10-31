import 'package:flutter/material.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showSaveDialog(BuildContext context, String originalPath) async {
  final TextEditingController nameController = TextEditingController(
    text: 'QR_${DateTime.now().millisecondsSinceEpoch}',
  );
  String? fileName;
  final lang = LangProvider.get('pages')['QR']['save'];

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang['title']),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: lang['input deco'],
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
          child: Text(lang['button']),
        ),
      ],
    ),
  );

  // Sauvegarder seulement si on a choisi un nom
  if (fileName != null && fileName!.isNotEmpty) {
    saveFile(originalPath, fileName!);
  }
}
