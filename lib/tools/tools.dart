import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_app/providers/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> shouldShowGuide() async {
  final prefs = await SharedPreferences.getInstance();
  final hasShown = prefs.getInt('guideShown') ?? 0;
  return hasShown == 0;
}

Future<void> markGuideShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('guideShown', 1);
}

Map<String, TextEditingController> mapToControllers(Map<String, dynamic> data) {
  return {
    "nom": TextEditingController(text: data['nom'] ?? ""),
    "prenom": TextEditingController(text: data['prenom'] ?? ""),
    "nom2": TextEditingController(text: data['nom2'] ?? ""),
    "prefixe": TextEditingController(text: data['prefixe'] ?? ""),
    "suffixe": TextEditingController(text: data['suffixe'] ?? ""),
    "org": TextEditingController(text: data['org'] ?? ""),
    "job": TextEditingController(text: data['job'] ?? ""),
    "photo": TextEditingController(text: data['photo'] ?? ""),
    "tel_work": TextEditingController(text: data['tel_work'] ?? ""),
    "tel_home": TextEditingController(text: data['tel_home'] ?? ""),
    "adr_work": TextEditingController(text: data['adr_work'] ?? ""),
    "adr_home": TextEditingController(text: data['adr_home'] ?? ""),
    "email": TextEditingController(text: data['email'] ?? ""),
  };
}

Widget buildItemAvatar(bool isVCard, String photo) {
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

Future<dynamic> redirect(BuildContext context, Widget page) {
  return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

List<Map<String, dynamic>> buildFields(
  Map<String, TextEditingController> controllers,
) {
  final lang = LangProvider.get('VCard Input');
  return [
    {"label": lang['nom'], "controller": controllers["nom"]},
    {"label": lang['prenom'], "controller": controllers["prenom"]},
    {"label": lang['nom2'], "controller": controllers["nom2"]},
    {"label": lang['prefixe'], "controller": controllers["prefixe"]},
    {"label": lang['suffixe'], "controller": controllers["suffixe"]},
    {"label": lang['org'], "controller": controllers["org"]},
    {"label": lang['job'], "controller": controllers["job"]},
    {"label": lang['photo'], "controller": controllers["photo"]},
    {"label": lang['tel_work'], "controller": controllers["tel_work"]},
    {"label": lang['tel_home'], "controller": controllers["tel_home"]},
    {"label": lang['adr_work'], "controller": controllers["adr_work"]},
    {"label": lang['adr_home'], "controller": controllers["adr_home"]},
    {"label": lang['email'], "controller": controllers["email"]},
  ];
}

List<String> getKeys(Map<String, dynamic> dict) {
  return dict.keys.toList();
}

Map<String, String> extractValues(
  Map<String, TextEditingController> controllers,
) {
  final keys = getKeys(controllers);
  return {for (var key in keys) key: controllers[key]!.text};
}

Future<void> saveFile(String originalPath, String fileName) async {
  final fileBytes = await File(originalPath).readAsBytes();

  await FileSaver.instance.saveAs(
    name: fileName,
    bytes: fileBytes,
    fileExtension: 'png',
    mimeType: MimeType.png,
  );
}

Future<Uint8List> loadAssetImage(String path) async {
  final ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

String getDateDays() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();

  return '$day/$month/$year';
}

Future<List<String>> getJsonFiles(String folderPath) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final jsonFiles = manifestMap.keys
      .where((path) => path.startsWith(folderPath) && path.endsWith('.json'))
      .map((path) => path.split('/').last)
      .toList();

  return jsonFiles;
}

Future<bool> isImageUrl(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null) {
        return contentType.startsWith('image/');
      }
    }
  } catch (e) {
    // URL invalide ou problème réseau
    return false;
  }
  return false;
}
