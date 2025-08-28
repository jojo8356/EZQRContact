import 'package:flutter/material.dart';
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

  // Affichage du dialog
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('detect contact'),
        content: SingleChildScrollView(
          child: ListBody(children: const [Text('What do you want ?')]),
        ),
        actions: [
          // 🔥 Remplacer
          TextButton(
            onPressed: () async {
              // SnackBar avant pop
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text("Replace Contact")),
              );

              await updateContactOnPhone(vcard);
              await db.modifContact(vcard);
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Replace contact"),
          ),

          // ✏️ Compléter champs vides
          TextButton(
            onPressed: () async {
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text("Input empty completed")),
              );

              await updateOnlyEmptyFields(vcard);
              await db.modifContact(vcard);
              Navigator.of(dialogContext).pop();
            },
            child: const Text("complete input empty"),
          ),

          // 🆕 Cloner
          TextButton(
            onPressed: () async {
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text("clone contact")),
              );

              final cloned = Map<String, dynamic>.from(vcard);
              cloned["nom"] = "${vcard["nom"] ?? ""} (Clone)";
              cloned.remove("id");
              await addContactToPhone(cloned);
              await createVCard(cloned);
              Navigator.of(dialogContext).pop();
            },
            child: const Text("clone contact"),
          ),

          closeButton(dialogContext),
        ],
      );
    },
  );
}

/// Mettre à jour uniquement les champs vides
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
