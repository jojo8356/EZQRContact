import 'package:flutter/material.dart';
import 'package:qr_code_app/home_page.dart';
import 'package:qr_code_app/modals/alert.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> showVCardPopup(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final db = QRDatabase();
  if (!isVCard) return;

  final vcard = await db.getVCardById(data['id']) ?? {};

  if (!context.mounted) return;
  final buttons = [
    {
      "title": "Replace contact",
      "action": () async {
        await updateContactOnPhone(vcard);
        await db.modifContact(vcard);
      },
    },
    {
      "title": "Clone Contact",
      "action": () async {
        final cloned = Map<String, dynamic>.from(vcard);
        cloned.remove("id");
        await createContact(cloned);
      },
    },
    {
      "title": "Input empty completed",
      "action": () async {
        await updateOnlyEmptyFields(vcard);
        await db.modifContact(vcard);
      },
    },
  ];

  // Affichage du dialog
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Options Contact"),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(buttons.length, (index) {
              final button = buttons[index];
              return TextButton(
                onPressed: () async {
                  final action = button['action'] as Future<void> Function();
                  await action();

                  if (!dialogContext.mounted) return;

                  Navigator.pushReplacement(
                    dialogContext,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                  AppAlerts.of(context)?.add(
                    Alert.success(
                      message: Text(
                        "${button['title']} successful",
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },

                child: Text(button['title'] as String),
              );
            }),
          ),
        ),
        actions: [closeButton(context)],
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
    if ((value == null || value.toString().isEmpty) &&
        vcard[key] != null &&
        vcard[key].toString().isNotEmpty) {
      contact[key] = vcard[key];
    }
  });

  await updateContactOnPhone(contact);
}
