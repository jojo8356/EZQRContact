import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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
    this.onDelete,
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

  /// Test override for [deleteQR]. Production leaves this null.
  final Future<void> Function(int id)? onDelete;

  @override
  Widget build(BuildContext context) {
    final semLang = LangProvider.section('semantics');
    final c = currentColors;
    final actions = <_QrAction>[
      _QrAction(
        icon: Icons.visibility_outlined,
        color: c['navy'],
        semanticsKey: 'btn_view_card',
        onPressed: () async {
          await showDataDialog(context, data, isVCard: isVCard);
        },
      ),
      _QrAction(
        icon: Icons.data_object,
        color: c['text-muted'],
        semanticsKey: 'btn_view_raw',
        onPressed: () async {
          await showRawTextDialog(context, data, isVCard: isVCard);
        },
      ),
      _QrAction(
        icon: Icons.qr_code_2_rounded,
        color: c['button-color'],
        semanticsKey: 'btn_view_qr',
        onPressed: () async {
          final path = data['path'] as String?;
          if (path != null && path.isNotEmpty) {
            await showImageDialog(context, path);
          }
        },
      ),
      if (data['deleted'] != 1)
        _QrAction(
          icon: LucideIcons.trash,
          color: c['danger'],
          semanticsKey: 'btn_delete',
          buttonKey: const Key('qr-btn-delete'),
          onPressed: () async {
            final id = _asId(data['id']);
            if (id == null) {
              return;
            }
            final custom = onDelete;
            if (custom != null) {
              await custom(id);
            } else {
              await deleteQR(isVCard: isVCard, id: id);
            }
            await onRefresh();
          },
        ),
      _QrAction(
        icon: LucideIcons.download,
        color: c['navy'],
        semanticsKey: 'btn_download',
        onPressed: () async {
          final id = _asId(data['id']);
          if (id == null) {
            return;
          }
          late final String? path;
          if (isVCard) {
            path = await QRDatabase().getPathFromVCard(id);
          } else {
            path = await QRDatabase().getPathFromSimpleQR(id);
          }
          if (!context.mounted) {
            return;
          }
          if (path == null || path.isEmpty) {
            return;
          }
          await showSaveDialog(context, path);
          await onRefresh();
        },
      ),
      if (isVCard && data['deleted'] != 1)
        _QrAction(
          icon: Icons.person_add_alt_1_outlined,
          color: c['success'],
          semanticsKey: 'btn_add_contact',
          onPressed: () async {
            await showVCardPopup(context, data, isVCard: true);
            await onRefresh();
          },
        ),
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
          children: [
            for (final action in actions)
              Semantics(
                label: semLang[action.semanticsKey] as String?,
                button: true,
                child: Material(
                  color: c['surface-raised'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.rSm),
                  ),
                  child: InkWell(
                    key: action.buttonKey,
                    onTap: () async {
                      await action.onPressed();
                    },
                    borderRadius: BorderRadius.circular(AppTokens.rSm),
                    child: SizedBox(
                      width: AppTokens.tap,
                      height: AppTokens.tap,
                      child: Icon(
                        action.icon,
                        color: action.color,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      crossFadeState: fade,
      duration: AppTokens.tMed,
    );
  }
}

int? _asId(dynamic raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  return int.tryParse(raw?.toString() ?? '');
}

class _QrAction {
  const _QrAction({
    required this.icon,
    required this.color,
    required this.semanticsKey,
    required this.onPressed,
    this.buttonKey,
  });

  final IconData icon;
  final Color? color;
  final String semanticsKey;
  final Future<void> Function() onPressed;
  final Key? buttonKey;
}
