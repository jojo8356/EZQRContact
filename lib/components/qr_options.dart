import 'package:flutter/material.dart';
import 'package:qr_code_app/modals/card_view.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/modals/qr_view.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/modals/save.dart';

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

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "icon": Icons.remove_red_eye,
        "color": null,
        "onPressed": () async {
          await showDataDialog(context, data, isVCard: isVCard);
        },
      },
      {
        "icon": Icons.qr_code,
        "color": null,
        "onPressed": () async {
          if (data['path'] != null && data['path'].isNotEmpty) {
            await showImageDialog(context, data['path']);
          }
        },
      },
      if (data['deleted'] != 1)
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
            await showVCardPopup(context, data, isVCard: true);
            await onRefresh();
          },
        },
    ];

    return AnimatedCrossFade(
      firstChild: Container(),
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: actions.length > 4 ? 4 : actions.length,
          mainAxisSpacing: 10,
          crossAxisSpacing: 40,
          children: actions.map((a) {
            return ElevatedButton(
              onPressed: a["onPressed"] as VoidCallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: a["color"] as Color?,
                padding: const EdgeInsets.all(2),
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
