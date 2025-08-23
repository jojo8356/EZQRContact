import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/db/db.dart';
import 'package:qr_code_app/save_file_page.dart';
import 'package:qr_code_app/tools.dart';

class OptionsQR extends StatelessWidget {
  final bool isVCard;
  final Map<String, dynamic> data;
  final bool expanded;
  final Future<void> Function() onRefresh;

  const OptionsQR({
    super.key,
    required this.isVCard,
    required this.data,
    required this.expanded,
    required this.onRefresh,
  });

  Widget closeButton(BuildContext context) => TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('Close'),
  );

  @override
  Widget build(BuildContext context) {
    final db = QRDatabase();
    final actions = [
      {
        "icon": Icons.remove_red_eye,
        "color": null,
        "onPressed": () {
          if (isVCard) {
            final controllers = mapToControllers(data);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('VCard infos'),
                content: SingleChildScrollView(
                  child: VCardView(controllers: controllers),
                ),
                actions: [closeButton(context)],
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('QR Code Texte'),
                content: Text(data['text'] ?? "", textAlign: TextAlign.center),
                actions: [closeButton(context)],
              ),
            );
          }
        },
      },
      {
        "icon": Icons.qr_code,
        "color": null,
        "onPressed": () {
          if (data['path'] != null && data['path'].isNotEmpty) {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: InteractiveViewer(
                    child: Image.file(File(data['path']), fit: BoxFit.contain),
                  ),
                ),
              ),
            );
          }
        },
      },
      {
        "icon": Icons.delete,
        "color": Colors.red,
        "onPressed": () async {
          await deleteQR(isVCard, data['id']);
          await onRefresh();
        },
      },
      {
        "icon": Icons.download,
        "color": Colors.blue,
        "onPressed": () async {
          String? path = isVCard
              ? await QRDatabase().getPathFromVCard(data['id'])
              : await QRDatabase().getPathFromSimpleQR(data['id']);
          if (!context.mounted) return;
          await showSaveDialog(context, path!);
          await onRefresh();
        },
      },
      if (isVCard)
        {
          "icon": Icons.contact_emergency,
          "color": Colors.green,
          "onPressed": () async {
            verifContact();
            addContact(
              data.entries.where((entry) => entry.key != 'id')
                  as Map<String, String>,
            );
            await db.saveContact(await db.getVCardById(data['id']) ?? {});
            await onRefresh();
          },
        },
    ];

    return AnimatedCrossFade(
      firstChild: Container(),
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((a) {
            return ElevatedButton(
              onPressed: a["onPressed"] as VoidCallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: a["color"] as Color?,
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              child: Icon(
                a["icon"] as IconData,
                color: a["color"] != null ? Colors.white : null,
              ),
            );
          }).toList(),
        ),
      ),
      crossFadeState: expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
