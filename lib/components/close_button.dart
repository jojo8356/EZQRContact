import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang.dart';

Widget cancelButton(BuildContext context, Map<String, Color> currentColors) {
  return TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text(
      LangProvider.get("close"),
      style: TextStyle(color: currentColors['popup-text']),
    ),
  );
}
