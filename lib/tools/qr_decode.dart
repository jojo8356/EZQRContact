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

/// Simulates a phone photo of a QR on a screen: dark UI, LCD RGB moiré,
/// chromatic fringe, and a tilt so the code is not axis-aligned.
Uint8List embedQrOnScreenPhoto(
  Uint8List qrPng, {
  int width = 960,
  int height = 720,
  int jpegQuality = 78,
  double tiltDeg = 7,
  int seed = 7,
}) {
  final qr = img.decodePng(qrPng);
  if (qr == null) {
    return qrPng;
  }

  var maxQr = width;
  if (height < width) {
    maxQr = height;
  }
  maxQr = (maxQr * 2) ~/ 3;
  final stamp = img.copyResize(
    qr,
    width: maxQr,
    interpolation: img.Interpolation.nearest,
  );

  const pad = 36;
  final card = img.Image(
    width: stamp.width + pad * 2,
    height: stamp.height + pad * 2,
  );
  img.fill(card, color: img.ColorRgb8(248, 248, 248));
  img.compositeImage(card, stamp, dstX: pad, dstY: pad);

  final scene = img.Image(width: width, height: height);
  img.fill(scene, color: img.ColorRgb8(22, 22, 24));
  var dstX = (width - card.width) ~/ 2;
  var dstY = (height - card.height) ~/ 2;
  if (dstX < 8) {
    dstX = 8;
  }
  if (dstY < 8) {
    dstY = 8;
  }
  img.compositeImage(scene, card, dstX: dstX, dstY: dstY);
  _addLcdMoiré(scene);
  _rgbFringe(scene);
  _addGrain(scene, seed, amplitude: 6);

  img.Image shot = scene;
  if (tiltDeg != 0) {
    shot = img.copyRotate(
      scene,
      angle: tiltDeg,
      interpolation: img.Interpolation.linear,
    );
  }
  return Uint8List.fromList(
    img.encodeJpg(shot, quality: jpegQuality),
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

void _addLcdMoire(img.Image scene) {
  final w = scene.width;
  final h = scene.height;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = scene.getPixel(x, y);
      var r = p.r.toInt();
      var g = p.g.toInt();
      var b = p.b.toInt();
      final lane = x % 3;
      if (lane == 0) {
        r = (r + 16).clamp(0, 255);
      } else if (lane == 1) {
        g = (g + 16).clamp(0, 255);
      } else {
        b = (b + 16).clamp(0, 255);
      }
      if (y.isEven) {
        r = (r - 7).clamp(0, 255);
        g = (g - 7).clamp(0, 255);
        b = (b - 7).clamp(0, 255);
      }
      scene.setPixelRgb(x, y, r, g, b);
    }
  }
}

void _rgbFringe(img.Image scene) {
  final copy = img.Image.from(scene);
  final w = scene.width;
  final h = scene.height;
  for (var y = 0; y < h; y++) {
    for (var x = 1; x < w - 1; x++) {
      final left = copy.getPixel(x - 1, y);
      final mid = copy.getPixel(x, y);
      final right = copy.getPixel(x + 1, y);
      scene.setPixelRgb(
        x,
        y,
        left.r.toInt(),
        mid.g.toInt(),
        right.b.toInt(),
      );
    }
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

  // Tiny or rotated codes (ZXing qrcode-6) need more pixels per module.
  if (prepared.width <= 1200 && prepared.height <= 1200) {
    variants.add(
      img.copyResize(
        prepared,
        width: prepared.width * 2,
        interpolation: img.Interpolation.nearest,
      ),
    );
  }
  if (prepared.width <= 600 && prepared.height <= 600) {
    variants.add(
      img.copyResize(
        prepared,
        width: prepared.width * 3,
        interpolation: img.Interpolation.nearest,
      ),
    );
  }

  final gray = img.grayscale(img.Image.from(prepared));
  img.normalize(gray, min: 0, max: 255);
  variants.add(gray);

  // LCD photos: green plane (less RGB subpixel fringe) + blur (moiré).
  variants.add(_greenPlane(prepared));
  final blurred = img.Image.from(gray);
  img.gaussianBlur(blurred, radius: 2);
  variants.add(blurred);

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

  // Codes that are not axis-aligned (phone photo of a screen).
  img.Image rotBase = gray;
  if (gray.width > 800 && gray.width >= gray.height) {
    rotBase = img.copyResize(
      gray,
      width: 800,
      interpolation: img.Interpolation.average,
    );
  } else if (gray.height > 800) {
    rotBase = img.copyResize(
      gray,
      height: 800,
      interpolation: img.Interpolation.average,
    );
  }
  const angles = <double>[-10, -5, 5, 10];
  for (final deg in angles) {
    variants.add(
      img.copyRotate(
        rotBase,
        angle: deg,
        interpolation: img.Interpolation.linear,
      ),
    );
  }
  return variants;
}

img.Image _greenPlane(img.Image src) {
  final out = img.Image(width: src.width, height: src.height);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final g = src.getPixel(x, y).g.toInt();
      out.setPixelRgb(x, y, g, g, g);
    }
  }
  return out;
}

String? _zxingDecode(img.Image image) {
  try {
    final source = RGBLuminanceSource(
      image.width,
      image.height,
      _argbPixels(image),
    );
    final hints = DecodeHints()..put(DecodeHintType.tryHarder);
    final text = _zxingRead(source, hints);
    if (text != null) {
      return text;
    }
    final inverted = _zxingRead(source.invert(), hints);
    if (inverted != null) {
      return inverted;
    }
    // Cropped rasters with almost no quiet zone (ZXing qrcode-2).
    final pure = DecodeHints()
      ..put(DecodeHintType.tryHarder)
      ..put(DecodeHintType.pureBarcode);
    return _zxingRead(source, pure);
  } on Object catch (_) {
    return null;
  }
}

/// Packs 0xAARRGGBB ints, matching Java ZXing's RGBLuminanceSource.
Int32List _argbPixels(img.Image image) {
  final rgba = image.convert(numChannels: 4);
  final bytes = rgba.getBytes(order: img.ChannelOrder.rgba);
  final count = rgba.width * rgba.height;
  final pixels = Int32List(count);
  for (var i = 0; i < count; i++) {
    final o = i * 4;
    final r = bytes[o];
    final g = bytes[o + 1];
    final b = bytes[o + 2];
    final a = bytes[o + 3];
    pixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
  }
  return pixels;
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
