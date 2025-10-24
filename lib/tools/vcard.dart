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

  Map<String, String> toMap() => {
    'nom': nom,
    'prenom': prenom,
    'nom2': nom2,
    'prefixe': prefixe,
    'suffixe': suffixe,
    'org': org,
    'job': job,
    'photo': photo,
    'tel_work': telWork,
    'tel_home': telHome,
    'adr_work': adrWork,
    'adr_home': adrHome,
    'email': email,
    'rev': rev,
  };

  String toVCard() {
    return '''
BEGIN:VCARD
VERSION:4.0
N:$nom;$prenom;$nom2;$prefixe;$suffixe
FN:$prefixe $prenom $nom $suffixe
ORG:$org
TITLE:$job
${photo.isNotEmpty ? 'PHOTO;MEDIATYPE=image/jpeg:$photo' : ''}
${telWork.isNotEmpty ? 'TEL;TYPE=_work,voice;VALUE=uri:tel:$telWork' : ''}
${telHome.isNotEmpty ? 'TEL;TYPE=_home,voice;VALUE=uri:tel:$telHome' : ''}
${adrWork.isNotEmpty ? 'ADR;TYPE=_work;LABEL="$adrWork":$adrWork' : ''}
${adrHome.isNotEmpty ? 'ADR;TYPE=_home;LABEL="$adrHome":$adrHome' : ''}
EMAIL:$email
REV:$rev
END:VCARD
''';
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

    return VCard.fromMap(data);
  }

  String getTitle() {
    if (nom.isNotEmpty && prenom.isNotEmpty) return '$prenom $nom';
    if (nom.isNotEmpty || prenom.isNotEmpty) return '$prenom$nom';
    return org;
  }
}
