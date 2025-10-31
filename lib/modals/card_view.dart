import 'package:flutter/material.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showDataDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final cardView = LangProvider.get('pages')['QR']['card view'];
  if (!context.mounted) return;

  final content = isVCard
      ? VCardView(controllers: mapToControllers(data))
      : Text(
          data['text'] ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(color: currentColors['popup-text']),
        );

  final title = Text(
    cardView[isVCard ? 'vcard' : 'simple'],
    textAlign: isVCard ? TextAlign.start : TextAlign.center,
    style: TextStyle(color: currentColors['popup-text']),
  );

  showDialog(
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
  );
}
