import 'package:flutter/material.dart';
import 'package:qr_code_app/bottom_nav.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:toastification/toastification.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> showVCardPopup(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final darkMode = DarkModeProvider();
  final db = QRDatabase();
  if (!isVCard) return;
  if (!context.mounted) return;

  final lang = LangProvider.get("pages")['contact']['options'];
  final buttonsLang = lang['buttons'];
  final buttons = [
    {
      "title": buttonsLang['replace'],
      "icon": Icons.sync,
      "action": () async {
        final vcard = await db.getVCardById(data['id']) ?? {};
        await updateContactOnPhone(vcard);
      },
    },
    {
      "title": buttonsLang['clone'],
      "icon": Icons.copy,
      "action": () async {
        await db.cloneVCard(data['id']);
      },
    },
    {
      "title": buttonsLang['empty input'],
      "icon": Icons.edit,
      "action": () async {
        final vcard = await getContactByName(
          nom: data['nom'],
          prenom: data['prenom'],
        );
        await db.modifContact(vcard ?? {});
      },
    },
  ];

  final bgColor = darkMode.isDarkMode ? Colors.black : Colors.white;
  final textColor = darkMode.isDarkMode ? Colors.white : Colors.black;
  final buttonColor = Colors.blue; // reste bleu dans les deux modes

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: bgColor,
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        title: Text(lang['title'], style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(buttons.length, (index) {
              final button = buttons[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      buttonColor,
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(textColor),
                  ),
                  icon: Icon(button['icon'] as IconData, color: textColor),
                  label: Text(
                    button['title'] as String,
                    style: TextStyle(color: textColor),
                  ),
                  onPressed: () async {
                    final action = button['action'] as Future<void> Function();
                    await action();

                    if (!dialogContext.mounted) return;
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      style: ToastificationStyle.fillColored,
                      autoCloseDuration: const Duration(seconds: 3),
                      title: Text(
                        '${button['title']} successful',
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.topRight,
                      direction: TextDirection.ltr,
                      animationDuration: const Duration(milliseconds: 300),
                      animationBuilder: (context, animation, alignment, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      icon: Icon(
                        Icons.check_circle,
                        size: 30,
                        color: textColor,
                      ),
                      showIcon: true,
                      primaryColor: Colors.green,
                      backgroundColor: bgColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 16,
                          offset: Offset(0, 16),
                          spreadRadius: 0,
                        ),
                      ],
                      showProgressBar: true,
                      closeOnClick: false,
                      pauseOnHover: true,
                      dragToClose: false,
                    );

                    Navigator.pushReplacement(
                      dialogContext,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
        actions: [closeButton(dialogContext)],
      );
    },
  );
}
