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

  late final String rawText;
  if (isVCard) {
    rawText = VCard.fromMap(data).toVCard();
  } else {
    rawText = (data['text'] as String?) ?? '';
  }

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

  late final Widget content;
  if (isVCard) {
    content = VCardView(controllers: mapToControllers(data));
  } else {
    content = Text(
      (data['text'] as String?) ?? '',
      textAlign: TextAlign.center,
      style: TextStyle(color: currentColors['popup-text']),
    );
  }

  var titleKey = 'simple';
  var titleAlign = TextAlign.center;
  var actionsRight = 16.0;
  var insetV = 0.0;
  var contentPad = const EdgeInsets.fromLTRB(0, 16, 0, 0);
  if (isVCard) {
    titleKey = 'vcard';
    titleAlign = TextAlign.start;
    actionsRight = 20;
    insetV = 6;
    contentPad = const EdgeInsets.symmetric(horizontal: 12);
  }

  final title = Text(
    cardView[titleKey] as String,
    textAlign: titleAlign,
    style: TextStyle(color: currentColors['popup-text']),
  );

  unawaited(showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: currentColors['popup-background'],
      actionsPadding: EdgeInsets.fromLTRB(0, 0, actionsRight, 8),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: insetV,
      ),
      contentPadding: contentPad,
      title: title,
      content: SingleChildScrollView(
        child: SizedBox(width: double.maxFinite, child: content),
      ),
      actions: [cancelButton(context, currentColors)],
    ),
  ));
}
