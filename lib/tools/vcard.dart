import 'dart:convert';

import 'package:qr_code_app/tools/tools.dart';

class VCard {
  String nom;
  String prenom;
  String nom2;
  String prefixe;
  String suffixe;
  String org;
  String job;
  String photo;
  String telWork;
  String telHome;
  String adrWork;
  String adrHome;
  String email;
  String rev;

  VCard({
    this.nom = '',
    this.prenom = '',
    this.nom2 = '',
    this.prefixe = '',
    this.suffixe = '',
    this.org = '',
    this.job = '',
    this.photo = '',
    this.telWork = '',
    this.telHome = '',
    this.adrWork = '',
    this.adrHome = '',
    this.email = '',
    String? rev,
  }) : rev = rev ?? _generateRev();

  static String _generateRev() {
    final now = DateTime.now().toUtc();
    return '${now.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';
  }

  factory VCard.fromMap(Map<String, dynamic> data) => VCard(
    nom: data['nom'] ?? '',
    prenom: data['prenom'] ?? '',
    nom2: data['nom2'] ?? '',
    prefixe: data['prefixe'] ?? '',
    suffixe: data['suffixe'] ?? '',
    org: data['org'] ?? '',
    job: data['job'] ?? '',
    photo: data['photo'] ?? '',
    telWork: data['tel_work'] ?? '',
    telHome: data['tel_home'] ?? '',
    adrWork: data['adr_work'] ?? '',
    adrHome: data['adr_home'] ?? '',
    email: data['email'] ?? '',
    rev: data['rev'],
  );

  String clean(String? value) {
    value = value?.replaceAll(';;', '') ?? '';
    return value.replaceAll(';', ' ');
  }

  Future<Map<String, String>> toMap() async {
    final map = <String, String>{
      'nom': clean(nom),
      'prenom': clean(prenom),
      'nom2': clean(nom2),
      'prefixe': clean(prefixe),
      'suffixe': clean(suffixe),
      'org': clean(org),
      'job': clean(job),
      'tel_work': clean(telWork),
      'tel_home': clean(telHome),
      'adr_work': clean(adrWork),
      'adr_home': clean(adrHome),
      'email': clean(email),
      'rev': clean(rev),
    };

    if (photo.isNotEmpty) {
      final isValid =
          await isImageUrl(photo) || photo.startsWith('data:image/');
      if (isValid) {
        map['photo'] = clean(photo);
      }
    }

    return map;
  }

  String toJson() => jsonEncode(toMap());

  String toVCard() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:4.0');
    buffer.writeln(
      'N:${clean(nom)};${clean(prenom)};${clean(nom2)};${clean(prefixe)};${clean(suffixe)}',
    );
    buffer.writeln(
      'FN:${clean(prefixe)} ${clean(prenom)} ${clean(nom)} ${clean(suffixe)}',
    );
    if (org.isNotEmpty) buffer.writeln('ORG:${clean(org)}');
    if (job.isNotEmpty) buffer.writeln('TITLE:${clean(job)}');

    // PHOTO : base64 ou URL
    if (photo.isNotEmpty) {
      if (photo.startsWith('data:image/')) {
        buffer.writeln('PHOTO:$photo');
      } else {
        buffer.writeln('PHOTO;VALUE=uri:$photo');
      }
    }

    if (telWork.isNotEmpty) {
      buffer.writeln('TEL;TYPE=work,voice;VALUE=uri:tel:${clean(telWork)}');
    }
    if (telHome.isNotEmpty) {
      buffer.writeln('TEL;TYPE=home,voice;VALUE=uri:tel:${clean(telHome)}');
    }
    if (adrWork.isNotEmpty) {
      buffer.writeln(
        'ADR;TYPE=work;LABEL="${clean(adrWork)}":${clean(adrWork)}',
      );
    }
    if (adrHome.isNotEmpty) {
      buffer.writeln(
        'ADR;TYPE=home;LABEL="${clean(adrHome)}":${clean(adrHome)}',
      );
    }
    if (email.isNotEmpty) buffer.writeln('EMAIL:${clean(email)}');
    buffer.writeln('REV:${clean(rev)}');
    buffer.writeln('END:VCARD');

    return buffer.toString();
  }

  static bool isVCard(String text) {
    final trimmed = text.trim().toUpperCase();
    return trimmed.startsWith('BEGIN:VCARD') && trimmed.endsWith('END:VCARD');
  }

  static VCard parse(String vcard) {
    final data = <String, String>{
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

    for (var line in vcard.split(RegExp(r'\r?\n'))) {
      line = line.trim();
      if (line.startsWith('N:')) {
        final parts = line.substring(2).split(';');
        data['nom'] = parts.isNotEmpty ? parts[0] : '';
        data['prenom'] = parts.length > 1 ? parts[1] : '';
        data['nom2'] = parts.length > 2 ? parts[2] : '';
        data['prefixe'] = parts.length > 3 ? parts[3] : '';
        data['suffixe'] = parts.length > 4 ? parts[4] : '';
      } else if (line.startsWith('ORG:')) {
        data['org'] = line.substring(4);
      } else if (line.startsWith('TITLE:')) {
        data['job'] = line.substring(6);
      } else if (line.startsWith('PHOTO')) {
        final index = line.indexOf(':');
        if (index != -1) data['photo'] = line.substring(index + 1);
      } else if (line.startsWith('TEL;TYPE=work') ||
          line.startsWith('TEL;WORK')) {
        final index = line.indexOf(':');
        if (index != -1) data['tel_work'] = line.substring(index + 1);
      } else if (line.startsWith('TEL;TYPE=cell') ||
          line.startsWith('TEL;CELL')) {
        final index = line.indexOf(':');
        if (index != -1) data['tel_home'] = line.substring(index + 1);
      } else if (line.startsWith('ADR;WORK') ||
          line.startsWith('ADR;TYPE=work')) {
        final index = line.indexOf(':');
        if (index != -1) data['adr_work'] = line.substring(index + 1);
      } else if (line.startsWith('URL:')) {
        data['photo'] = line.substring(4);
      }
    }

    return VCard.fromMap(data);
  }

  String getTitle() {
    if (nom.isNotEmpty && prenom.isNotEmpty) return '$prenom $nom';
    if (nom.isNotEmpty || prenom.isNotEmpty) return '$prenom$nom';
    return org;
  }
}
