import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> showSharePopup(BuildContext context) async {
  final darkMode = DarkModeProvider();

  showDialog(
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: darkMode,
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
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (kDebugMode) {
          print("launchUrl renvoie: $ok");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Erreur: $e");
        }
      }
    },

    child: Icon(icon, size: 40, color: isDark ? Colors.white : Colors.black),
  );
}
