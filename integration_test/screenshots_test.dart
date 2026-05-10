// Capture des screenshots automatiques des pages v1 d'EZQRContact.
//
// Lancer avec :
//   ./scripts/capture_screenshots.sh
//
// Les images PNG sont écrites dans docs/screenshots/ par le driver.
//
// Stratégie : chaque action est wrappée dans tryShoot() qui :
//   1. Vérifie que l'app est toujours vivante (find.byType(MaterialApp))
//   2. Si l'app est morte → throw AppDeadException → abort le test entier
//   3. Si l'action timeout (3s par défaut) → log et continue avec la suivante
// Comme ça, dès que l'app crash, le test s'arrête au lieu de bloquer 10 min.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/main.dart' as app;
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/tools/db/db.dart';

// Insert sample QR/VCard rows so the Collection page is not empty when
// captured. Uses raw insert (no saveQrCode) to avoid the file system
// dependency of createVCard/createSimpleQR.
Future<void> seedSampleData() async {
  final db = QRDatabase();

  final existing = await db.getAllVCards();
  if (existing.isNotEmpty) return; // already seeded

  await db.insertSimpleQR(
    'https://github.com/jojo8356/EZQRContact',
    null,
  );

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

class AppDeadException implements Exception {
  @override
  String toString() => 'App is no longer running, aborting test.';
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  // Captures a screenshot of whatever is currently on screen.
  // - Aborts the whole test (throws AppDeadException) if app is dead.
  // - Catches any other exception to log it but does not propagate, so the
  //   next tryShoot can still run.
  Future<bool> tryShoot(
    WidgetTester tester,
    String name, {
    Future<void> Function()? before,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    abortIfDead(tester);
    try {
      if (before != null) {
        await before().timeout(timeout * 2);
      }
      abortIfDead(tester);
      await tester.pumpAndSettle(timeout);
      await binding.takeScreenshot(name);
      // ignore: avoid_print
      print('[ok] captured $name');
      return true;
    } on AppDeadException {
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[skip] $name: $e');
      return false;
    }
  }

  // Skipped intentionally:
  // - SettingsPage: crashes on AssetManifest.json (LangProvider.getAll
  //   reads assets/langs/ via rootBundle, not available in
  //   integration_test context).
  // - Scanner is in its own test because mobile_scanner triggers a
  //   camera permission dialog that can freeze or kill the engine.

  testWidgets('home, vcard form, collection (light)', (
    WidgetTester tester,
  ) async {
    DarkModeProvider().setDarkMode(false);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await seedSampleData();
    await binding.convertFlutterSurfaceToImage();

    // 1. Home (already on the initial route).
    await tryShoot(tester, 'home');

    // 2. VCard form (push from home).
    await tryShoot(
      tester,
      'vcard-form',
      before: () async {
        await tester.tap(find.byIcon(Icons.contact_page).first);
      },
    );

    // 3. Collection. Use Navigator.pushNamed so we do not depend on a
    // back button being available on the VCard form.
    await tryShoot(
      tester,
      'collection',
      before: () async {
        final ctx = tester.element(find.byType(Navigator).first);
        Navigator.of(ctx).pushNamed('/collection');
      },
    );
  });

  testWidgets('home and collection in dark mode', (
    WidgetTester tester,
  ) async {
    DarkModeProvider().setDarkMode(true);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await seedSampleData();
    await binding.convertFlutterSurfaceToImage();

    // 4. Home dark.
    await tryShoot(tester, 'home-dark');

    // 5. Collection dark.
    await tryShoot(
      tester,
      'collection-dark',
      before: () async {
        final ctx = tester.element(find.byType(Navigator).first);
        Navigator.of(ctx).pushNamed('/collection');
      },
    );
  });

  // Isolated test: if the camera permission dialog kills the engine, only
  // this test fails and the screenshots from the other tests are kept.
  testWidgets('scanner (may fail without camera permission)', (
    WidgetTester tester,
  ) async {
    DarkModeProvider().setDarkMode(false);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await seedSampleData();
    await binding.convertFlutterSurfaceToImage();

    await tryShoot(
      tester,
      'scanner',
      before: () async {
        await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
      },
    );
  });
}
