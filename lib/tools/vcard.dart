import 'dart:convert';

import 'package:qr_code_app/tools/tools.dart';

/// In-memory representation of a vCard 4.0 contact, with helpers to
/// serialize to/from the legacy `Map<String, dynamic>` shape used by
/// `QRDatabase` and to the canonical RFC 6350 text encoding.
class VCard {

  /// Creates a VCard with the given fields. All string fields default to ''.
  /// [rev] auto-generates a UTC ISO8601 revision marker if omitted.
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

  /// Builds a VCard from a legacy `Map<String, dynamic>` payload, where
  /// missing or null values fall back to empty strings.
  factory VCard.fromMap(Map<String, dynamic> data) => VCard(
    nom: (data['nom'] as String?) ?? '',
    prenom: (data['prenom'] as String?) ?? '',
    nom2: (data['nom2'] as String?) ?? '',
    prefixe: (data['prefixe'] as String?) ?? '',
    suffixe: (data['suffixe'] as String?) ?? '',
    org: (data['org'] as String?) ?? '',
    job: (data['job'] as String?) ?? '',
    photo: (data['photo'] as String?) ?? '',
    telWork: (data['tel_work'] as String?) ?? '',
    telHome: (data['tel_home'] as String?) ?? '',
    adrWork: (data['adr_work'] as String?) ?? '',
    adrHome: (data['adr_home'] as String?) ?? '',
    email: (data['email'] as String?) ?? '',
    rev: data['rev'] as String?,
  );

  /// Parses an RFC 6350 vCard text [vcard] into a VCard instance. Only the
  /// subset of properties used by EZQRContact (N, FN, ORG, TITLE, PHOTO,
  /// TEL, ADR, EMAIL, REV) is recognized; everything else is ignored.
  factory VCard.parse(String vcard) {
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

  /// Last name (vCard `N` family-name component).
  String nom;

  /// First name (vCard `N` given-name component).
  String prenom;

  /// Additional name (vCard `N` middle-name component).
  String nom2;

  /// Honorific prefix (vCard `N` prefix component, e.g. "Dr.").
  String prefixe;

  /// Honorific suffix (vCard `N` suffix component, e.g. "Jr.").
  String suffixe;

  /// Organization name (vCard `ORG`).
  String org;

  /// Job title (vCard `TITLE`).
  String job;

  /// Photo URL or `data:image/...` base64 payload (vCard `PHOTO`).
  String photo;

  /// Work phone number (vCard `TEL;TYPE=work,voice`).
  String telWork;

  /// Home phone number (vCard `TEL;TYPE=home,voice`).
  String telHome;

  /// Work postal address (vCard `ADR;TYPE=work`).
  String adrWork;

  /// Home postal address (vCard `ADR`).
  String adrHome;

  /// Email address (vCard `EMAIL`).
  String email;

  /// Revision marker, set automatically when not provided (vCard `REV`).
  String rev;

  static String _generateRev() {
    final now = DateTime.now().toUtc();
    final iso = now
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .split('.')
        .first;
    return '${iso}Z';
  }

  /// Removes the `;` separator characters that would corrupt vCard
  /// serialization, returning '' for null inputs.
  String clean(String? value) {
    final cleaned = value?.replaceAll(';;', '') ?? '';
    return cleaned.replaceAll(';', ' ');
  }

  /// Serializes the VCard to the legacy flat `Map<String, String>` shape.
  /// The `photo` entry is only included when [isImageUrl] succeeds or the
  /// payload is an inline `data:image/` URI.
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

  /// Returns the VCard's flat map JSON-encoded.
  String toJson() => jsonEncode(toMap());

  /// Renders the VCard as an RFC 6350 vCard 4.0 text payload.
  String toVCard() {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:4.0')
      ..writeln(
        'N:${clean(nom)};${clean(prenom)};${clean(nom2)};'
        '${clean(prefixe)};${clean(suffixe)}',
      )
      ..writeln(
        'FN:${clean(prefixe)} ${clean(prenom)} '
        '${clean(nom)} ${clean(suffixe)}',
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
    buffer
      ..writeln('REV:${clean(rev)}')
      ..writeln('END:VCARD');

    return buffer.toString();
  }

  /// Returns true when [text] is a vCard payload (BEGIN/END:VCARD wrapper).
  static bool isVCard(String text) {
    final trimmed = text.trim().toUpperCase();
    return trimmed.startsWith('BEGIN:VCARD') && trimmed.endsWith('END:VCARD');
  }

  /// Returns a human-friendly display title: "prenom nom" when both are set,
  /// the concatenation if only one is set, or the org name as a fallback.
  String getTitle() {
    if (nom.isNotEmpty && prenom.isNotEmpty) return '$prenom $nom';
    if (nom.isNotEmpty || prenom.isNotEmpty) return '$prenom$nom';
    return org;
  }
}
