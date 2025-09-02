import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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

String generateVCardFromData(Map<String, dynamic> data) {
  final now = DateTime.now().toUtc();
  final rev =
      '${now.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

  return '''
BEGIN:VCARD
VERSION:4.0
N:${data['nom'] ?? ''};${data['prenom'] ?? ''};${data['nom2'] ?? ''};${data['prefixe'] ?? ''};${data['suffixe'] ?? ''}
FN:${data['prefixe'] ?? ''} ${data['prenom'] ?? ''} ${data['nom'] ?? ''} ${data['suffixe'] ?? ''}
ORG:${data['org'] ?? ''}
TITLE:${data['job'] ?? ''}
${(data['photo'] ?? '').isNotEmpty ? 'PHOTO;MEDIATYPE=image/jpeg:${data['photo']}' : ''}
${(data['tel_work'] ?? '').isNotEmpty ? 'TEL;TYPE=_work,voice;VALUE=uri:tel:${data['tel_work']}' : ''}
${(data['tel_home'] ?? '').isNotEmpty ? 'TEL;TYPE=_home,voice;VALUE=uri:tel:${data['tel_home']}' : ''}
${(data['adr_work'] ?? '').isNotEmpty ? 'ADR;TYPE=_work;LABEL="${data['adr_work']}":${data['adr_work']}' : ''}
${(data['adr_home'] ?? '').isNotEmpty ? 'ADR;TYPE=_home;LABEL="${data['adr_home']}":${data['adr_home']}' : ''}
EMAIL:${data['email'] ?? ''}
REV:$rev
END:VCARD
''';
}

bool isVCard(String text) {
  final trimmed = text.trim().toUpperCase();
  return trimmed.startsWith('BEGIN:VCARD') && trimmed.endsWith('END:VCARD');
}

Map<String, String> parseVCard(String vcard) {
  final Map<String, String> data = {
    'nom': '',
    'prenom': '',
    'nom2': '',
    'prefixe': '',
    'suffixe': '',
    'org': '',
    'job': '',
    'photo': '',
    'tel_work': '',
    'tel_home': '',
    'adr_work': '',
    'adr_home': '',
    'email': '',
    'rev': '',
  };

  final lines = vcard.split(RegExp(r'\r?\n'));
  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('N:')) {
      final parts = line.substring(2).split(';');
      data['nom'] = parts.isNotEmpty ? parts[0] : '';
      data['prenom'] = parts.length > 1 ? parts[1] : '';
      data['nom2'] = parts.length > 2 ? parts[2] : '';
      data['prefixe'] = parts.length > 3 ? parts[3] : '';
      data['suffixe'] = parts.length > 4 ? parts[4] : '';
    } else if (line.startsWith('FN:')) {
      // optionnel, déjà couvert par N
    } else if (line.startsWith('ORG:')) {
      data['org'] = line.substring(4);
    } else if (line.startsWith('TITLE:')) {
      data['job'] = line.substring(6);
    } else if (line.startsWith('PHOTO')) {
      final index = line.indexOf(':');
      if (index != -1) data['photo'] = line.substring(index + 1);
    } else if (line.startsWith('TEL;TYPE=_work')) {
      final index = line.indexOf(':tel:');
      if (index != -1) data['tel_work'] = line.substring(index + 5);
    } else if (line.startsWith('TEL;TYPE=_home')) {
      final index = line.indexOf(':tel:');
      if (index != -1) data['tel_home'] = line.substring(index + 5);
    } else if (line.startsWith('ADR;TYPE=_work')) {
      final index = line.indexOf(':');
      if (index != -1) data['adr_work'] = line.substring(index + 1);
    } else if (line.startsWith('ADR;TYPE=_home')) {
      final index = line.indexOf(':');
      if (index != -1) data['adr_home'] = line.substring(index + 1);
    } else if (line.startsWith('EMAIL:')) {
      data['email'] = line.substring(6);
    } else if (line.startsWith('REV:')) {
      data['rev'] = line.substring(4);
    }
  }

  return data;
}

String getTitleAndPhoto(Map<String, dynamic> item) {
  final data = item['data'] as Map<String, dynamic>;
  final isVCard = item['type'] == 'vcard';

  String title;

  if (isVCard) {
    final nom = data['nom'] ?? '';
    final prenom = data['prenom'] ?? '';
    final org = data['org'] ?? '';

    if (nom.isNotEmpty && prenom.isNotEmpty) {
      title = '$prenom $nom';
    } else if (nom.isNotEmpty || prenom.isNotEmpty) {
      title = '$prenom$nom';
    } else {
      title = org;
    }
  } else {
    title = data['text'] ?? '';
  }

  return title;
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
  return [
    {"label": "Name", "controller": controllers["nom"]},
    {"label": "Surname", "controller": controllers["prenom"]},
    {"label": "Name2", "controller": controllers["nom2"]},
    {"label": "Prefix", "controller": controllers["prefixe"]},
    {"label": "Suffix", "controller": controllers["suffixe"]},
    {"label": "Incorporation", "controller": controllers["org"]},
    {"label": "Job", "controller": controllers["job"]},
    {"label": "Photo URL", "controller": controllers["photo"]},
    {"label": "Work phone", "controller": controllers["tel_work"]},
    {"label": "Home phone", "controller": controllers["tel_home"]},
    {"label": "Work address", "controller": controllers["adr_work"]},
    {"label": "Home address", "controller": controllers["adr_home"]},
    {"label": "Email", "controller": controllers["email"]},
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

Future<bool> verifContact() async {
  var status = await Permission.contacts.status;

  if (!status.isGranted) {
    status = await Permission.contacts.request();
  }

  return status.isGranted;
}

Future<Uint8List> loadAssetImage(String path) async {
  final ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

Widget closeButton(BuildContext context) => TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Close'),
);

String getDateDays() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();

  return '$day/$month/$year';
}
