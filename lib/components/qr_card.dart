import 'package:flutter/material.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Tile-style widget representing a single QR or VCard row, expandable to
/// reveal the [OptionsQR] action grid.
class QRCard extends StatefulWidget {
  /// Creates a QR card. [onRefresh] is invoked after destructive actions.
  const new({
    required this.data,
    required this.isVCard,
    required this.onRefresh,
    super.key,
  });

  /// Legacy row payload for the QR or VCard.
  final Map<String, dynamic> data;

  /// True when [data] represents a vCard contact.
  final bool isVCard;

  /// Callback invoked after a destructive action mutates the database.
  final Future<void> Function() onRefresh;

  @override
  State<QRCard> createState() => _QRCardState();
}

class _QRCardState extends State<QRCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    var type = 'simple';
    if (widget.isVCard) {
      type = 'vcard';
    }
    final titleText = PhoneContacts.getTitle({
      'type': type,
      'data': widget.data,
    });
    final photo = (widget.data['photo'] as String?) ?? '';
    final c = currentColors;
    final theme = Theme.of(context);
    var expandIcon = Icons.expand_more_rounded;
    if (expanded) {
      expandIcon = Icons.expand_less_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s5,
        vertical: AppTokens.s2,
      ),
      child: PaperCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s4,
                vertical: AppTokens.s1,
              ),
              leading: buildItemAvatar(
                isVCard: widget.isVCard,
                photo: photo,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: c['text'],
                    ),
                  ),
                  if (widget.data['date_deleted'] != null)
                    Text(
                      'Supprimé le : ${widget.data['date_deleted']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c['danger'],
                      ),
                    ),
                ],
              ),
              trailing: Icon(
                expandIcon,
                color: c['text-muted'],
              ),
              onTap: () {
                setState(() => expanded = !expanded);
              },
            ),
            OptionsQR(
              isVCard: widget.isVCard,
              data: widget.data,
              expanded: expanded,
              onRefresh: widget.onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
