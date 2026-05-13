import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns true when the first-run guide has not yet been displayed.
Future<bool> shouldShowGuide() async {
  final prefs = await SharedPreferences.getInstance();
  final hasShown = prefs.getInt('guideShown') ?? 0;
  return hasShown == 0;
}

/// Persists the fact that the first-run guide has been displayed.
Future<void> markGuideShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('guideShown', 1);
}

/// Builds a map of [TextEditingController]s pre-filled from the legacy
/// `Map<String, dynamic>` VCard payload, one controller per known field.
Map<String, TextEditingController> mapToControllers(Map<String, dynamic> data) {
  String s(String key) => (data[key] as String?) ?? '';
  return {
    'nom': TextEditingController(text: s('nom')),
    'prenom': TextEditingController(text: s('prenom')),
    'nom2': TextEditingController(text: s('nom2')),
    'prefixe': TextEditingController(text: s('prefixe')),
    'suffixe': TextEditingController(text: s('suffixe')),
    'org': TextEditingController(text: s('org')),
    'job': TextEditingController(text: s('job')),
    'photo': TextEditingController(text: s('photo')),
    'tel_work': TextEditingController(text: s('tel_work')),
    'tel_home': TextEditingController(text: s('tel_home')),
    'adr_work': TextEditingController(text: s('adr_work')),
    'adr_home': TextEditingController(text: s('adr_home')),
    'email': TextEditingController(text: s('email')),
  };
}

/// Returns the leading avatar for a list/card item: a photo for vCards
/// (or a person icon when [photo] is empty) and a QR icon otherwise.
Widget buildItemAvatar({required bool isVCard, required String photo}) {
  if (isVCard) {
    if (photo.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(photo), radius: 25);
    } else {
      return const Icon(Icons.person, size: 40, color: Colors.green);
    }
  } else {
    return const Icon(Icons.qr_code, size: 40, color: Colors.blue);
  }
}

/// Pushes [page] on the navigator and returns the value popped back, if any.
Future<dynamic> redirect(BuildContext context, Widget page) {
  return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

/// Builds the list of `{label, controller}` records used by the VCard form.
/// Labels come from the active language pack at `VCard Input.<key>`.
/// Fields whose key is absent from [controllers] are silently omitted, so
/// callers that manage photo via a dedicated widget can simply omit the
/// `'photo'` key from their controllers map.
List<Map<String, dynamic>> buildFields(
  Map<String, TextEditingController> controllers,
) {
  final lang = LangProvider.getMap('VCard Input');
  final all = <Map<String, dynamic>>[
    {'label': lang['nom'], 'controller': controllers['nom']},
    {'label': lang['prenom'], 'controller': controllers['prenom']},
    {'label': lang['nom2'], 'controller': controllers['nom2']},
    {'label': lang['prefixe'], 'controller': controllers['prefixe']},
    {'label': lang['suffixe'], 'controller': controllers['suffixe']},
    {'label': lang['org'], 'controller': controllers['org']},
    {'label': lang['job'], 'controller': controllers['job']},
    {'label': lang['photo'], 'controller': controllers['photo']},
    {
      'label': lang['tel_work'],
      'controller': controllers['tel_work'],
    },
    {
      'label': lang['tel_home'],
      'controller': controllers['tel_home'],
    },
    {
      'label': lang['adr_work'],
      'controller': controllers['adr_work'],
    },
    {
      'label': lang['adr_home'],
      'controller': controllers['adr_home'],
    },
    {'label': lang['email'], 'controller': controllers['email']},
  ];
  return all
      .where((f) => f['controller'] != null)
      .toList();
}

/// Returns the keys of [dict] as a List.
List<String> getKeys(Map<String, dynamic> dict) {
  return dict.keys.toList();
}

/// Reads the current text of every controller into a flat `Map<String,String>`.
Map<String, String> extractValues(
  Map<String, TextEditingController> controllers,
) {
  final keys = getKeys(controllers);
  return {for (final key in keys) key: controllers[key]!.text};
}

/// Reads [originalPath] from disk and prompts the user to save it as
/// `<fileName>.png` via the platform file picker.
Future<void> saveFile(String originalPath, String fileName) async {
  final fileBytes = await File(originalPath).readAsBytes();

  await FileSaver.instance.saveAs(
    name: fileName,
    bytes: fileBytes,
    fileExtension: 'png',
    mimeType: MimeType.png,
  );
}

/// Loads an asset image at [path] as raw bytes.
Future<Uint8List> loadAssetImage(String path) async {
  final data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

/// Returns today's date formatted as `dd/MM/yyyy`.
String getDateDays() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();

  return '$day/$month/$year';
}

/// Returns the names of every `.json` file bundled under [folderPath]
/// in the Flutter asset manifest.
Future<List<String>> getJsonFiles(String folderPath) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where((path) => path.startsWith(folderPath) && path.endsWith('.json'))
      .map((path) => path.split('/').last)
      .toList();
}

/// Returns true when [url] resolves to an `image/*` content-type via HEAD.
/// Returns false on any network error or non-image response.
Future<bool> isImageUrl(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null) {
        return contentType.startsWith('image/');
      }
    }
    // URL probing is best-effort: any failure (FormatException from
    // Uri.parse on garbage input, ArgumentError on malformed scheme,
    // SocketException offline) means "not a valid image URL".
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return false;
  }
  return false;
}
