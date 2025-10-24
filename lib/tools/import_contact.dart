import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/components/contact_app.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'db/db.dart';
import 'tools.dart';

Future<void> importContacts(context) async {
  await PhoneContacts.verifyPermission();
  final contacts = await FlutterContacts.getContacts(withProperties: true);
  if (contacts.isEmpty || !context.mounted) return;

  final selectedContacts = await redirect(
    context,
    MultiContactPickerPage(contacts: contacts),
  );
  if (selectedContacts == null || selectedContacts.isEmpty) return;
  final contactsMap = PhoneContacts.toMapList(selectedContacts);

  for (var contactMap in contactsMap) {
    await createVCard(contactMap);
  }
}
