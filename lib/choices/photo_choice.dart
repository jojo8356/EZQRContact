import 'package:flutter/material.dart';
import 'package:qr_code_app/import_qr_page.dart';
import 'package:qr_code_app/qr_scanner.dart';

final List<Map<String, dynamic>> photoChoiceButtons = [
  {
    "label": "Scanner QR Code",
    "icon": Icons.qr_code,
    "color": Colors.blue,
    "builder": () => const QRScannerPage(),
  },
  {
    "label": "Import QR Code",
    "icon": Icons.upload_file,
    "color": Colors.green,
    "builder": () => QrFromImagePage(),
  },
];
