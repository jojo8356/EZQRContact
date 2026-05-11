import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';

/// Shows a fullscreen interactive image viewer for the file at [path].
/// No-op when [path] is null/empty or the underlying file is missing.
Future<void> showImageDialog(BuildContext context, String? path) async {
  final darkProv = DarkModeProvider();
  if (path == null || path.isEmpty) return;
  if (!context.mounted) return;

  unawaited(showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Builder(
          builder: (context) {
            if (!File(path).existsSync()) {
              return const Center(child: CircularProgressIndicator());
            }

            return InteractiveViewer(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkProv.isDarkMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    ),
  ));
}
