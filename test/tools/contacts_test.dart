import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/tools/contacts.dart';

/// 1×1 PNG. Used as a device-contact photo in mapping tests.
const _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0xD4, 0xEF, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// Builds a fully populated [Contact] fixture used across several tests.
Contact _buildFullContact() {
  return const Contact(
    id: 'test-id',
    name: Name(first: 'Marie', last: 'Dupont'),
    organizations: [Organization(name: 'Acme', jobTitle: 'CTO')],
    phones: [
      Phone(number: '+33612345678', label: Label(PhoneLabel.work)),
      Phone(number: '+33123456789', label: Label(PhoneLabel.home)),
    ],
    emails: [Email(address: 'marie@acme.fr')],
    addresses: [
      Address(
        street: '12 rue de la Paix',
        formatted: '12 rue de la Paix',
        label: Label(AddressLabel.work),
      ),
      Address(
        street: '5 villa des Lilas',
        formatted: '5 villa des Lilas',
      ),
    ],
  );
}

void main() {
  group('PhoneContacts.contactToMap', () {
    test('maps id, prenom, nom correctly', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['id'], equals('test-id'));
      expect(map['prenom'], equals('Marie'));
      expect(map['nom'], equals('Dupont'));
    });

    test('maps org and job from organizations', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['org'], equals('Acme'));
      expect(map['job'], equals('CTO'));
    });

    test('maps tel_work from phone with PhoneLabel.work', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['tel_work'], equals('+33612345678'));
    });

    test('maps tel_home from phone with PhoneLabel.home', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['tel_home'], equals('+33123456789'));
    });

    test('maps email from first email', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['email'], equals('marie@acme.fr'));
    });

    test('maps adr_work from address with AddressLabel.work', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['adr_work'], equals('12 rue de la Paix'));
    });

    test('maps adr_home from address without work label', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['adr_home'], equals('5 villa des Lilas'));
    });

    test('contact with no phones produces empty tel_work and tel_home', () {
      const c = Contact(name: Name(first: 'Test'));
      final map = PhoneContacts.contactToMap(c);
      expect(map['tel_work'], equals(''));
      expect(map['tel_home'], equals(''));
    });

    test('contact with no organizations produces empty org and job', () {
      const c = Contact(name: Name(first: 'Test'));
      final map = PhoneContacts.contactToMap(c);
      expect(map['org'], equals(''));
      expect(map['job'], equals(''));
    });

    test('contact with no emails produces empty email', () {
      const c = Contact(name: Name(first: 'Test'));
      final map = PhoneContacts.contactToMap(c);
      expect(map['email'], equals(''));
    });

    test('photo is empty when the device contact has none', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['photo'], equals(''));
    });

    test('photo becomes a data URI from fullSize bytes', () {
      final png = Uint8List.fromList(_tinyPng);
      final contact = Contact(
        id: 'with-photo',
        name: const Name(first: 'Marie', last: 'Dupont'),
        photo: Photo(fullSize: png),
      );
      final map = PhoneContacts.contactToMap(contact);
      final photo = map['photo'] as String;
      expect(photo.startsWith('data:image/png;base64,'), isTrue);
      final b64 = photo.substring('data:image/png;base64,'.length);
      expect(base64Decode(b64), png);
    });

    test('photo falls back to thumbnail when fullSize is missing', () {
      final png = Uint8List.fromList(_tinyPng);
      final contact = Contact(
        id: 'thumb',
        name: const Name(first: 'Marie', last: 'Dupont'),
        photo: Photo(thumbnail: png),
      );
      final map = PhoneContacts.contactToMap(contact);
      expect(
        (map['photo'] as String).startsWith('data:image/png;base64,'),
        isTrue,
      );
    });
  });

  group('PhoneContacts.getTitle', () {
    test('vcard with prenom + nom returns full name', () {
      final input = {
        'type': 'vcard',
        'data': {'prenom': 'Marie', 'nom': 'Dupont', 'org': 'Acme'},
      };
      expect(PhoneContacts.getTitle(input), equals('Marie Dupont'));
    });

    test('vcard with only prenom returns prenom', () {
      final input = {
        'type': 'vcard',
        'data': {'prenom': 'Marie', 'nom': '', 'org': 'Acme'},
      };
      expect(PhoneContacts.getTitle(input), equals('Marie'));
    });

    test('vcard with only nom returns nom', () {
      final input = {
        'type': 'vcard',
        'data': {'prenom': '', 'nom': 'Dupont', 'org': 'Acme'},
      };
      expect(PhoneContacts.getTitle(input), equals('Dupont'));
    });

    test('vcard with empty name falls back to org', () {
      final input = {
        'type': 'vcard',
        'data': {'prenom': '', 'nom': '', 'org': 'Acme'},
      };
      expect(PhoneContacts.getTitle(input), equals('Acme'));
    });

    test('simple type returns text value', () {
      final input = {
        'type': 'simple',
        'data': {'text': 'https://example.com'},
      };
      expect(PhoneContacts.getTitle(input), equals('https://example.com'));
    });

    test('unknown type returns empty string', () {
      final input = {
        'type': 'unknown',
        'data': {'text': 'something'},
      };
      expect(PhoneContacts.getTitle(input), equals(''));
    });

    test('data not a Map returns empty string', () {
      final input = {'type': 'vcard', 'data': 'not-a-map'};
      expect(PhoneContacts.getTitle(input), equals(''));
    });
  });

  group('PhoneContacts.toMapList', () {
    test('empty list returns empty list', () {
      expect(PhoneContacts.toMapList([]), isEmpty);
    });

    test('single contact is mapped correctly', () {
      final result = PhoneContacts.toMapList([_buildFullContact()]);
      expect(result.length, equals(1));
      expect(result.first['prenom'], equals('Marie'));
    });

    test('two contacts produces list of two maps', () {
      const c2 = Contact(
        id: 'id2',
        name: Name(first: 'Jean', last: 'Martin'),
      );
      final result = PhoneContacts.toMapList([_buildFullContact(), c2]);
      expect(result.length, equals(2));
      expect(result[0]['prenom'], equals('Marie'));
      expect(result[1]['prenom'], equals('Jean'));
    });
  });

  group('PhoneContacts OS writes respect permission', () {
    tearDown(() {
      PhoneContacts.debugVerifyPermission = null;
      PhoneContacts.debugOsWriteAttempts = 0;
    });

    test('add is a no-op when contacts are denied', () async {
      PhoneContacts.debugVerifyPermission = () async => false;
      PhoneContacts.debugOsWriteAttempts = 0;
      final ok = await PhoneContacts.add({
        'prenom': 'Marie',
        'nom': 'Dupont',
        'tel_work': '+33612345678',
      });
      expect(ok, isFalse);
      expect(PhoneContacts.debugOsWriteAttempts, 0);
    });

    test('update is a no-op when contacts are denied', () async {
      PhoneContacts.debugVerifyPermission = () async => false;
      PhoneContacts.debugOsWriteAttempts = 0;
      final ok = await PhoneContacts.update({
        'prenom': 'Marie',
        'nom': 'Dupont',
      });
      expect(ok, isFalse);
      expect(PhoneContacts.debugOsWriteAttempts, 0);
    });

    test('getAll is empty when contacts are denied', () async {
      PhoneContacts.debugVerifyPermission = () async => false;
      final all = await PhoneContacts.getAll();
      expect(all, isEmpty);
    });
  });
}
