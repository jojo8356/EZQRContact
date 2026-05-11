import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Renders [data] to a 2048×2048 PNG QR code and writes it to the app
/// documents directory as `<id>.png`. Returns the absolute file path.
/// Throws when [data] is not a valid QR payload (translated message).
Future<String> saveQrCode(String data, int id) async {
  // Explicit defaults below pin behavior against future qr_flutter
  // upgrades that might change them.
  final qrValidationResult = QrValidator.validate(
    data: data,
    // Pin behavior against future qr_flutter default change.
    // ignore: avoid_redundant_argument_values
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      gapless: true,
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black, // carrés de données
      ),
      // Pin eye style against future qr_flutter default change.
      // ignore: avoid_redundant_argument_values
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
    );

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(2048, 2048);

    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    painter.paint(canvas, size);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$id.png';
    await File(path).writeAsBytes(byteData!.buffer.asUint8List());

    return path;
  } else {
    throw Exception(LangProvider.t('pages.QR.scanner.invalid qr'));
  }
}
