import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Bottom bar shown while Collection is in multi-select mode.
class CollectionSelectBar extends StatelessWidget {
  /// Creates the bar.
  const new({
    required this.count,
    required this.onCancel,
    required this.onDelete,
    required this.onExport,
    required this.onSelectAll,
    super.key,
  });

  /// Number of checked cards.
  final int count;

  /// Exit select mode.
  final VoidCallback onCancel;

  /// Delete the checked cards.
  final VoidCallback onDelete;

  /// Export the checked cards as a zip.
  final VoidCallback onExport;

  /// Select every card currently listed.
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.collection');
    final c = currentColors;
    final countLabel = ((lang['select_count'] as String?) ?? '%s selected')
        .replaceFirst('%s', '$count');
    VoidCallback? deletePressed = onDelete;
    VoidCallback? exportPressed = onExport;
    if (count == 0) {
      deletePressed = null;
      exportPressed = null;
    }
    return Material(
      color: c['surface'],
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s3,
            AppTokens.s2,
            AppTokens.s3,
            AppTokens.s2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const Key('collection-select-cancel'),
                    tooltip: LangProvider.getString('close'),
                    onPressed: onCancel,
                    icon: Icon(Icons.close, color: c['text']),
                  ),
                  Expanded(
                    child: Text(
                      countLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: c['text'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('collection-select-all'),
                    onPressed: onSelectAll,
                    child: Text(
                      (lang['select_all'] as String?) ?? 'Select all',
                      style: TextStyle(color: c['button-color']),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      key: const Key('collection-select-delete'),
                      label: (lang['select_delete'] as String?) ?? 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: deletePressed,
                    ),
                  ),
                  const SizedBox(width: AppTokens.s2),
                  Expanded(
                    child: AppButton.primary(
                      key: const Key('collection-select-export'),
                      label: (lang['select_export'] as String?) ?? 'Export',
                      icon: Icons.ios_share_outlined,
                      onPressed: exportPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
