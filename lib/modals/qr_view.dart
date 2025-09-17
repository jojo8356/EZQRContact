import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';

Future<void> showImageDialog(BuildContext context, String? path) async {
  final darkMode = DarkModeProvider();
  if (path == null || path.isEmpty) return;
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: FutureBuilder<bool>(
          future: File(path).exists(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const Center(child: CircularProgressIndicator());
            }

            return InteractiveViewer(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkMode.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    ),
  );
}
