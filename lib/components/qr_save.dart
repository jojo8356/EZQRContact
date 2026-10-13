import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/tools/perf.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Pixels per QR module. 4 px is enough to scan and nearest-neighbour
/// upscales cleanly for print; 10 px was ~6× more work for encode+fill.
const int qrModulePx = 4;

/// Quiet zone in modules (QR spec minimum).
const int qrQuietModules = 4;

// ---------------------------------------------------------------------------
// Pure-Dart QR renderer — cheap enough to run on the UI isolate when there
// is no logo. Logo decode/resize still goes through [compute].
// ---------------------------------------------------------------------------

/// Top-level so it can be sent to a compute() isolate.
/// args: [bits (Uint8List), n (int), r (int), g (int), b (int),
///        logoData (Uint8List?)]
Uint8List _renderQrPng(List<dynamic> args) {
  final bits = args[0] as Uint8List;
  final n = args[1] as int;
  final cr = args[2] as int;
  final cg = args[3] as int;
  final cb = args[4] as int;
  Uint8List? logoData;
  if (args.length > 5) {
    logoData = args[5] as Uint8List?;
  }

  const scale = qrModulePx;
  const quietPx = qrQuietModules * qrModulePx;
  final size = n * scale + quietPx * 2;
  const ch = 3;

  final image = img.Image(width: size, height: size);
  final buf = image.buffer.asUint8List();
  buf.fillRange(0, buf.length, 255);

  // One module-row of packed RGB, copied with setRange (much faster than
  // per-pixel stores in the inner loop).
  final moduleRow = Uint8List(scale * ch);
  for (var i = 0; i < scale; i++) {
    final o = i * ch;
    moduleRow[o] = cr;
    moduleRow[o + 1] = cg;
    moduleRow[o + 2] = cb;
  }

  for (var row = 0; row < n; row++) {
    final y0 = quietPx + row * scale;
    final rowOff = row * n;
    for (var col = 0; col < n; col++) {
      if (bits[rowOff + col] == 0) {
        continue;
      }
      final xOff = (quietPx + col * scale) * ch;
      for (var dy = 0; dy < scale; dy++) {
        final start = ((y0 + dy) * size) * ch + xOff;
        buf.setRange(start, start + moduleRow.length, moduleRow);
      }
    }
  }

  if (logoData != null) {
    var logo = img.decodeImage(logoData);
    if (logo != null) {
      const maxSide = 64;
      if (logo.width > maxSide || logo.height > maxSide) {
        if (logo.width >= logo.height) {
          logo = img.copyResize(logo, width: maxSide);
        } else {
          logo = img.copyResize(logo, height: maxSide);
        }
      }

      const pad = 4;
      final shieldW = logo.width + pad * 2;
      final shieldH = logo.height + pad * 2;
      final shieldX = (size - shieldW) ~/ 2;
      final shieldY = (size - shieldH) ~/ 2;

      final x0 = shieldX.clamp(0, size);
      final x1 = (shieldX + shieldW).clamp(0, size);
      final shieldTop = shieldY.clamp(0, size);
      final y1 = (shieldY + shieldH).clamp(0, size);
      for (var y = shieldTop; y < y1; y++) {
        for (var x = x0; x < x1; x++) {
          final px = (y * size + x) * ch;
          buf[px] = 255;
          buf[px + 1] = 255;
          buf[px + 2] = 255;
        }
      }

      final logoX = shieldX + pad;
      final logoY = shieldY + pad;

      int alphaOver(num channel, num alpha, num maxVal) =>
          ((channel / maxVal) * (alpha / maxVal) * 255 +
                  255 * (1 - alpha / maxVal))
              .round()
              .clamp(0, 255);

      for (var ly = 0; ly < logo.height; ly++) {
        final dy = logoY + ly;
        if (dy < 0 || dy >= size) continue;
        for (var lx = 0; lx < logo.width; lx++) {
          final dx = logoX + lx;
          if (dx < 0 || dx >= size) continue;
          final p = logo.getPixel(lx, ly);
          final max = p.maxChannelValue;
          final idx = (dy * size + dx) * ch;
          buf[idx] = alphaOver(p.r, p.a, max);
          buf[idx + 1] = alphaOver(p.g, p.a, max);
          buf[idx + 2] = alphaOver(p.b, p.a, max);
        }
      }
    }
  }

  return img.encodePng(image, level: 1);
}

// ---------------------------------------------------------------------------
// Public helpers
// ---------------------------------------------------------------------------

/// Builds a QR code PNG for [data] and returns the raw bytes.
///
/// [color] sets the module color (default black).
/// [logoBytes] optional PNG/JPEG logo to embed at center (max 64×64 px,
/// 4 px white padding). Logo compositing runs in a worker isolate; the
/// no-logo path stays on the caller isolate (spawn cost dominated 10 px
/// raster).
///
/// Throws when [data] is not a valid QR payload (translated message).
Future<Uint8List> buildQrBytes(
  String data, {
  Color color = Colors.black,
  Uint8List? logoBytes,
}) async {
  final result = QrValidator.validate(
    data: data,
    // The qr_flutter default is QrVersions.auto; pinning it here makes the
    // intent explicit and guards against a future default change.
    // ignore: avoid_redundant_argument_values
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );
  if (result.status != QrValidationStatus.valid) {
    throw Exception(LangProvider.t('pages.QR.scanner.invalid qr'));
  }

  final qrImage = QrImage(result.qrCode!);
  final n = qrImage.moduleCount;
  final bits = Uint8List(n * n);
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      if (qrImage.isDark(r, c)) bits[r * n + c] = 1;
    }
  }

  final cr = (color.r * 255).round().clamp(0, 255);
  final cg = (color.g * 255).round().clamp(0, 255);
  final cb = (color.b * 255).round().clamp(0, 255);
  final args = <dynamic>[bits, n, cr, cg, cb];
  if (logoBytes != null) {
    args.add(logoBytes);
    return await compute<List<dynamic>, Uint8List>(_renderQrPng, args);
  }
  return _renderQrPng(args);
}

/// Renders [data] to a PNG QR code, writes it to the app documents directory
/// as `<id>.png`, and returns the absolute file path.
/// [color] sets the QR module colour (default black).
/// [logoBytes] optional logo to embed at center (see [buildQrBytes]).
/// Throws when [data] is not a valid QR payload (translated message).
Future<String> saveQrCode(
  String data,
  int id, {
  Color color = Colors.black,
  Uint8List? logoBytes,
}) async {
  Perf.start('qr.save.total');

  Perf.start('qr.save.build_bytes');
  final pngBytes = await buildQrBytes(data, color: color, logoBytes: logoBytes);
  Perf.end('qr.save.build_bytes');

  Perf.start('qr.save.write_file');
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  // Default flush=false: the OS writes through; fsync was 30–70 ms extra.
  await File(path).writeAsBytes(pngBytes);
  Perf.end('qr.save.write_file');

  Perf.end('qr.save.total');
  return path;
}
