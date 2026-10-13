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

/// Builds a full-frame desk photo around [qrPng]: wood grain, clutter,
/// a white card, camera grain, slight tilt, blur, and JPEG compression.
///
/// This is what a gallery import actually looks like — not a cropped
/// QR PNG. Used by generate→import tests.
Uint8List embedQrInNoisyPhoto(
  Uint8List qrPng, {
  int width = 960,
  int height = 720,
  int jpegQuality = 72,
  int seed = 42,
  double tiltDeg = 6,
  int blurRadius = 1,
  int grainAmplitude = 8,
}) {
  final qr = img.decodePng(qrPng);
  if (qr == null) {
    return qrPng;
  }

  var maxQr = width;
  if (height < width) {
    maxQr = height;
  }
  maxQr = maxQr ~/ 3;
  final stamp = img.copyResize(
    qr,
    width: maxQr,
    interpolation: img.Interpolation.nearest,
  );

  const pad = 28;
  final card = img.Image(
    width: stamp.width + pad * 2,
    height: stamp.height + pad * 2,
  );
  img.fill(card, color: img.ColorRgb8(252, 250, 245));
  img.compositeImage(card, stamp, dstX: pad, dstY: pad);

  var piece = card;
  if (tiltDeg != 0) {
    piece = img.copyRotate(card, angle: tiltDeg);
  }

  final scene = _deskBackground(width, height, seed);
  _paintClutter(scene, seed);
  var dstX = width ~/ 6;
  var dstY = height ~/ 5;
  if (dstX + piece.width >= width) {
    dstX = 24;
  }
  if (dstY + piece.height >= height) {
    dstY = 24;
  }
  img.compositeImage(scene, piece, dstX: dstX, dstY: dstY);
  if (grainAmplitude > 0) {
    _addGrain(scene, seed, amplitude: grainAmplitude);
  }
  if (blurRadius > 0) {
    img.gaussianBlur(scene, radius: blurRadius);
  }
  return Uint8List.fromList(
    img.encodeJpg(scene, quality: jpegQuality),
  );
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
  for (final variant in _decodeVariants(image)) {
    final text = _zxingDecode(variant);
    if (text != null) {
      return text;
    }
  }
  return null;
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

img.Image _deskBackground(int width, int height, int seed) {
  final scene = img.Image(width: width, height: height);
  final rng = <int>[seed];
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final grain = (x + y * 3) % 37;
      final n = (_lcg(rng) % 21) - 10;
      final r = (118 + grain + n).clamp(0, 255);
      final g = (86 + grain ~/ 2 + n).clamp(0, 255);
      final b = (54 + grain ~/ 3 + n).clamp(0, 255);
      scene.setPixelRgb(x, y, r, g, b);
    }
  }
  return scene;
}

void _paintClutter(img.Image scene, int seed) {
  final rng = <int>[seed ^ 0x9e3779b9];
  final w = scene.width;
  final h = scene.height;
  for (var i = 0; i < 6; i++) {
    final x = _lcg(rng) % (w ~/ 2);
    final y = _lcg(rng) % (h ~/ 2);
    final bw = 40 + _lcg(rng) % (w ~/ 5);
    final bh = 18 + _lcg(rng) % (h ~/ 6);
    final r = 40 + _lcg(rng) % 180;
    final g = 40 + _lcg(rng) % 180;
    final b = 40 + _lcg(rng) % 180;
    var x2 = x + bw;
    var y2 = y + bh;
    if (x2 >= w) {
      x2 = w - 1;
    }
    if (y2 >= h) {
      y2 = h - 1;
    }
    img.fillRect(
      scene,
      x1: x,
      y1: y,
      x2: x2,
      y2: y2,
      color: img.ColorRgb8(r, g, b),
    );
  }
}

void _addGrain(img.Image scene, int seed, {int amplitude = 8}) {
  final rng = <int>[seed ^ 0x51ed];
  final w = scene.width;
  final h = scene.height;
  final span = amplitude * 2 + 1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final n = (_lcg(rng) % span) - amplitude;
      final p = scene.getPixel(x, y);
      scene.setPixelRgb(
        x,
        y,
        (p.r.toInt() + n).clamp(0, 255),
        (p.g.toInt() + n).clamp(0, 255),
        (p.b.toInt() + n).clamp(0, 255),
      );
    }
  }
}

int _lcg(List<int> state) {
  final next = (state[0] * 1103515245 + 12345) & 0x7fffffff;
  state[0] = next;
  return next;
}

img.Image _prepareForDecode(img.Image image) {
  if (image.width <= qrDecodeMaxSide && image.height <= qrDecodeMaxSide) {
    return image;
  }
  if (image.width >= image.height) {
    return img.copyResize(
      image,
      width: qrDecodeMaxSide,
      interpolation: img.Interpolation.average,
    );
  }
  return img.copyResize(
    image,
    height: qrDecodeMaxSide,
    interpolation: img.Interpolation.average,
  );
}

List<img.Image> _decodeVariants(img.Image image) {
  final prepared = _prepareForDecode(image);
  final variants = <img.Image>[prepared];

  final gray = img.grayscale(img.Image.from(prepared));
  img.normalize(gray, min: 0, max: 255);
  variants.add(gray);

  final contrast = img.Image.from(gray);
  img.adjustColor(contrast, contrast: 1.5);
  variants.add(contrast);

  final sharp = img.Image.from(gray);
  img.convolution(
    sharp,
    filter: const <num>[0, -1, 0, -1, 5, -1, 0, -1, 0],
  );
  variants.add(sharp);

  const sides = <int>[1024, 768, 512];
  for (final side in sides) {
    if (prepared.width <= side && prepared.height <= side) {
      continue;
    }
    img.Image scaled;
    if (prepared.width >= prepared.height) {
      scaled = img.copyResize(
        prepared,
        width: side,
        interpolation: img.Interpolation.average,
      );
    } else {
      scaled = img.copyResize(
        prepared,
        height: side,
        interpolation: img.Interpolation.average,
      );
    }
    variants.add(scaled);
  }
  return variants;
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
