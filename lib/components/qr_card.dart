import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Tile-style widget representing a single QR or VCard row, expandable to
/// reveal the [OptionsQR] action grid.
class QRCard extends StatefulWidget {
  /// Creates a QR card. [onRefresh] is invoked after destructive actions.
  const QRCard({
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
    final darkProv = DarkModeProvider();
    final titleText = PhoneContacts.getTitle({
      'type': widget.isVCard ? 'vcard' : 'simple',
      'data': widget.data,
    });
    final photo = (widget.data['photo'] as String?) ?? '';

    return Card(
      color: currentColors['surface'],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            leading: buildItemAvatar(isVCard: widget.isVCard, photo: photo),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: currentColors['text-muted'],
                  ),
                ),
                if (widget.data['date_deleted'] != null)
                  Text(
                    "Supprimé le : ${widget.data['date_deleted']}",
                    style: TextStyle(
                      fontSize: 12,
                      color: darkProv.isDarkMode
                          ? Colors.redAccent
                          : Colors.pinkAccent,
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: currentColors['text'],
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
    );
  }
}
