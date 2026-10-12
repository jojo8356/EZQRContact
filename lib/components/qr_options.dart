import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/card_view.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/modals/qr_view.dart';
import 'package:qr_code_app/modals/save.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Collapsible grid of action buttons attached to a QRCard: view, open
/// the rendered QR image, delete, download, and (for vCards) sync to the
/// device contacts. Reveals its content when [expanded] is true.
class OptionsQR extends StatelessWidget {
  /// Creates the options row for the QR/VCard described by [data].
  /// [onRefresh] is awaited after each destructive action so the parent
  /// list can re-query the database.
  const new({
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
    final semLang = LangProvider.section('semantics');
    final c = currentColors;
    final actions = [
      {
        'icon': Icons.visibility_outlined,
        'color': c['navy'],
        'semanticsKey': 'btn_view_card',
        'onPressed': () async {
          await showDataDialog(context, data, isVCard: isVCard);
        },
      },
      {
        'icon': Icons.data_object,
        'color': c['text-muted'],
        'semanticsKey': 'btn_view_raw',
        'onPressed': () async {
          await showRawTextDialog(context, data, isVCard: isVCard);
        },
      },
      {
        'icon': Icons.qr_code_2_rounded,
        'color': c['button-color'],
        'semanticsKey': 'btn_view_qr',
        'onPressed': () async {
          final path = data['path'] as String?;
          if (path != null && path.isNotEmpty) {
            await showImageDialog(context, path);
          }
        },
      },
      if (data['deleted'] != 1)
        {
          'icon': LucideIcons.trash_2,
          'color': c['danger'],
          'semanticsKey': 'btn_delete',
          'onPressed': () async {
            await deleteQR(isVCard: isVCard, id: data['id'] as int);
            await onRefresh();
          },
        },
      {
          'icon': LucideIcons.download,
        'color': c['navy'],
        'semanticsKey': 'btn_download',
        'onPressed': () async {
          late final String? path;
          if (isVCard) {
            path = await QRDatabase().getPathFromVCard(data['id'] as int);
          } else {
            path = await QRDatabase().getPathFromSimpleQR(
              data['id'] as int,
            );
          }
          if (!context.mounted) return;
          await showSaveDialog(context, path!);
          await onRefresh();
        },
      },
      if (isVCard && data['deleted'] != 1)
        {
          'icon': Icons.person_add_alt_1_outlined,
          'color': c['success'],
          'semanticsKey': 'btn_add_contact',
          'onPressed': () async {
            await showVCardPopup(context, data, isVCard: true);
            await onRefresh();
          },
        },
    ];
    var fade = CrossFadeState.showFirst;
    if (expanded) {
      fade = CrossFadeState.showSecond;
    }
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s4,
          0,
          AppTokens.s4,
          AppTokens.s3,
        ),
        child: Wrap(
          spacing: AppTokens.s2,
          runSpacing: AppTokens.s2,
          children: actions.map((a) {
            final key = a['semanticsKey'] as String?;
            String? label;
            if (key != null) {
              label = semLang[key] as String?;
            }
            final color = a['color'] as Color?;
            return Semantics(
              label: label,
              button: true,
              child: Material(
                color: c['surface-raised'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.rSm),
                ),
                child: InkWell(
                  onTap: a['onPressed']! as VoidCallback,
                  borderRadius: BorderRadius.circular(AppTokens.rSm),
                  child: SizedBox(
                    width: AppTokens.tap,
                    height: AppTokens.tap,
                    child: Icon(
                      a['icon']! as IconData,
                      color: color,
                      size: 22,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      crossFadeState: fade,
      duration: AppTokens.tMed,
    );
  }
}
