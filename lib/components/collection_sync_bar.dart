import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Import-all / export-all actions shown on the Collection tab.
class CollectionSyncBar extends StatelessWidget {
  /// Creates the two-button bar.
  const new({
    required this.onImport,
    required this.onExport,
    super.key,
  });

  /// Import every contact from the device address book.
  final VoidCallback onImport;

  /// Export the collection as a zip (vCards, QR images, photos).
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.collection');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              key: const Key('collection-import-all'),
              label: (lang['import_all'] as String?) ?? 'Import all',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: onImport,
            ),
          ),
          const SizedBox(width: AppTokens.s2),
          Expanded(
            child: AppButton.primary(
              key: const Key('collection-export-all'),
              label: (lang['export_all'] as String?) ?? 'Export all',
              icon: Icons.ios_share_outlined,
              onPressed: onExport,
            ),
          ),
        ],
      ),
    );
  }
}
