import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang_provider.dart';

/// "Annuler" button used in every modal: pops the current dialog and is
/// styled with the active theme's popup-text color.
Widget cancelButton(BuildContext context, Map<String, Color> currentColors) {
  return TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text(
      LangProvider.getString('close'),
      style: TextStyle(color: currentColors['popup-text']),
    ),
  );
}
