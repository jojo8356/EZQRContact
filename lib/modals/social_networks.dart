import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the "Partager" dialog with social-network icons that open the
/// developer's Discord / Instagram / X profiles in the platform browser.
Future<void> showSharePopup(BuildContext context) async {
  unawaited(showDialog<void>(
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return AlertDialog(
          backgroundColor: currentColors['popup-background'],
          title: Text(
            'Partager',
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
                'https://discord.gg/gz25QVbS',
                FontAwesomeIcons.discord,
              ),
              _shareIcon(
                'https://www.instagram.com/dev_jojokes/',
                FontAwesomeIcons.instagram,
              ),
              _shareIcon(
                'https://x.com/HazroF3',
                FontAwesomeIcons.xTwitter,
              ),
            ],
          ),
          actions: [cancelButton(context, currentColors)],
        );
      },
    ),
  ));
}

Widget _shareIcon(String url, FaIconData icon) {
  return InkWell(
    onTap: () async {
      final uri = Uri.parse(url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception catch (_) {
        return;
      }
    },
    child: FaIcon(icon, size: 40, color: currentColors['text']),
  );
}
