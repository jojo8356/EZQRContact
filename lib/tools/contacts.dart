import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

Future<List<Contact>> getAllContacts() async {
  await verifContact();

  // Récupérer tous les contacts avec propriétés et comptes
  final contacts = await FlutterContacts.getContacts(
    withProperties: true,
    withAccounts: true,
  );

  return contacts;
}

Future<String?> getContactId({String? prenom, String? nom}) async {
  await verifContact();
  final contacts = await getAllContacts();

  for (var contact in contacts) {
    final first = contact.name.first;
    final last = contact.name.last;

    bool match = (prenom != null && nom != null)
        ? (first == prenom && last == nom)
        : prenom != null
        ? first == prenom
        : last == nom;

    if (match) return contact.id;
  }

  return null;
}

Future<void> addContactToPhone(Map<String, dynamic> contactData) async {
  await verifContact();

  final newContact = Contact()
    ..name.first = contactData['prenom'] ?? ''
    ..name.last = contactData['nom'] ?? ''
    ..name.middle = contactData['nom2']
    ..name.prefix = contactData['prefixe']
    ..name.suffix = contactData['suffixe']
    ..organizations = [
      if (contactData['org'] != null || contactData['job'] != null)
        Organization(
          company: contactData['org'] ?? '',
          title: contactData['job'] ?? '',
        ),
    ]
    ..emails = [
      if (contactData['email'] != null)
        Email(contactData['email'], label: EmailLabel.home),
    ]
    ..phones = [
      if (contactData['tel_work'] != null)
        Phone(contactData['tel_work'], label: PhoneLabel.work),
      if (contactData['tel_home'] != null)
        Phone(contactData['tel_home'], label: PhoneLabel.home),
    ]
    ..addresses = [
      if (contactData['adr_work'] != null)
        Address(contactData['adr_work'], label: AddressLabel.work),
      if (contactData['adr_home'] != null)
        Address(contactData['adr_home'], label: AddressLabel.home),
    ];

  await newContact.insert();
}

Future<bool> contactExists({String? prenom, String? nom}) async {
  if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
    throw Exception("Donner au moins prénom ou nom");
  }

  await verifContact();

  final contacts = await getAllContacts();
  return contacts.any((c) {
    final first = c.name.first;
    final last = c.name.last;
    final matchFirst = prenom != null && first == prenom;
    final matchLast = nom != null && last == nom;
    return (prenom != null && nom != null)
        ? matchFirst && matchLast
        : matchFirst || matchLast;
  });
}

Future<Map<String, String>?> getContactByName({
  String? prenom,
  String? nom,
}) async {
  if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
    throw Exception("Donner au moins prénom ou nom");
  }

  final contacts = await getAllContacts();
  final contact = contacts.firstWhere((c) {
    final first = c.name.first;
    final last = c.name.last;
    return (prenom != null && nom != null)
        ? first == prenom && last == nom
        : prenom != null
        ? first == prenom
        : last == nom;
  });

  return {
    'nom': contact.name.last,
    'prenom': contact.name.first,
    'nom2': '',
    'prefixe': '',
    'suffixe': '',
    'org': contact.organizations.isNotEmpty
        ? contact.organizations.first.company
        : '',
    'job': contact.organizations.isNotEmpty
        ? contact.organizations.first.title
        : '',
    'photo': '',
    'tel_work': contact.phones.firstWhere((p) => p.label.name == 'work').number,
    'tel_home': contact.phones.firstWhere((p) => p.label.name == 'home').number,
    'adr_work': contact.addresses
        .firstWhere((a) => a.label.name == 'work')
        .address,
    'adr_home': contact.addresses
        .firstWhere((a) => a.label.name == 'home')
        .address,
    'email': contact.emails.isNotEmpty ? contact.emails.first.address : '',
    'rev': '',
  };
}

Future<void> updateContactOnPhone(Map<String, dynamic> contactData) async {
  final prenom = contactData['prenom']?.toString();
  final nom = contactData['nom']?.toString();

  if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
    throw Exception("Donner au moins prénom ou nom pour modifier un contact");
  }

  await verifContact();
  final existingContact = await getContactByName(prenom: prenom, nom: nom);
  if (existingContact == null || existingContact.isEmpty) {
    throw Exception("Aucun contact trouvé pour modification");
  }

  final contact = await FlutterContacts.getContact(
    await getContactId(nom: nom, prenom: prenom) ?? '',
    withProperties: true,
    withAccounts: true,
  );

  if (contact == null) return;

  contact.name.first = prenom ?? contact.name.first;
  contact.name.last = nom ?? contact.name.last;
  contact.name.middle = contactData['nom2']?.toString() ?? contact.name.middle;
  contact.name.prefix =
      contactData['prefixe']?.toString() ?? contact.name.prefix;
  contact.name.suffix =
      contactData['suffixe']?.toString() ?? contact.name.suffix;

  contact.organizations = [
    Organization(
      company: contactData['org']?.toString() ?? '',
      title: contactData['job']?.toString() ?? '',
    ),
  ];

  // Emails
  if (contactData['email'] != null) {
    contact.emails = [
      Email(contactData['email'].toString(), label: EmailLabel.home),
    ];
  }

  // Phones
  final phones = <Phone>[];
  if (contactData['tel_work'] != null) {
    phones.add(
      Phone(contactData['tel_work'].toString(), label: PhoneLabel.work),
    );
  }
  if (contactData['tel_home'] != null) {
    phones.add(
      Phone(contactData['tel_home'].toString(), label: PhoneLabel.home),
    );
  }
  if (phones.isNotEmpty) contact.phones = phones;

  // Addresses
  final addresses = <Address>[];
  if (contactData['adr_work'] != null) {
    addresses.add(
      Address(contactData['adr_work'].toString(), label: AddressLabel.work),
    );
  }
  if (contactData['adr_home'] != null) {
    addresses.add(
      Address(contactData['adr_home'].toString(), label: AddressLabel.home),
    );
  }
  if (addresses.isNotEmpty) contact.addresses = addresses;
  await contact.update();
}

List<Map<String, dynamic>> contactsToMapList(List<Contact> contacts) {
  return contacts.map((c) {
    return {
      'id': c.id,
      'prenom': c.name.first,
      'nom': c.name.last,
      'nom2': c.name.middle,
      'prefixe': c.name.prefix,
      'suffixe': c.name.suffix,
      'org': c.organizations.isNotEmpty ? c.organizations.first.company : '',
      'job': c.organizations.isNotEmpty ? c.organizations.first.title : '',
      'photo': '', // à gérer si tu veux les images
      'tel_work': c.phones
          .firstWhere(
            (p) => p.label == PhoneLabel.work,
            orElse: () => Phone('', label: PhoneLabel.work),
          )
          .number,
      'tel_home': c.phones
          .firstWhere(
            (p) => p.label == PhoneLabel.home,
            orElse: () => Phone('', label: PhoneLabel.home),
          )
          .number,
      'adr_work': c.addresses
          .firstWhere(
            (a) => a.label == AddressLabel.work,
            orElse: () => Address('', label: AddressLabel.work),
          )
          .address,
      'adr_home': c.addresses
          .firstWhere(
            (a) => a.label == AddressLabel.home,
            orElse: () => Address('', label: AddressLabel.home),
          )
          .address,
      'email': c.emails.isNotEmpty ? c.emails.first.address : '',
      'rev': '',
    };
  }).toList();
}
