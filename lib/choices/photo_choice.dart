import 'package:flutter/material.dart';
import 'package:qr_code_app/import_qr_page.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_scanner.dart';

final choicePhoto = LangProvider.get('choices')['photo'];

List<Map<String, dynamic>> getPhotoChoiceButtons(BuildContext context) {
  final darkMode = DarkModeProvider();

  return [
    {
      "label": choicePhoto['scanner'],
      "icon": Icons.qr_code,
      "color": darkMode.isDarkMode ? Colors.indigo : Colors.blue,
      "builder": () => const QRScannerPage(),
    },
    {
      "label": choicePhoto['import'],
      "icon": Icons.upload_file,
      "color": darkMode.isDarkMode ? Colors.green : Colors.lightGreen,
      "builder": () => QrFromImagePage(),
    },
  ];
}
