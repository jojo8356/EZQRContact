import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/contact_app.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'tools/db/db.dart';
import 'tools/tools.dart';

Future<void> importContacts(State state) async {
  verifContact();
  final contacts = await FlutterContacts.getContacts(withProperties: true);
  if (contacts.isEmpty || !state.mounted) return;

  final selectedContacts = await redirect(
    state.context,
    MultiContactPickerPage(contacts: contacts),
  );

  if (selectedContacts == null || selectedContacts.isEmpty) return;

  await saveSelectedContacts(selectedContacts);
}

Future<void> saveSelectedContacts(List<Contact> selectedContacts) async {
  for (var contact in selectedContacts) {
    final data = {
      "nom": contact.name.last,
      "prenom": contact.name.first,
      "nom2": "",
      "prefixe": contact.name.prefix,
      "suffixe": contact.name.suffix,
      "org": contact.organizations.isNotEmpty
          ? contact.organizations.first.company
          : "",
      "job": contact.organizations.isNotEmpty
          ? contact.organizations.first.title
          : "",
      "photo": contact.photo != null
          ? String.fromCharCodes(contact.photo!)
          : "",
      "tel_home": contact.phones.isNotEmpty ? contact.phones.first.number : "",
      "tel_work": contact.phones.length > 1 ? contact.phones[1].number : "",
      "adr_work": contact.addresses.isNotEmpty
          ? contact.addresses.first.address
          : "",
      "adr_home": contact.addresses.length > 1
          ? contact.addresses[1].address
          : "",
      "email": contact.emails.isNotEmpty ? contact.emails.first.address : "",
    };

    final vcardString = generateVCardFromData(data);
    final id = await createVCard(data);
    await saveQrCode(vcardString, id);
  }
}
