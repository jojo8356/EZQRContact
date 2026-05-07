// Capture des screenshots automatiques des pages v1 d'EZQRContact.
//
// Lancer avec :
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart \
//     -d <device_id>
//
// Ou plus simple :
//   ./scripts/capture_screenshots.sh
//
// Les images PNG sont écrites dans docs/screenshots/ par le driver.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/main.dart' as app;
import 'package:qr_code_app/providers/darkmode.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    // Required on Android, no-op on iOS.
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  testWidgets('home, vcard form, scanner, collection, settings (light)', (
    WidgetTester tester,
  ) async {
    DarkModeProvider().setDarkMode(false);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 1. Home (OptionsListPage)
    await shoot(tester, 'home');

    // 2. VCard form (GenerateVCardQRCode)
    final vcardBtn = find.byIcon(Icons.contact_page);
    expect(vcardBtn, findsWidgets);
    await tester.tap(vcardBtn.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await shoot(tester, 'vcard-form');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 3. Scanner (QRScannerPage)
    final scannerBtn = find.byIcon(Icons.qr_code_scanner);
    expect(scannerBtn, findsWidgets);
    await tester.tap(scannerBtn.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await shoot(tester, 'scanner');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Collection (/collection) via Navigator.pushNamed
    final ctx = tester.element(find.byType(MaterialApp));
    Navigator.of(ctx).pushNamed('/collection');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await shoot(tester, 'collection');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 5. Settings (/settings)
    Navigator.of(ctx).pushNamed('/settings');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await shoot(tester, 'settings');
  });

  testWidgets('home and settings in dark mode', (WidgetTester tester) async {
    DarkModeProvider().setDarkMode(true);

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 6. Home in dark mode
    await shoot(tester, 'home-dark');

    // 7. Settings in dark mode
    final ctx = tester.element(find.byType(MaterialApp));
    Navigator.of(ctx).pushNamed('/settings');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await shoot(tester, 'settings-dark');
  });
}
