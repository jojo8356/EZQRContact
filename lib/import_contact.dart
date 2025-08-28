import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/contact_app.dart';
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

  await createContact(selectedContacts);
}
