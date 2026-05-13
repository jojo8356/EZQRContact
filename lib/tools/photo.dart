import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Resizes [bytes] to fit within [maxSide]×[maxSide] px, preserving aspect
/// ratio. Compresses as JPEG at [quality] (0–100). Returns the JPEG bytes.
///
/// Runs in a [compute] isolate so the UI thread never blocks.
Future<Uint8List> resizeAndCompressJpeg(
  Uint8List bytes, {
  int maxSide = 720,
  int quality = 85,
}) async {
  return compute(
    _resizeAndCompressIsolate,
    [bytes, maxSide, quality],
  );
}

Uint8List _resizeAndCompressIsolate(List<dynamic> args) {
  final bytes = args[0] as Uint8List;
  final maxSide = args[1] as int;
  final quality = args[2] as int;

  var src = img.decodeImage(bytes);
  if (src == null) return bytes;

  if (src.width > maxSide || src.height > maxSide) {
    src = src.width >= src.height
        ? img.copyResize(src, width: maxSide)
        : img.copyResize(src, height: maxSide);
  }
  return img.encodeJpg(src, quality: quality);
}

/// Encodes [originalBytes] as a base64 JPEG data URI suitable for the vCard
/// `photo` field. Progressively recompresses until the encoded string fits
/// under [maxBase64Bytes] (default 200 KB = 204800 bytes):
///
///   quality 85 → 75 → 65 → 55
///   if still too large: resize to 512 then 256 before trying again
///
/// Returns `null` if the image cannot be compressed enough — the caller
/// should surface an error message to the user.
Future<String?> compressPhotoForVCard(
  Uint8List originalBytes, {
  int maxBase64Bytes = 204800,
}) async {
  final qualities = [85, 75, 65, 55];
  final maxSides = [720, 512, 256];

  for (final side in maxSides) {
    for (final q in qualities) {
      final jpeg = await resizeAndCompressJpeg(
        originalBytes,
        maxSide: side,
        quality: q,
      );
      final b64 = base64Encode(jpeg);
      if (b64.length <= maxBase64Bytes) {
        return 'data:image/jpeg;base64,$b64';
      }
    }
  }
  return null; // Could not compress enough.
}
