import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Wrapper around `flutter_contacts` providing the small subset of
/// device-contacts operations EZQRContact needs (permission, lookup by
/// name, conversion to/from the legacy `Map<String, dynamic>` shape).
class PhoneContacts {
  /// Vérifie et demande la permission contacts
  static Future<bool> verifyPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }

  /// Récupère tous les contacts avec propriétés et comptes
  static Future<List<Contact>> getAll() async {
    await verifyPermission();
    return FlutterContacts.getContacts(
      withProperties: true,
      withAccounts: true,
    );
  }

  /// Récupère l'ID d'un contact selon prénom et/ou nom
  static Future<String?> getId({String? prenom, String? nom}) async {
    final contacts = await getAll();
    for (final contact in contacts) {
      final first = contact.name.first;
      final last = contact.name.last;
      final match = (prenom != null && nom != null)
          ? (first == prenom && last == nom)
          : prenom != null
          ? first == prenom
          : last == nom;
      if (match) return contact.id;
    }
    return null;
  }

  /// Vérifie si un contact existe
  static Future<bool> exists({String? prenom, String? nom}) async {
    if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
      throw Exception('Donner au moins prénom ou nom');
    }
    final contacts = await getAll();
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

  /// Convertit un contact FlutterContacts en Map
  static Map<String, dynamic> contactToMap(Contact c) => {
    'id': c.id,
    'prenom': c.name.first,
    'nom': c.name.last,
    'nom2': c.name.middle,
    'prefixe': c.name.prefix,
    'suffixe': c.name.suffix,
    'org': c.organizations.isNotEmpty ? c.organizations.first.company : '',
    'job': c.organizations.isNotEmpty ? c.organizations.first.title : '',
    'photo': '',
    'tel_work': c.phones
        .firstWhere(
          (p) => p.label.name == 'work',
          orElse: () => Phone('', label: PhoneLabel.work),
        )
        .number,
    'tel_home': c.phones
        .firstWhere(
          (p) => p.label.name == 'home',
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
          orElse: () => Address(''),
        )
        .address,
    'email': c.emails.isNotEmpty ? c.emails.first.address : '',
    'rev': '',
  };

  /// Récupère un contact sous forme de Map par prénom et/ou nom
  static Future<Map<String, dynamic>?> getByName({
    String? prenom,
    String? nom,
  }) async {
    if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
      throw Exception('Donner au moins prénom ou nom');
    }
    final contacts = await getAll();
    final contact = contacts.firstWhere((c) {
      final first = c.name.first;
      final last = c.name.last;
      return (prenom != null && nom != null)
          ? first == prenom && last == nom
          : prenom != null
          ? first == prenom
          : last == nom;
    });
    return contactToMap(contact);
  }

  /// Ajoute un contact à l'appareil
  static Future<void> add(Map<String, dynamic> data) async {
    String s(String key) => (data[key] as String?) ?? '';
    String? sn(String key) => data[key] as String?;
    final newContact = Contact()
      ..name.first = s('prenom')
      ..name.last = s('nom')
      ..name.middle = sn('nom2') ?? ''
      ..name.prefix = sn('prefixe') ?? ''
      ..name.suffix = sn('suffixe') ?? ''
      ..organizations = [
        if (data['org'] != null || data['job'] != null)
          Organization(company: s('org'), title: s('job')),
      ]
      ..emails = [
        if (data['email'] != null) Email(s('email')),
      ]
      ..phones = [
        if (data['tel_work'] != null)
          Phone(s('tel_work'), label: PhoneLabel.work),
        if (data['tel_home'] != null)
          Phone(s('tel_home'), label: PhoneLabel.home),
      ]
      ..addresses = [
        if (data['adr_work'] != null)
          Address(s('adr_work'), label: AddressLabel.work),
        if (data['adr_home'] != null)
          Address(s('adr_home')),
      ];

    await newContact.insert();
  }

  /// Met à jour un contact existant
  static Future<void> update(Map<String, dynamic> data) async {
    final prenom = data['prenom']?.toString();
    final nom = data['nom']?.toString();
    if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
      throw Exception('Donner au moins prénom ou nom pour modifier un contact');
    }

    final contactId = await getId(prenom: prenom, nom: nom);
    if (contactId == null) throw Exception('Contact introuvable');

    final contact = await FlutterContacts.getContact(
      contactId,
      withAccounts: true,
    );
    if (contact == null) return;

    contact.name.first = prenom ?? contact.name.first;
    contact.name.last = nom ?? contact.name.last;
    contact.name.middle = data['nom2']?.toString() ?? contact.name.middle;
    contact.name.prefix = data['prefixe']?.toString() ?? contact.name.prefix;
    contact.name.suffix = data['suffixe']?.toString() ?? contact.name.suffix;

    contact.organizations = [
      Organization(
        company: data['org']?.toString() ?? '',
        title: data['job']?.toString() ?? '',
      ),
    ];

    if (data['email'] != null) {
      contact.emails = [
        Email(data['email'].toString()),
      ];
    }

    final phones = <Phone>[];
    if (data['tel_work'] != null) {
      phones.add(Phone(data['tel_work'].toString(), label: PhoneLabel.work));
    }
    if (data['tel_home'] != null) {
      phones.add(Phone(data['tel_home'].toString(), label: PhoneLabel.home));
    }
    if (phones.isNotEmpty) contact.phones = phones;

    final addresses = <Address>[];
    if (data['adr_work'] != null) {
      addresses.add(
        Address(data['adr_work'].toString(), label: AddressLabel.work),
      );
    }
    if (data['adr_home'] != null) {
      addresses.add(
        Address(data['adr_home'].toString()),
      );
    }
    if (addresses.isNotEmpty) contact.addresses = addresses;

    await contact.update();
  }

  /// Convertit une liste de contacts en liste de Map
  static List<Map<String, dynamic>> toMapList(List<Contact> contacts) {
    return contacts.map(contactToMap).toList();
  }

  /// Returns a display title for a stored entry. [input] must contain a
  /// `type` (`'vcard'` or `'simple'`) and a `data` map. Falls back to '' on
  /// unknown types or empty fields.
  static String getTitle(Map<String, dynamic> input) {
    final type = input['type'];
    final data = input['data'];

    if (type == 'vcard' && data is Map<String, dynamic>) {
      final prenom = (data['prenom'] as String?) ?? '';
      final nom = (data['nom'] as String?) ?? '';
      final org = (data['org'] as String?) ?? '';
      if (prenom.isNotEmpty && nom.isNotEmpty) return '$prenom $nom';
      if (prenom.isNotEmpty || nom.isNotEmpty) return '$prenom$nom';
      return org;
    }

    if (type == 'simple' && data is Map<String, dynamic>) {
      return (data['text'] as String?) ?? '';
    }

    return '';
  }

  /// Returns the contact photo bytes, or null when [c] has no photo set.
  static Future<Uint8List?> getPhoto(Contact c) async {
    final photo = c.photo;
    return photo;
  }
}
