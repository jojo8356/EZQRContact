import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shouldShowGuide / markGuideShown', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('shouldShowGuide() returns true when no pref stored', () async {
      expect(await shouldShowGuide(), isTrue);
    });

    test('shouldShowGuide() returns false after markGuideShown()', () async {
      await markGuideShown();
      expect(await shouldShowGuide(), isFalse);
    });

    test('markGuideShown() is idempotent — calling twice still returns false',
        () async {
      await markGuideShown();
      await markGuideShown();
      expect(await shouldShowGuide(), isFalse);
    });
  });

  group('getDateDays', () {
    test('returns string matching dd/MM/yyyy format', () {
      expect(getDateDays(), matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')));
    });

    test('day, month, year match DateTime.now()', () {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();
      expect(getDateDays(), equals('$day/$month/$year'));
    });
  });

  group('mapToControllers', () {
    late Map<String, TextEditingController> controllers;

    tearDown(() {
      for (final c in controllers.values) {
        c.dispose();
      }
    });

    test('creates exactly 13 controllers', () {
      controllers = mapToControllers({});
      expect(controllers.length, equals(13));
      for (final key in [
        'nom',
        'prenom',
        'nom2',
        'prefixe',
        'suffixe',
        'org',
        'job',
        'photo',
        'tel_work',
        'tel_home',
        'adr_work',
        'adr_home',
        'email',
      ]) {
        expect(
          controllers.containsKey(key),
          isTrue,
          reason: 'missing key $key',
        );
      }
    });

    test('pre-fills controllers from map values', () {
      controllers = mapToControllers({'nom': 'Dupont', 'prenom': 'Marie'});
      expect(controllers['nom']!.text, equals('Dupont'));
      expect(controllers['prenom']!.text, equals('Marie'));
    });

    test('missing map keys produce empty string controllers', () {
      controllers = mapToControllers({});
      expect(controllers['org']!.text, equals(''));
    });

    test('null values produce empty string controllers', () {
      controllers = mapToControllers({'nom': null});
      expect(controllers['nom']!.text, equals(''));
    });
  });

  group('extractValues', () {
    late Map<String, TextEditingController> controllers;

    tearDown(() {
      for (final c in controllers.values) {
        c.dispose();
      }
    });

    test('returns map with same keys as input', () {
      controllers = {
        'a': TextEditingController(text: 'hello'),
        'b': TextEditingController(text: 'world'),
      };
      final values = extractValues(controllers);
      expect(values.keys, containsAll(['a', 'b']));
      expect(values.length, equals(2));
    });

    test('returns current text of each controller', () {
      controllers = {'name': TextEditingController(text: 'Alice')};
      expect(extractValues(controllers)['name'], equals('Alice'));
    });

    test('empty controller produces empty string in output', () {
      controllers = {'x': TextEditingController()};
      expect(extractValues(controllers)['x'], equals(''));
    });

    test('updated controller text is reflected in output', () {
      controllers = {'field': TextEditingController(text: 'original')};
      controllers['field']!.text = 'updated';
      expect(extractValues(controllers)['field'], equals('updated'));
    });
  });

  group('getKeys', () {
    test('returns list of keys in insertion order', () {
      final map = <String, dynamic>{'b': 2, 'a': 1, 'c': 3};
      expect(getKeys(map), equals(['b', 'a', 'c']));
    });

    test('empty map returns empty list', () {
      expect(getKeys({}), isEmpty);
    });
  });
}
