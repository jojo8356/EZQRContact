import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/contact_app.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'tools/db/db.dart';
import 'tools/tools.dart';

Future<void> importContacts(context) async {
  await verifContact();
  final contacts = await FlutterContacts.getContacts(withProperties: true);
  if (contacts.isEmpty || !context.mounted) return;

  final selectedContacts = await redirect(
    context,
    MultiContactPickerPage(contacts: contacts),
  );
  if (selectedContacts == null || selectedContacts.isEmpty) return;
  final contactsMap = contactsToMapList(selectedContacts);

  for (var contactMap in contactsMap) {
    await createVCard(contactMap);
  }
}
