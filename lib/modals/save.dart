import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang.dart';
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
        closeButton(context),
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
