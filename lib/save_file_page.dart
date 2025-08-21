import 'package:flutter/material.dart';
import 'package:qr_code_app/tools.dart';

Future<void> showSaveDialog(BuildContext context, String originalPath) async {
  final TextEditingController nameController = TextEditingController(
    text: 'QR_${DateTime.now().millisecondsSinceEpoch}',
  );
  String? fileName;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Save QR Code"),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: "File name",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            fileName = nameController.text.trim();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
  saveFile(originalPath, fileName!);
}
