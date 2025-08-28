import 'package:flutter/material.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> showVCardPopup(
  BuildContext context,
  Map<String, dynamic> data, {
  required bool isVCard,
}) async {
  final db = QRDatabase();

  if (!isVCard) return;

  final vcard = await db.getVCardById(data['id']) ?? {};
  final existingDB = await db.verifContact(
    nom: vcard["nom"],
    prenom: vcard["prenom"],
  );
  final existingTel = await contactExists(
    nom: vcard["nom"],
    prenom: vcard["prenom"],
  );

  String message = '';

  if (!existingTel && (existingDB == null || existingDB.isEmpty)) {
    await createContact(vcard);
    message = "Contact ajouté dans la DB et téléphone ✅";
  } else if (!existingTel) {
    await addContactToPhone(vcard);
    message = "Contact ajouté dans le téléphone ✅";
  } else if (existingDB == null || existingDB.isEmpty) {
    await createVCard(vcard);
    message = "Contact ajouté dans la DB ✅";
  } else {
    message = "Contact déjà existant";
  }

  // Vérifications et mises à jour
  if (!await compare2VCard(await db.getVCardById(vcard["id"]), vcard)) {
    await db.modifContact(vcard);
    message += "\nDB mise à jour";
  }
  if (!await compare2VCard(
    await getContactByName(nom: vcard["nom"], prenom: vcard["prenom"]),
    vcard,
  )) {
    await updateContactOnPhone(vcard);
    message += "\nTéléphone mis à jour";
  }

  if (!context.mounted) return;

  // Affichage du popup
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Info Contact'),
      content: Text(message),
      actions: [closeButton(context)],
    ),
  );
}
