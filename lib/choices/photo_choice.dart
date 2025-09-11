import 'package:flutter/material.dart';
import 'package:qr_code_app/import_qr_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_scanner.dart';
import 'package:qr_code_app/vars.dart';

final choicePhoto = LangProvider.get('choices')['photo'];

final List<Map<String, dynamic>> photoChoiceButtons = [
  {
    "label": choicePhoto['scanner'],
    "icon": Icons.qr_code,
    "color": isDarkMode ? Colors.indigo : Colors.blue,
    "builder": () => const QRScannerPage(),
  },
  {
    "label": choicePhoto['import'],
    "icon": Icons.upload_file,
    "color": isDarkMode ? Colors.green : Colors.lightGreen,
    "builder": () => QrFromImagePage(),
  },
];
