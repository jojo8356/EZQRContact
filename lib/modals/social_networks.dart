import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSharePopup(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? Colors.blueGrey : Colors.white,
          title: Text(
            "Partager",
            style: TextStyle(color: currentColors['text']),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shareIcon(
                "https://discord.gg/gz25QVbS",
                FontAwesomeIcons.discord,
                isDark,
              ),
              _shareIcon(
                "https://www.instagram.com/dev_jojokes/",
                FontAwesomeIcons.instagram,
                isDark,
              ),
              _shareIcon(
                "https://x.com/HazroF3",
                FontAwesomeIcons.xTwitter,
                isDark,
              ),
            ],
          ),
          actions: [cancelButton(context, currentColors)],
        );
      },
    ),
  );
}

Widget _shareIcon(String url, IconData icon, bool isDark) {
  return InkWell(
    onTap: () async {
      final uri = Uri.parse(url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        return;
      }
    },

    child: Icon(icon, size: 40, color: currentColors['text']),
  );
}
