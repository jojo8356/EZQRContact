import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_generator_simple.dart';
import 'package:qr_code_app/qr_generator_vcard.dart';

final choiceAdd = LangProvider.get('choices')['add'];

List<Map<String, dynamic>> getAddChoiceButtons(BuildContext context) {
  final darkMode = DarkModeProvider(); // Singleton

  return [
    {
      "label": choiceAdd['simple'],
      "icon": Icons.qr_code,
      "color": darkMode.isDarkMode ? Colors.indigo : Colors.blue,
      "builder": () => const GenerateSimpleQRCode(),
    },
    {
      "label": choiceAdd['vcard'],
      "icon": Icons.perm_identity,
      "color": darkMode.isDarkMode ? Colors.green : Colors.lightGreen,
      "builder": () => const GenerateVCardQRCode(),
    },
  ];
}
