import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/components/contact_app.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Pushes [MultiContactPickerPage] so the user picks device contacts,
/// then persists each selection as a VCard row.
Future<void> importContacts(BuildContext context) async {
  await PhoneContacts.verifyPermission();
  final contacts = await FlutterContacts.getContacts(withProperties: true);
  if (contacts.isEmpty || !context.mounted) return;

  final popped = await redirect(
    context,
    MultiContactPickerPage(contacts: contacts),
  );
  // Use is-check instead of as-cast: any future pop returning a different
  // type (system back gesture, forced dispose) becomes a no-op rather than
  // crashing the importer.
  if (popped is! List<Contact> || popped.isEmpty) return;
  final contactsMap = PhoneContacts.toMapList(popped);

  for (final contactMap in contactsMap) {
    await createVCard(contactMap);
  }
}
