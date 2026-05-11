// Driver pour le test integration_test/screenshots_test.dart.
// Reçoit chaque screenshot pris via binding.takeScreenshot(name) et l'écrit
// dans docs/screenshots/<name>.png.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot:
        (
          screenshotName,
          screenshotBytes, [
          args,
        ]) async {
          final outDir = Directory('docs/screenshots');
          if (!outDir.existsSync()) {
            await outDir.create(recursive: true);
          }
          final file = File('${outDir.path}/$screenshotName.png');
          await file.writeAsBytes(screenshotBytes);
          // Driver-side log; goes to stdout consumed by capture_screenshots.sh.
          // ignore: avoid_print
          print('Saved ${file.path} (${screenshotBytes.length} bytes)');
          return true;
        },
  );
}
