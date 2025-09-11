import 'package:flutter/material.dart';
import 'package:qr_code_app/bottom_nav.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/tools.dart';

List<Map<String, dynamic>> getActionQRCode(BuildContext context) {
  final actions = LangProvider.get('pages')['QR']['result']['actions'];
  return [
    {
      "label": actions['menu'],
      "color": isDarkMode ? Colors.red : Colors.redAccent,
      "icon": Icons.home,
      "onPressed": () async {
        await redirect(context, MainNavigation());
      },
    },
    {
      "label": actions['generate'],
      "color": isDarkMode ? Colors.cyan : Colors.blue,
      "icon": Icons.refresh,
      "onPressed": () {
        Navigator.pop(context, true);
      },
    },
  ];
}

bool isDarkMode = false;
