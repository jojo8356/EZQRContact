import 'dart:io';
import 'package:flutter/material.dart';

Future<void> showImageDialog(BuildContext context, String? path) async {
  if (path == null || path.isEmpty) return;

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: InteractiveViewer(
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
