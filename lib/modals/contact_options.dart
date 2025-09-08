import 'package:flutter/material.dart';
import 'package:qr_code_app/bottom_nav.dart';
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

  // Affichage du dialog
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        title: Text(lang['title']),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(buttons.length, (index) {
              final button = buttons[index];
              return TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                  foregroundColor: WidgetStateProperty.all<Color>(
                    Colors.white,
                  ), // texte et icône
                ),

                icon: Icon(button['icon'] as IconData),
                label: Text(
                  button['title'] as String,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final action = button['action'] as Future<void> Function();
                  await action();

                  if (!dialogContext.mounted) return;
                  toastification.show(
                    context:
                        context, // optional if you use ToastificationWrapper
                    type: ToastificationType.success,
                    style: ToastificationStyle.fillColored,
                    autoCloseDuration: const Duration(seconds: 3),
                    title: Text('${button['title']} successful'),
                    alignment: Alignment.topRight,
                    direction: TextDirection.ltr,
                    animationDuration: const Duration(milliseconds: 300),
                    animationBuilder: (context, animation, alignment, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    icon: const Icon(Icons.check_circle, size: 30),
                    showIcon: true,
                    primaryColor: Colors.green,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
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
              );
            }),
          ),
        ),
        actions: [closeButton(dialogContext)],
      );
    },
  );
}

Future<void> updateOnlyEmptyFields(Map<String, dynamic> vcard) async {
  final contact = await getContactByName(
    nom: vcard["nom"],
    prenom: vcard["prenom"],
  );
  if (contact == null) return;

  contact.forEach((key, value) {
    if ((value.toString().isEmpty) &&
        vcard[key] != null &&
        vcard[key].toString().isNotEmpty) {
      contact[key] = vcard[key];
    }
  });

  await updateContactOnPhone(contact);
}
