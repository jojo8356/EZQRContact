// Drives the six README screens. The host script watches stdout for
// `[ezqr-shot] <name>` and runs `adb screencap` (flutter drive's VM
// service dies on some Mali devices).
//
//   ./scripts/capture_screenshots.sh
//
// Filenames: home, home-dark, scanner, collection, collection-dark.

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
      'org': 'Demo Corp',
      'job': 'Sales Representative',
      'photo': '',
      'tel_work': '+33 6 12 34 56 78',
      'adr_work': '1 rue Demo, 75001 Paris',
      'email': 'marie@example.com',
      'rev': '20260510T194800Z',
      'clone': 0,
    });
  }
  if (!hasJean) {
    await db.insertVCard({
      'nom': 'Martin',
      'prenom': 'Jean',
      'org': 'TechCo',
      'job': 'CTO',
      'photo': '',
      'tel_work': '+33 7 98 76 54 32',
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

Future<void> pumpQuiet(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> launchApp(WidgetTester tester) async {
    await _skipFirstRunGates();
    darkProv.forceSetDarkMode(false);
    app.main();
    await pumpQuiet(tester, frames: 30);
    await seedSampleData();
    await pumpQuiet(tester, frames: 8);
  }

  Future<void> tapBack(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    final back = find.byTooltip('Back');
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
      await pumpQuiet(tester);
      return;
    }
    await tester.pageBack();
    await pumpQuiet(tester);
  }

  Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon).first);
    await pumpQuiet(tester);
  }

  Future<void> markShot(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 400));
    await pumpQuiet(tester, frames: 8);
    // Host script matches this token and runs adb screencap.
    // ignore: avoid_print
    print('[ezqr-shot] $name');
    await Future<void>.delayed(const Duration(seconds: 4));
  }

  testWidgets('readme screenshots', (tester) async {
    await launchApp(tester);

    await markShot(tester, 'home');

    await tapIcon(tester, Icons.qr_code_scanner_rounded);
    await markShot(tester, 'scanner');
    await tapBack(tester);

    await tapIcon(tester, Icons.style_outlined);
    await markShot(tester, 'collection');

    darkProv.forceSetDarkMode(true);
    await pumpQuiet(tester, frames: 10);
    await markShot(tester, 'collection-dark');

    await tapIcon(tester, Icons.home_outlined);
    await markShot(tester, 'home-dark');

    // ignore: avoid_print
    print('[ezqr-shot-done]');
  });
}
