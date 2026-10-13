import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  return await compute(
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
    if (src.width >= src.height) {
      src = img.copyResize(src, width: maxSide);
    } else {
      src = img.copyResize(src, height: maxSide);
    }
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

/// Test hook so [hostPhotoForQr] never hits the network. Return a public
/// http(s) URL, or `null` to omit PHOTO from the QR payload.
@visibleForTesting
Future<String?> Function(String photo)? debugHostPhotoForQr;

/// Test hook for [deviceHasInternet]. `true` / `false` skip the lookup.
@visibleForTesting
bool? debugHasInternet;

final Map<int, String?> _hostCache = <int, String?>{};

/// Drops the in-memory host cache (tests).
@visibleForTesting
void resetPhotoHostCache() {
  _hostCache.clear();
}

/// True inside `flutter test` / `dart test` (the test package zone, or
/// the `FLUTTER_TEST` dart-define). Used so we never DNS/upload in tests
/// unless a debug hook opts in.
bool _inTest() {
  if (const bool.fromEnvironment('FLUTTER_TEST')) {
    return true;
  }
  if (Zone.current[#test.declarer] != null) {
    return true;
  }
  return false;
}

/// True when the device can resolve a public host (needs internet).
///
/// Used before uploading a vCard photo: offline, the QR is text-only.
Future<bool> deviceHasInternet() async {
  if (debugHasInternet != null) {
    return debugHasInternet!;
  }
  // A hosted-photo test hook implies we are pretending to be online.
  if (debugHostPhotoForQr != null) {
    return true;
  }
  if (_inTest()) {
    return false;
  }
  try {
    final result = await InternetAddress.lookup(
      'one.one.one.one',
    ).timeout(const Duration(seconds: 2));
    if (result.isEmpty) {
      return false;
    }
    if (result.first.rawAddress.isEmpty) {
      return false;
    }
    return true;
  } on Object catch (_) {
    return false;
  }
}

/// Returns an http(s) URL for [photo] that can fit in a QR `PHOTO;VALUE=URI`
/// line. Inline `data:image` payloads are uploaded to an anonymous host
/// (needs internet). Already-hosted URLs are returned as-is. Returns `null`
/// when there is nothing to host, or when the upload fails — callers then
/// omit PHOTO so the QR still encodes.
Future<String?> hostPhotoForQr(String photo) async {
  if (debugHostPhotoForQr != null) {
    return await debugHostPhotoForQr!(photo);
  }
  if (photo.startsWith('https://') || photo.startsWith('http://')) {
    return photo;
  }
  if (!photo.startsWith('data:image/')) {
    return null;
  }
  // Unit/widget tests must not hit the network. Inject [debugHostPhotoForQr]
  // to simulate a hosted URL.
  if (_inTest()) {
    return null;
  }
  final cacheKey = Object.hash(photo.length, photo.hashCode);
  if (_hostCache.containsKey(cacheKey)) {
    return _hostCache[cacheKey];
  }
  final comma = photo.indexOf(',');
  if (comma < 0) {
    _hostCache[cacheKey] = null;
    return null;
  }
  Uint8List bytes;
  try {
    bytes = base64Decode(photo.substring(comma + 1));
  } on FormatException {
    _hostCache[cacheKey] = null;
    return null;
  }
  if (bytes.isEmpty) {
    _hostCache[cacheKey] = null;
    return null;
  }

  final meta = photo.substring(0, comma).toLowerCase();
  var filename = 'photo.jpg';
  if (meta.contains('png')) {
    filename = 'photo.png';
  } else if (meta.contains('gif')) {
    filename = 'photo.gif';
  } else if (meta.contains('webp')) {
    filename = 'photo.webp';
  }

  final url = await _uploadAnonymous(bytes, filename);
  _hostCache[cacheKey] = url;
  return url;
}

Future<String?> _uploadAnonymous(Uint8List bytes, String filename) async {
  try {
    final catbox = await _postMultipart(
      Uri.parse('https://catbox.moe/user/api.php'),
      fields: const {'reqtype': 'fileupload'},
      fileField: 'fileToUpload',
      bytes: bytes,
      filename: filename,
    );
    if (catbox != null && catbox.startsWith('http')) {
      return catbox.trim();
    }
  } on Object catch (_) {
    // Fall through to 0x0.st.
  }
  try {
    final paste = await _postMultipart(
      Uri.parse('https://0x0.st'),
      fields: const {},
      fileField: 'file',
      bytes: bytes,
      filename: filename,
    );
    if (paste != null && paste.startsWith('http')) {
      return paste.trim();
    }
  } on Object catch (_) {
    return null;
  }
  return null;
}

Future<String?> _postMultipart(
  Uri uri, {
  required Map<String, String> fields,
  required String fileField,
  required Uint8List bytes,
  required String filename,
}) async {
  final req = http.MultipartRequest('POST', uri);
  req.headers['User-Agent'] = 'EZQRContact/1.1';
  req.fields.addAll(fields);
  req.files.add(
    http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
  );
  final streamed = await req.send().timeout(const Duration(seconds: 8));
  final body = (await streamed.stream.bytesToString()).trim();
  if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
    return null;
  }
  if (body.isEmpty) {
    return null;
  }
  return body;
}
