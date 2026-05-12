import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Opens a dialog showing the raw QR payload as selectable monospaced text.
/// For vCards, the payload is reconstructed from [data] via [VCard.fromMap].
/// For SimpleQRs, [data]['text'] is shown directly. Includes a Copy button.
Future<void> showRawTextDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final cardView = LangProvider.section('pages.QR.card view');
  if (!context.mounted) return;

  final rawText = isVCard
      ? VCard.fromMap(data).toVCard()
      : (data['text'] as String?) ?? '';

  unawaited(showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: currentColors['popup-background'],
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        title: Text(
          cardView['raw'] as String? ?? 'Raw text',
          style: TextStyle(color: currentColors['popup-text']),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              rawText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: currentColors['popup-text'],
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: rawText));
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text(cardView['copied'] as String? ?? 'Copied!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(cardView['copy'] as String? ?? 'Copy'),
          ),
          cancelButton(dialogContext, currentColors),
        ],
      );
    },
  ));
}

/// Opens the read-only viewing dialog for [data]: a structured vCard
/// preview when [isVCard] is true, or the raw text otherwise.
Future<void> showDataDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final cardView = LangProvider.section('pages.QR.card view');
  if (!context.mounted) return;

  final content = isVCard
      ? VCardView(controllers: mapToControllers(data))
      : Text(
          (data['text'] as String?) ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: currentColors['popup-text']),
        );

  final title = Text(
    cardView[isVCard ? 'vcard' : 'simple'] as String,
    textAlign: isVCard ? TextAlign.start : TextAlign.center,
    style: TextStyle(color: currentColors['popup-text']),
  );

  unawaited(showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: currentColors['popup-background'],
      actionsPadding: EdgeInsets.fromLTRB(0, 0, isVCard ? 20 : 16, 8),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isVCard ? 6 : 0,
      ),
      contentPadding: isVCard
          ? const EdgeInsets.symmetric(horizontal: 12)
          : const EdgeInsets.fromLTRB(0, 16, 0, 0),
      title: title,
      content: SingleChildScrollView(
        child: SizedBox(width: double.maxFinite, child: content),
      ),
      actions: [cancelButton(context, currentColors)],
    ),
  ));
}
