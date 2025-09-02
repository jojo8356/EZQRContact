import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

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
      dataModuleStyle: QrDataModuleStyle(color: Colors.black),
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
    );

    // Générer le QR code sur un canvas
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = const Size(2048, 2048);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    painter.paint(canvas, size);

    final picture = pictureRecorder.endRecording();
    final imageFlutter = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await imageFlutter.toByteData(format: ImageByteFormat.png);

    // Convertir PNG en JPG
    final pngBytes = byteData!.buffer.asUint8List();
    final decodedImage = img.decodeImage(pngBytes)!;
    final jpgBytes = img.encodeJpg(decodedImage);

    // Sauvegarder
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$id.jpg';
    await File(path).writeAsBytes(jpgBytes);

    return path;
  } else {
    throw Exception(LangProvider.get('pages')['QR']['scanner']['invalid qr']);
  }
}
