import 'dart:io';
import 'dart:typed_data';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart' hide BarcodeFormat;

/// Longest side kept when decoding a gallery photo. 12 MP frames drown
/// ZXing; 1600 px still leaves QR modules readable.
const int qrDecodeMaxSide = 1600;

/// Places [qrPng] on a larger beige canvas so the file looks like a photo
/// of a card, not a cropped QR. Used by generate→import tests.
Uint8List embedQrInScene(Uint8List qrPng, {int margin = 96}) {
  final qr = img.decodePng(qrPng);
  if (qr == null) {
    return qrPng;
  }
  final scene = img.Image(
    width: qr.width + margin * 2,
    height: qr.height + margin * 2,
  );
  img.fill(scene, color: img.ColorRgb8(0xF4, 0xEF, 0xE6));
  img.compositeImage(scene, qr, dstX: margin, dstY: margin);
  return Uint8List.fromList(img.encodePng(scene));
}

/// Decodes the first QR payload in [bytes] (PNG/JPEG).
///
/// Uses ZXing's detector, so the code does not have to fill the frame —
/// a photo of a card or a screenshot with UI chrome still works.
String? decodeQrFromBytes(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) {
    return null;
  }
  final prepared = _prepareForDecode(image);
  final text = _zxingDecode(prepared);
  if (text != null) {
    return text;
  }
  if (prepared.width == image.width && prepared.height == image.height) {
    return null;
  }
  return _zxingDecode(image);
}

/// Reads [path] and decodes a QR.
///
/// Tries platform ML Kit / Apple Vision first ([analyzeImage]), then
/// falls back to [decodeQrFromBytes] when the plugin is missing or the
/// photo is not a cropped code.
Future<String?> decodeQrFromFile(String path) async {
  try {
    final controller = AiBarcodeScannerController(autoStart: false);
    try {
      final capture = await controller.analyzeImage(
        path,
        formats: const [BarcodeFormat.qrCode],
      );
      if (capture != null && capture.barcodes.isNotEmpty) {
        final value = capture.barcodes.first.rawValue;
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } finally {
      controller.dispose();
    }
  } on Object catch (_) {
    // MissingPluginException in widget tests; unsupported on some hosts.
  }

  try {
    final bytes = await File(path).readAsBytes();
    return decodeQrFromBytes(bytes);
  } on Object catch (_) {
    return null;
  }
}

img.Image _prepareForDecode(img.Image image) {
  if (image.width <= qrDecodeMaxSide && image.height <= qrDecodeMaxSide) {
    return image;
  }
  if (image.width >= image.height) {
    return img.copyResize(image, width: qrDecodeMaxSide);
  }
  return img.copyResize(image, height: qrDecodeMaxSide);
}

String? _zxingDecode(img.Image image) {
  try {
    final rgba = image.convert(numChannels: 4);
    final bytes = Uint8List.fromList(
      rgba.getBytes(order: img.ChannelOrder.abgr),
    );
    final source = RGBLuminanceSource(
      rgba.width,
      rgba.height,
      bytes.buffer.asInt32List(),
    );
    final hints = DecodeHints()..put(DecodeHintType.tryHarder);
    final text = _zxingRead(source, hints);
    if (text != null) {
      return text;
    }
    return _zxingRead(source.invert(), hints);
  } on Object catch (_) {
    return null;
  }
}

String? _zxingRead(LuminanceSource source, DecodeHints hints) {
  try {
    final result = QRCodeReader().decode(
      BinaryBitmap(HybridBinarizer(source)),
      hints: hints,
    );
    return result.text;
  } on Object catch (_) {
    try {
      final result = QRCodeReader().decode(
        BinaryBitmap(GlobalHistogramBinarizer(source)),
        hints: hints,
      );
      return result.text;
    } on Object catch (_) {
      return null;
    }
  }
}
