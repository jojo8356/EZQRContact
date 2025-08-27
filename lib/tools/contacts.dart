import 'package:contacts_service/contacts_service.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<void> addContactToPhone(Map<String, dynamic> contactData) async {
  // Demander permission
  verifContact();

  // Créer contact
  final newContact = Contact(
    givenName: contactData['prenom'] ?? '',
    familyName: contactData['nom'] ?? '',
    middleName: contactData['nom2'],
    prefix: contactData['prefixe'],
    suffix: contactData['suffixe'],
    company: contactData['org'],
    jobTitle: contactData['job'],
    emails: contactData['email'] != null
        ? [Item(label: 'email', value: contactData['email'])]
        : [],
    phones: [
      if (contactData['tel_work'] != null)
        Item(label: 'work', value: contactData['tel_work']),
      if (contactData['tel_home'] != null)
        Item(label: 'home', value: contactData['tel_home']),
    ],
    postalAddresses: [
      if (contactData['adr_work'] != null)
        PostalAddress(label: 'work', street: contactData['adr_work']),
      if (contactData['adr_home'] != null)
        PostalAddress(label: 'home', street: contactData['adr_home']),
    ],
  );

  await ContactsService.addContact(newContact);
}

Future<bool> contactExists({String? prenom, String? nom}) async {
  verifContact();
  if ((prenom == null || prenom.trim().isEmpty) &&
      (nom == null || nom.trim().isEmpty)) {
    throw Exception("Donner au moins prénom ou nom");
  }

  final contacts = await ContactsService.getContacts();
  final prenomLower = prenom;
  final nomLower = nom;

  return contacts.any((c) {
    final givenName = c.givenName ?? '';
    final familyName = c.familyName ?? '';
    final matchPrenom = prenomLower != null && givenName == prenomLower;
    final matchNom = nomLower != null && familyName == nomLower;
    return matchPrenom && matchNom;
  });
}

Future<List<Contact>> getContactByName({String? prenom, String? nom}) async {
  // Vérifier qu'au moins un paramètre est donné
  if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
    throw Exception("Donner au moins prénom ou nom");
  }

  verifContact();

  final contacts = await ContactsService.getContacts();
  return contacts
      .where(
        (c) => (prenom != null && nom != null)
            ? (c.givenName ?? '') == prenom && (c.familyName ?? '') == nom
            : (prenom != null
                  ? (c.givenName ?? '') == prenom
                  : (c.familyName ?? '') == nom),
      )
      .toList();
}

Future<void> updateContactOnPhone(Map<String, dynamic> contactData) async {
  final prenom = contactData['prenom'] as String?;
  final nom = contactData['nom'] as String?;

  if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
    throw Exception("Donner au moins prénom ou nom pour modifier un contact");
  }

  verifContact();

  final existingContacts = await getContactByName(prenom: prenom, nom: nom);
  if (existingContacts.isEmpty) {
    throw Exception("Aucun contact trouvé pour modification");
  }
  for (var contact in existingContacts) {
    contact.givenName = prenom ?? contact.givenName;
    contact.familyName = nom ?? contact.familyName;
    contact.middleName = contactData['nom2'] ?? contact.middleName;
    contact.prefix = contactData['prefixe'] ?? contact.prefix;
    contact.suffix = contactData['suffixe'] ?? contact.suffix;
    contact.company = contactData['org'] ?? contact.company;
    contact.jobTitle = contactData['job'] ?? contact.jobTitle;

    // Emails
    if (contactData['email'] != null) {
      contact.emails = [Item(label: 'email', value: contactData['email'])];
    }

    // Téléphones
    final phones = <Item>[];
    if (contactData['tel_work'] != null) {
      phones.add(Item(label: 'work', value: contactData['tel_work']));
    }
    if (contactData['tel_home'] != null) {
      phones.add(Item(label: 'home', value: contactData['tel_home']));
    }
    if (phones.isNotEmpty) contact.phones = phones;

    // Adresses
    final addresses = <PostalAddress>[];
    if (contactData['adr_work'] != null) {
      addresses.add(
        PostalAddress(label: 'work', street: contactData['adr_work']),
      );
    }
    if (contactData['adr_home'] != null) {
      addresses.add(
        PostalAddress(label: 'home', street: contactData['adr_home']),
      );
    }
    if (addresses.isNotEmpty) contact.postalAddresses = addresses;
    await ContactsService.updateContact(contact);
  }
}
