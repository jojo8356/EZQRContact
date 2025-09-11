import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/vars.dart';

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
    final titleText = getTitleAndPhoto({
      'type': widget.isVCard ? 'vcard' : 'simple',
      'data': widget.data,
    });
    final photo = widget.data['photo'] ?? '';

    return Card(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.data['date_deleted'] != null)
                  Text(
                    "Supprimé le : ${widget.data['date_deleted']}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.redAccent : Colors.pinkAccent,
                    ),
                  ),
              ],
            ),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
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
