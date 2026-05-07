// Driver pour le test integration_test/screenshots_test.dart.
// Reçoit chaque screenshot pris via binding.takeScreenshot(name) et l'écrit
// dans docs/screenshots/<name>.png.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot:
        (
          String screenshotName,
          List<int> screenshotBytes, [
          Map<String, Object?>? args,
        ]) async {
          final outDir = Directory('docs/screenshots');
          if (!await outDir.exists()) {
            await outDir.create(recursive: true);
          }
          final file = File('${outDir.path}/$screenshotName.png');
          await file.writeAsBytes(screenshotBytes);
          // ignore: avoid_print
          print('Saved ${file.path} (${screenshotBytes.length} bytes)');
          return true;
        },
  );
}
