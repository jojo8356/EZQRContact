import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/close_button.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:toastification/toastification.dart';

/// Shows a fill-colored toast at the top-right of [context] using
/// `toastification`. Defaults to a success-checkmark icon.
void showToast({
  required BuildContext context,
  required String title,
  required Color color,
  IconData icon = Icons.check_circle,
  ToastificationType type = ToastificationType.success,
}) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 3),
    title: Text(title, style: TextStyle(color: color)),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) =>
        FadeTransition(opacity: animation, child: child),
    icon: Icon(icon, size: 30, color: color),
    showIcon: true,
    primaryColor: Colors.green,
    backgroundColor: color,
    foregroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
      ),
    ],
    showProgressBar: true,
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: false,
  );
}

/// Builds the action buttons of the vCard contact-options dialog.
/// Each entry of [buttons] must contain `icon`, `title`, and `action`.
List<Widget> generateButtons({
  required List<Map<String, dynamic>> buttons,
  required BuildContext context,
  required BuildContext dialogContext,
  required Color buttonColor,
  required Color color,
}) {
  return List.generate(buttons.length, (index) {
    final button = buttons[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(buttonColor),
          foregroundColor: WidgetStateProperty.all<Color>(color),
        ),
        icon: Icon(button['icon'] as IconData, color: color),
        label: Text(button['title'] as String, style: TextStyle(color: color)),
        onPressed: () async {
          final action = button['action'] as Future<void> Function();
          await action();

          if (!dialogContext.mounted) return;

          showToast(
            context: context,
            title: '${button['title']} successful',
            color: color,
          );

          unawaited(Navigator.pushReplacementNamed(dialogContext, '/home'));
        },
      ),
    );
  });
}

/// Opens the vCard contact-options dialog for [data] (the row payload).
/// No-op when [isVCard] is false.
Future<void> showVCardPopup(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final db = QRDatabase();
  if (!isVCard) return;
  if (!context.mounted) return;

  final lang = LangProvider.section('pages.contact.options');
  final buttonsLang =
      lang['buttons'] as Map<String, dynamic>? ?? const <String, dynamic>{};
  final buttons = [
    {
      'title': buttonsLang['replace'] as String,
      'icon': Icons.sync,
      'action': () async {
        final vcard = await db.getVCardById(data['id'] as int) ?? {};
        await PhoneContacts.update(vcard);
      },
    },
    {
      'title': buttonsLang['clone'] as String,
      'icon': Icons.copy,
      'action': () async {
        await db.cloneVCard(data['id'] as int);
      },
    },
    {
      'title': buttonsLang['empty input'] as String,
      'icon': Icons.edit,
      'action': () async {
        final vcard = await PhoneContacts.getByName(
          nom: data['nom'] as String?,
          prenom: data['prenom'] as String?,
        );
        await db.modifContact(vcard ?? {});
      },
    },
  ];

  final bgColor = currentColors['bg'] ?? Colors.white;
  final textColor = currentColors['text'];
  final buttonColor = currentColors['button-color'] ?? Colors.white;

  unawaited(showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: bgColor,
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        title: Text(
          lang['title'] as String,
          style: TextStyle(color: textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: generateButtons(
              buttons: buttons,
              context: context,
              dialogContext: dialogContext,
              buttonColor: buttonColor,
              color: bgColor,
            ),
          ),
        ),
        actions: [cancelButton(dialogContext, currentColors)],
      );
    },
  ));
}
