import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> showSharePopup(BuildContext context) async {
  final darkMode = DarkModeProvider();

  showDialog(
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: darkMode, // 👈 écoute le mode
      builder: (context, _) {
        final isDark = darkMode.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? Colors.blueGrey : Colors.white,
          title: Text(
            "Partager",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shareIcon(
                "https://discord.com/invite/xxxx",
                FontAwesomeIcons.discord,
                isDark,
              ),
              _shareIcon(
                "https://instagram.com/xxxx",
                FontAwesomeIcons.instagram,
                isDark,
              ),
              _shareIcon(
                "https://x.com/xxxx",
                FontAwesomeIcons.xTwitter,
                isDark,
              ),
              _shareIcon(
                "https://facebook.com/xxxx",
                FontAwesomeIcons.facebook,
                isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Fermer",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _shareIcon(String url, IconData icon, bool isDark) {
  return InkWell(
    onTap: () async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    child: Icon(icon, size: 40, color: isDark ? Colors.white : Colors.black),
  );
}
