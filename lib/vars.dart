import 'package:flutter/material.dart';
import 'package:qr_code_app/home_page.dart';
import 'package:qr_code_app/tools.dart';

List<Map<String, dynamic>> getActionQRCode(BuildContext context) {
  return [
    {
      "label": "Menu",
      "color": Colors.red,
      "icon": Icons.home,
      "onPressed": () async {
        await redirect(context, HomePage());
      },
    },
    {
      "label": "Generate",
      "color": Colors.blue,
      "icon": Icons.refresh,
      "onPressed": () {
        Navigator.pop(context, true);
      },
    },
  ];
}
