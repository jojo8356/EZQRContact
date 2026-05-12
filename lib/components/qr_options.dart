import 'package:flutter/material.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/card_view.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/modals/qr_view.dart';
import 'package:qr_code_app/modals/save.dart';
import 'package:qr_code_app/providers/darkmode.dart';

/// Collapsible grid of action buttons attached to a QRCard: view, open
/// the rendered QR image, delete, download, and (for vCards) sync to the
/// device contacts. Reveals its content when [expanded] is true.
class OptionsQR extends StatelessWidget {
  /// Creates the options row for the QR/VCard described by [data].
  /// [onRefresh] is awaited after each destructive action so the parent
  /// list can re-query the database.
  const OptionsQR({
    required this.isVCard,
    required this.data,
    required this.expanded,
    required this.onRefresh,
    super.key,
  });

  /// True when [data] represents a vCard contact (unlocks extra actions).
  final bool isVCard;

  /// Legacy row payload (`Map<String, dynamic>`) for the QR or VCard.
  final Map<String, dynamic> data;

  /// True to display the action grid, false to hide it.
  final bool expanded;

  /// Callback invoked after a destructive action mutates the database.
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();
    final actions = [
      {
        'icon': Icons.remove_red_eye,
        'color': null,
        'onPressed': () async {
          await showDataDialog(context, data, isVCard: isVCard);
        },
      },
      {
        'icon': Icons.data_object,
        'color': null,
        'onPressed': () async {
          await showRawTextDialog(context, data, isVCard: isVCard);
        },
      },
      {
        'icon': Icons.qr_code,
        'color': null,
        'onPressed': () async {
          final path = data['path'] as String?;
          if (path != null && path.isNotEmpty) {
            await showImageDialog(context, path);
          }
        },
      },
      if (data['deleted'] != 1)
        {
          'icon': Icons.delete,
          'color': darkProv.isDarkMode ? Colors.red : Colors.redAccent,
          'onPressed': () async {
            await deleteQR(isVCard: isVCard, id: data['id'] as int);
            await onRefresh();
          },
        },
      {
        'icon': Icons.download,
        'color': darkProv.isDarkMode ? Colors.indigo : Colors.blue,
        'onPressed': () async {
          final path = isVCard
              ? await QRDatabase().getPathFromVCard(data['id'] as int)
              : await QRDatabase().getPathFromSimpleQR(data['id'] as int);
          if (!context.mounted) return;
          await showSaveDialog(context, path!);
          await onRefresh();
        },
      },
      if (isVCard && data['deleted'] != 1)
        {
          'icon': Icons.contact_emergency,
          'color': darkProv.isDarkMode ? Colors.green : Colors.lightGreen,
          'onPressed': () async {
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
              onPressed: a['onPressed']! as VoidCallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: a['color'] as Color?,
                padding: EdgeInsets.zero,
                fixedSize: const Size(60, 60),
              ),
              child: Icon(
                a['icon']! as IconData,
                color: a['color'] != null ? Colors.white : null,
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
