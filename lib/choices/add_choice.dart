import 'package:flutter/material.dart';
import 'package:qr_code_app/qr_generator_simple.dart';
import 'package:qr_code_app/qr_generator_vcard.dart';

final List<Map<String, dynamic>> addChoiceButtons = [
  {
    "label": "Simple QR Code",
    "icon": Icons.qr_code,
    "color": Colors.blue,
    "builder": () => const GenerateSimpleQRCode(),
  },
  {
    "label": "VCard QR Code",
    "icon": Icons.perm_identity,
    "color": Colors.green,
    "builder": () => const GenerateVCardQRCode(),
  },
];
