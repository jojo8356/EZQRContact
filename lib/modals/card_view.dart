import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showDataDialog(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  if (!context.mounted) return;

  if (isVCard) {
    final controllers = mapToControllers(data);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),

        title: const Text('Infos VCard'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: VCardView(controllers: controllers),
          ),
        ),
        actions: [closeButton(context)],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        title: const Text('QR Code Texte', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Text(data['text'] ?? "", textAlign: TextAlign.center),
          ),
        ),
        actions: [closeButton(context)],
      ),
    );
  }
}
