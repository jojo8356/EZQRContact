import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> showSharePopup(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Partager"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _shareIcon(
            "https://discord.com/invite/xxxx",
            FontAwesomeIcons.discord,
          ),
          _shareIcon("https://instagram.com/xxxx", FontAwesomeIcons.instagram),
          _shareIcon("https://x.com/xxxx", FontAwesomeIcons.xTwitter),
          _shareIcon("https://facebook.com/xxxx", FontAwesomeIcons.facebook),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Fermer"),
        ),
      ],
    ),
  );
}

Widget _shareIcon(String url, IconData icon) {
  return InkWell(
    onTap: () async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    child: Icon(icon, size: 40),
  );
}
