import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showDataDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(isVCard ? 'VCard infos' : 'QR Code Texte'),
      content: isVCard
          ? SingleChildScrollView(
              child: VCardView(controllers: mapToControllers(data)),
            )
          : Text(data['text'] ?? "", textAlign: TextAlign.center),
      actions: [closeButton(context)],
    ),
  );
}
