import 'package:flutter/material.dart';
import 'package:qr_code_app/modals/card_view.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/modals/qr_view.dart';
import 'package:qr_code_app/modals/save.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/tools/db/db.dart';

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
    final darkProv = DarkModeProvider();
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
          "color": darkProv.isDarkMode ? Colors.red : Colors.redAccent,
          "onPressed": () async {
            await deleteQR(isVCard, data['id']);
            await onRefresh();
          },
        },
      {
        "icon": Icons.download,
        "color": darkProv.isDarkMode ? Colors.indigo : Colors.blue,
        "onPressed": () async {
          String? path = isVCard
              ? await QRDatabase().getPathFromVCard(data['id'])
              : await QRDatabase().getPathFromSimpleQR(data['id']);
          if (!context.mounted) return;
          await showSaveDialog(context, path!);
          await onRefresh();
        },
      },
      if (isVCard && data['deleted'] != 1)
        {
          "icon": Icons.contact_emergency,
          "color": darkProv.isDarkMode ? Colors.green : Colors.lightGreen,
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
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
              ? 4
              : 8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 40,
          children: actions.map((a) {
            return ElevatedButton(
              onPressed: a["onPressed"] as VoidCallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: a["color"] as Color?,
                padding: EdgeInsets.zero,
                fixedSize: const Size(60, 60),
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
