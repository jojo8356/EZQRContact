import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_generator_simple.dart';
import 'package:qr_code_app/qr_generator_vcard.dart';
import 'package:qr_code_app/vars.dart';

final choiceAdd = LangProvider.get('choices')['add'];

final List<Map<String, dynamic>> addChoiceButtons = [
  {
    "label": choiceAdd['simple'],
    "icon": Icons.qr_code,
    "color": isDarkMode ? Colors.indigo : Colors.blue,
    "builder": () => const GenerateSimpleQRCode(),
  },
  {
    "label": choiceAdd['vcard'],
    "icon": Icons.perm_identity,
    "color": isDarkMode ? Colors.green : Colors.lightGreen,
    "builder": () => const GenerateVCardQRCode(),
  },
];
