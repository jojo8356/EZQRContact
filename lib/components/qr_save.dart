import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

Future<String> saveQrCode(String data, int id) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      gapless: true,
      dataModuleStyle: QrDataModuleStyle(
        color: Colors.black, // carrés de données
      ),
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square, // forme des yeux
        color: Colors.black, // couleur des yeux
      ),
    );

    // Pour générer le PNG avec fond blanc
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = const Size(2048, 2048);

    // Dessine un fond blanc
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Dessine le QR code dessus
    painter.paint(canvas, size);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$id.png';
    await File(path).writeAsBytes(byteData!.buffer.asUint8List());

    return path;
  } else {
    throw Exception('QR invalide');
  }
}
