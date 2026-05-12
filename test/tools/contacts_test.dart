import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/tools/contacts.dart';

/// Builds a fully populated [Contact] fixture used across several tests.
Contact _buildFullContact() {
  return Contact()
    ..id = 'test-id'
    ..name.first = 'Marie'
    ..name.last = 'Dupont'
    ..organizations = [Organization(company: 'Acme', title: 'CTO')]
    ..phones = [
      Phone('+33612345678', label: PhoneLabel.work),
      Phone('+33123456789', label: PhoneLabel.home),
    ]
    ..emails = [Email('marie@acme.fr')]
    ..addresses = [
      Address('12 rue de la Paix', label: AddressLabel.work),
      Address('5 villa des Lilas'),
    ];
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
      final c = Contact()
        ..name.first = 'Test'
        ..phones = [];
      final map = PhoneContacts.contactToMap(c);
      expect(map['tel_work'], equals(''));
      expect(map['tel_home'], equals(''));
    });

    test('contact with no organizations produces empty org and job', () {
      final c = Contact()
        ..name.first = 'Test'
        ..organizations = [];
      final map = PhoneContacts.contactToMap(c);
      expect(map['org'], equals(''));
      expect(map['job'], equals(''));
    });

    test('contact with no emails produces empty email', () {
      final c = Contact()
        ..name.first = 'Test'
        ..emails = [];
      final map = PhoneContacts.contactToMap(c);
      expect(map['email'], equals(''));
    });

    test('photo is always empty string', () {
      final map = PhoneContacts.contactToMap(_buildFullContact());
      expect(map['photo'], equals(''));
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
      final c2 = Contact()
        ..id = 'id2'
        ..name.first = 'Jean'
        ..name.last = 'Martin';
      final result = PhoneContacts.toMapList([_buildFullContact(), c2]);
      expect(result.length, equals(2));
      expect(result[0]['prenom'], equals('Marie'));
      expect(result[1]['prenom'], equals('Jean'));
    });
  });
}
