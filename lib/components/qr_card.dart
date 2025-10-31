import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

class QRCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isVCard;
  final Future<void> Function() onRefresh;

  const QRCard({
    super.key,
    required this.data,
    required this.isVCard,
    required this.onRefresh,
  });

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
    final photo = widget.data['photo'] ?? '';

    return Card(
      color: darkProv.isDarkMode ? Colors.white30 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            leading: buildItemAvatar(widget.isVCard, photo),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkProv.isDarkMode ? Colors.white70 : Colors.black,
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
              color: darkProv.isDarkMode ? Colors.white : Colors.black,
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
