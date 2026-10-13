import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Wrapper around `flutter_contacts` providing the small subset of
/// device-contacts operations EZQRContact needs (permission, lookup by
/// name, conversion to/from the legacy `Map<String, dynamic>` shape).
class PhoneContacts {
  static const Set<ContactProperty> _fullProps = ContactProperties.all;

  /// Test seam. When set, [verifyPermission] returns this instead of
  /// talking to the OS.
  @visibleForTesting
  static Future<bool> Function()? debugVerifyPermission;

  /// OS create/update attempts after a granted permission check.
  @visibleForTesting
  static int debugOsWriteAttempts = 0;

  /// Asks for contacts access when missing. Returns false on deny,
  /// permanent deny, or restricted — never throws.
  static Future<bool> verifyPermission() async {
    final override = debugVerifyPermission;
    if (override != null) {
      return override();
    }
    var status = await Permission.contacts.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    }
    status = await Permission.contacts.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }
    return false;
  }

  /// Récupère tous les contacts avec propriétés
  static Future<List<Contact>> getAll() async {
    final granted = await verifyPermission();
    if (!granted) {
      return <Contact>[];
    }
    return FlutterContacts.getAll(properties: _fullProps);
  }

  /// Récupère l'ID d'un contact selon prénom et/ou nom
  static Future<String?> getId({String? prenom, String? nom}) async {
    final contacts = await getAll();
    for (final contact in contacts) {
      final first = contact.name?.first ?? '';
      final last = contact.name?.last ?? '';
      late final bool match;
      if (prenom != null && nom != null) {
        match = first == prenom && last == nom;
      } else if (prenom != null) {
        match = first == prenom;
      } else {
        match = last == nom;
      }
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
      final first = c.name?.first ?? '';
      final last = c.name?.last ?? '';
      final matchFirst = prenom != null && first == prenom;
      final matchLast = nom != null && last == nom;
      if (prenom != null && nom != null) {
        return matchFirst && matchLast;
      }
      return matchFirst || matchLast;
    });
  }

  static String _orgName(Contact c) {
    if (c.organizations.isEmpty) return '';
    return c.organizations.first.name ?? '';
  }

  static String _orgTitle(Contact c) {
    if (c.organizations.isEmpty) return '';
    return c.organizations.first.jobTitle ?? '';
  }

  static String _emailOf(Contact c) {
    if (c.emails.isEmpty) return '';
    return c.emails.first.address;
  }

  static String _phoneOf(Contact c, PhoneLabel wanted) {
    for (final p in c.phones) {
      if (p.label.label == wanted) return p.number;
    }
    return '';
  }

  static String _addressLine(Address a) {
    final parts = <String>[];
    final street = a.street;
    final city = a.city;
    final state = a.state;
    final postal = a.postalCode;
    final country = a.country;
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (postal != null && postal.isNotEmpty) parts.add(postal);
    if (country != null && country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  static String _addressOf(Contact c, AddressLabel wanted) {
    for (final a in c.addresses) {
      if (a.label.label == wanted) {
        final formatted = a.formatted;
        if (formatted != null && formatted.isNotEmpty) return formatted;
        return _addressLine(a);
      }
    }
    if (wanted == AddressLabel.home && c.addresses.isNotEmpty) {
      final first = c.addresses.first;
      final formatted = first.formatted;
      if (formatted != null && formatted.isNotEmpty) return formatted;
      return _addressLine(first);
    }
    return '';
  }

  /// Convertit un contact FlutterContacts en Map
  static Map<String, dynamic> contactToMap(Contact c) => {
        'id': c.id ?? '',
        'prenom': c.name?.first ?? '',
        'nom': c.name?.last ?? '',
        'nom2': c.name?.middle ?? '',
        'prefixe': c.name?.prefix ?? '',
        'suffixe': c.name?.suffix ?? '',
        'org': _orgName(c),
        'job': _orgTitle(c),
        'photo': '',
        'tel_work': _phoneOf(c, PhoneLabel.work),
        'tel_home': _phoneOf(c, PhoneLabel.home),
        'adr_work': _addressOf(c, AddressLabel.work),
        'adr_home': _addressOf(c, AddressLabel.home),
        'email': _emailOf(c),
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
    for (final c in contacts) {
      final first = c.name?.first ?? '';
      final last = c.name?.last ?? '';
      var match = false;
      if (prenom != null && nom != null) {
        match = first == prenom && last == nom;
      } else if (prenom != null) {
        match = first == prenom;
      } else {
        match = last == nom;
      }
      if (match) return contactToMap(c);
    }
    return null;
  }

  /// Ajoute un contact à l'appareil. Returns false when the OS
  /// permission is missing — the caller must still persist the QR.
  static Future<bool> add(Map<String, dynamic> data) async {
    final granted = await verifyPermission();
    if (!granted) {
      return false;
    }
    debugOsWriteAttempts += 1;
    String s(String key) => (data[key] as String?) ?? '';
    bool has(String key) {
      final v = data[key];
      return v is String && v.isNotEmpty;
    }

    final phones = <Phone>[];
    if (has('tel_work')) {
      phones.add(
        Phone(number: s('tel_work'), label: const Label(PhoneLabel.work)),
      );
    }
    if (has('tel_home')) {
      phones.add(
        Phone(number: s('tel_home'), label: const Label(PhoneLabel.home)),
      );
    }
    final emails = <Email>[];
    if (has('email')) {
      emails.add(Email(address: s('email')));
    }
    final orgs = <Organization>[];
    if (has('org') || has('job')) {
      orgs.add(
        Organization(name: s('org'), jobTitle: s('job')),
      );
    }
    final addresses = <Address>[];
    if (has('adr_work')) {
      addresses.add(
        Address(street: s('adr_work'), label: const Label(AddressLabel.work)),
      );
    }
    if (has('adr_home')) {
      addresses.add(Address(street: s('adr_home')));
    }

    final newContact = Contact(
      name: Name(
        first: s('prenom'),
        last: s('nom'),
        middle: s('nom2'),
        prefix: s('prefixe'),
        suffix: s('suffixe'),
      ),
      phones: phones,
      emails: emails,
      organizations: orgs,
      addresses: addresses,
    );
    try {
      await FlutterContacts.create(newContact);
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  /// Met à jour un contact existant. No-op (false) without permission.
  static Future<bool> update(Map<String, dynamic> data) async {
    final granted = await verifyPermission();
    if (!granted) {
      return false;
    }
    debugOsWriteAttempts += 1;
    final prenom = data['prenom']?.toString();
    final nom = data['nom']?.toString();
    if ((prenom == null || prenom.isEmpty) && (nom == null || nom.isEmpty)) {
      throw Exception('Donner au moins prénom ou nom pour modifier un contact');
    }

    final contactId = await getId(prenom: prenom, nom: nom);
    if (contactId == null) throw Exception('Contact introuvable');

    final contact = await FlutterContacts.get(
      contactId,
      properties: _fullProps,
    );
    if (contact == null) {
      return false;
    }

    final phones = <Phone>[];
    final telWork = data['tel_work']?.toString();
    final telHome = data['tel_home']?.toString();
    if (telWork != null && telWork.isNotEmpty) {
      phones.add(Phone(number: telWork, label: const Label(PhoneLabel.work)));
    }
    if (telHome != null && telHome.isNotEmpty) {
      phones.add(Phone(number: telHome, label: const Label(PhoneLabel.home)));
    }
    final emails = <Email>[];
    final email = data['email']?.toString();
    if (email != null && email.isNotEmpty) {
      emails.add(Email(address: email));
    }
    final addresses = <Address>[];
    final adrWork = data['adr_work']?.toString();
    final adrHome = data['adr_home']?.toString();
    if (adrWork != null && adrWork.isNotEmpty) {
      addresses.add(
        Address(street: adrWork, label: const Label(AddressLabel.work)),
      );
    }
    if (adrHome != null && adrHome.isNotEmpty) {
      addresses.add(Address(street: adrHome));
    }

    final updated = contact.copyWith(
      name: Name(
        first: prenom ?? contact.name?.first,
        last: nom ?? contact.name?.last,
        middle: data['nom2']?.toString() ?? contact.name?.middle,
        prefix: data['prefixe']?.toString() ?? contact.name?.prefix,
        suffix: data['suffixe']?.toString() ?? contact.name?.suffix,
      ),
      organizations: [
        Organization(
          name: data['org']?.toString() ?? '',
          jobTitle: data['job']?.toString() ?? '',
        ),
      ],
      emails: emails,
      phones: phones,
      addresses: addresses,
    );
    try {
      await FlutterContacts.update(updated);
      return true;
    } on Object catch (_) {
      return false;
    }
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
    return c.photo?.fullSize ?? c.photo?.thumbnail;
  }
}
