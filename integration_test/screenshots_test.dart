// Captures the six README screenshots into docs/screenshots/.
//
//   ./scripts/capture_screenshots.sh
//   ./scripts/capture_screenshots.sh <device-id>
//
// Filenames must match README.md:
//   home.png, home-dark.png, vcard-form.png, scanner.png,
//   collection.png, collection-dark.png
//
// Demo contacts only (Marie Dupont, Jean Martin). No personal data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/main.dart' as app;
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _github = 'https://github.com/jojo8356/EZQRContact';

Future<void> _skipFirstRunGates() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  await prefs.setInt('guideShown', 1);
  await prefs.setString('lang_override', 'en');
}

Future<void> seedSampleData() async {
  final db = QRDatabase();

  final vcards = await db.getAllVCards();
  var hasMarie = false;
  var hasJean = false;
  for (final row in vcards) {
    if (row['prenom'] == 'Marie' && row['nom'] == 'Dupont') {
      hasMarie = true;
    }
    if (row['prenom'] == 'Jean' && row['nom'] == 'Martin') {
      hasJean = true;
    }
  }
  if (!hasMarie) {
    await db.insertVCard({
      'nom': 'Dupont',
      'prenom': 'Marie',
      'nom2': '',
      'prefixe': '',
      'suffixe': '',
      'org': 'Demo Corp',
      'job': 'Sales Representative',
      'photo': '',
      'tel_work': '+33 6 12 34 56 78',
      'tel_home': '',
      'adr_work': '1 rue Demo, 75001 Paris',
      'adr_home': '',
      'email': 'marie@example.com',
      'rev': '20260510T194800Z',
      'clone': 0,
    });
  }
  if (!hasJean) {
    await db.insertVCard({
      'nom': 'Martin',
      'prenom': 'Jean',
      'nom2': '',
      'prefixe': '',
      'suffixe': '',
      'org': 'TechCo',
      'job': 'CTO',
      'photo': '',
      'tel_work': '+33 7 98 76 54 32',
      'tel_home': '',
      'adr_work': '',
      'adr_home': '',
      'email': 'jean.martin@example.com',
      'rev': '20260510T194800Z',
      'clone': 0,
    });
  }

  final simples = await db.getAllSimpleQR();
  var hasGithub = false;
  for (final row in simples) {
    if (row['text'] == _github) {
      hasGithub = true;
    }
  }
  if (!hasGithub) {
    await db.insertSimpleQR(_github, null);
  }
}

class AppDeadException implements Exception {
  @override
  String toString() => 'App is no longer running, aborting test.';
}

Future<void> pumpQuiet(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool isAppAlive(WidgetTester tester) {
    return find.byType(MaterialApp).evaluate().isNotEmpty;
  }

  void abortIfDead(WidgetTester tester) {
    if (!isAppAlive(tester)) {
      // ignore: avoid_print
      print('[abort] app is dead, stopping test');
      throw AppDeadException();
    }
  }

  Future<bool> tryShoot(
    WidgetTester tester,
    String name, {
    Future<void> Function()? before,
  }) async {
    abortIfDead(tester);
    try {
      if (before != null) {
        await before();
      }
      abortIfDead(tester);
      await pumpQuiet(tester);
      await binding.takeScreenshot(name);
      // ignore: avoid_print
      print('[ok] captured $name');
      return true;
    } on AppDeadException {
      rethrow;
    } on Exception catch (e) {
      // ignore: avoid_print
      print('[skip] $name: $e');
      return false;
    }
  }

  Future<void> launchApp(WidgetTester tester, {required bool dark}) async {
    await _skipFirstRunGates();
    darkProv.forceSetDarkMode(dark);
    app.main();
    await pumpQuiet(tester, frames: 30);
    await seedSampleData();
    await binding.convertFlutterSurfaceToImage();
    await pumpQuiet(tester, frames: 5);
  }

  Future<void> fillVCardForm(WidgetTester tester) async {
    final fields = find.byType(TextField);
    final count = fields.evaluate().length;
    Future<void> enter(int index, String value) async {
      if (index >= count) {
        return;
      }
      final target = fields.at(index);
      await tester.ensureVisible(target);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(target, value);
    }

    // Order matches GenerateVCardQRCode.fieldKeys (photo is not a TextField).
    await enter(0, 'Dupont');
    await enter(1, 'Marie');
    await enter(5, 'Demo Corp');
    await enter(6, 'Sales Representative');
    await enter(7, '+33 6 12 34 56 78');
    await enter(11, 'marie@example.com');
    await tester.pump(const Duration(milliseconds: 300));
  }

  NavigatorState rootNav(WidgetTester tester) {
    return Navigator.of(tester.element(find.byType(MaterialApp)));
  }

  testWidgets('home, vcard form, collection (light + dark)', (tester) async {
    await launchApp(tester, dark: false);

    await tryShoot(tester, 'home');

    await tryShoot(
      tester,
      'vcard-form',
      before: () async {
        await tester.tap(find.byIcon(Icons.contact_page_outlined).first);
        await pumpQuiet(tester);
        await fillVCardForm(tester);
      },
    );

    await tryShoot(
      tester,
      'collection',
      before: () async {
        rootNav(tester).popUntil((route) => route.isFirst);
        await pumpQuiet(tester);
        rootNav(tester).pushReplacementNamed('/collection');
      },
    );

    darkProv.forceSetDarkMode(true);
    await pumpQuiet(tester, frames: 8);
    await tryShoot(tester, 'collection-dark');

    await tryShoot(
      tester,
      'home-dark',
      before: () async {
        rootNav(tester).pushReplacementNamed('/options');
      },
    );
  });

  // Isolated: camera permission must not kill the other shots.
  testWidgets('scanner landing (no camera)', (tester) async {
    await launchApp(tester, dark: false);

    await tryShoot(
      tester,
      'scanner',
      before: () async {
        await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded).first);
      },
    );
  });
}
