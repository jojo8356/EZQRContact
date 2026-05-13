import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Shows a fullscreen interactive image viewer for the file at [path].
/// No-op when [path] is null/empty or the underlying file is missing.
Future<void> showImageDialog(BuildContext context, String? path) async {
  if (path == null || path.isEmpty) return;
  if (!context.mounted) return;

  // Capture the existence probe once: async (off the UI thread) and stable
  // across rebuilds. Caching avoids re-stat()ing on every parent rebuild and
  // restores the original retry semantics that the synchronous Builder broke.
  // ignore: avoid_slow_async_io
  final existsFuture = File(path).exists();

  unawaited(showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: FutureBuilder<bool>(
          future: existsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data != true) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Icon(Icons.broken_image, size: 64),
                ),
              );
            }

            final semLabel = LangProvider.section('semantics')['qr_image']
                as String?;
            return InteractiveViewer(
              child: Semantics(
                label: semLabel,
                image: true,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: currentColors['bg'],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Image.file(File(path), fit: BoxFit.contain),
                ),
              ),
            );
          },
        ),
      ),
    ),
  ));
}
