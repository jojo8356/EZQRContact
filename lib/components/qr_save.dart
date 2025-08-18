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
        color: Colors.black, // couleur des carrés de données
      ),
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square, // forme des yeux
        color: Colors.black, // couleur des yeux
      ),
      // emptyColor retiré
    );

    Container(
      color: Colors.white, // couleur de fond
      child: CustomPaint(size: const Size(200, 200), painter: painter),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$id.png'; // nom = id
    final file = File(path);

    final picData = await painter.toImageData(
      2048,
      format: ImageByteFormat.png,
    );
    await file.writeAsBytes(picData!.buffer.asUint8List());
    return path;
  } else {
    throw Exception('QR invalide');
  }
}
