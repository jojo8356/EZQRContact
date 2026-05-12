import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/tools/perf.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ---------------------------------------------------------------------------
// Pure-Dart QR renderer — runs in a compute() isolate, no GPU required.
// ---------------------------------------------------------------------------

/// Top-level so it can be sent to a compute() isolate.
/// args: [bits (Uint8List), n (int), r (int), g (int), b (int)]
Uint8List _renderQrPng(List<dynamic> args) {
  final bits = args[0] as Uint8List;
  final n    = args[1] as int;
  final cr   = args[2] as int;
  final cg   = args[3] as int;
  final cb   = args[4] as int;

  // 10 px per module + 4-module quiet zone on each side.
  const scale   = 10;
  const quietPx = 4 * scale;
  final size    = n * scale + quietPx * 2;
  const ch      = 3; // RGB — no alpha channel needed for QR codes

  // numChannels default is 3 (RGB); ch must match for the buffer math below.
  final image = img.Image(width: size, height: size);
  // image.buffer gives direct access to the underlying Uint8List.
  // Uint8List is zero-initialised (black); fill with 255 for white background.
  final buf = image.buffer.asUint8List();
  buf.fillRange(0, buf.length, 255);

  for (var row = 0; row < n; row++) {
    final y0 = quietPx + row * scale;
    for (var col = 0; col < n; col++) {
      if (bits[row * n + col] == 1) {
        final x0 = quietPx + col * scale;
        for (var dy = 0; dy < scale; dy++) {
          var px = ((y0 + dy) * size + x0) * ch;
          for (var dx = 0; dx < scale; dx++) {
            buf[px]     = cr;
            buf[px + 1] = cg;
            buf[px + 2] = cb;
            px += ch;
          }
        }
      }
    }
  }

  // level=1 (fastest deflate): QR codes compress extremely well regardless
  // of level; the ~2× size difference vs level=6 is negligible on-device.
  return img.encodePng(image, level: 1);
}

// ---------------------------------------------------------------------------
// Public helpers
// ---------------------------------------------------------------------------

/// Builds a QR code PNG for [data] and returns the raw bytes.
///
/// Matrix extraction runs on the calling isolate; pixel rendering and PNG
/// encoding run in a worker isolate via [compute] — the UI thread never
/// blocks, and multiple calls are automatically parallelised across CPU cores.
///
/// Throws when [data] is not a valid QR payload (translated message).
Future<Uint8List> buildQrBytes(
  String data, {
  Color color = Colors.black,
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
  final n       = qrImage.moduleCount;
  final bits    = Uint8List(n * n);
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      if (qrImage.isDark(r, c)) bits[r * n + c] = 1;
    }
  }

  // color.red/green/blue are deprecated in Flutter; extract 0-255 components
  // via the normalized double channels instead.
  final cr = (color.r * 255).round().clamp(0, 255);
  final cg = (color.g * 255).round().clamp(0, 255);
  final cb = (color.b * 255).round().clamp(0, 255);
  return compute<List<dynamic>, Uint8List>(
    _renderQrPng,
    [bits, n, cr, cg, cb],
  );
}

/// Renders [data] to a PNG QR code, writes it to the app documents directory
/// as `<id>.png`, and returns the absolute file path.
/// [color] sets the QR module colour (default black).
/// Throws when [data] is not a valid QR payload (translated message).
Future<String> saveQrCode(
  String data,
  int id, {
  Color color = Colors.black,
}) async {
  Perf.start('qr.save.total');

  Perf.start('qr.save.build_bytes');
  final pngBytes = await buildQrBytes(data, color: color);
  Perf.end('qr.save.build_bytes');

  Perf.start('qr.save.write_file');
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await File(path).writeAsBytes(pngBytes, flush: true);
  Perf.end('qr.save.write_file');

  Perf.end('qr.save.total');
  return path;
}
