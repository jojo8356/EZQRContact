import 'dart:convert';

import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/tools.dart';

/// CRLF line separator imposed by RFC 2426 (vCard 3.0) and RFC 6350
/// (vCard 4.0) between every content line, including the last one before
/// `END:VCARD`.
const String _crlf = '\r\n';

/// In-memory representation of a vCard contact, with helpers to serialize
/// to/from the legacy `Map<String, dynamic>` shape used by `QRDatabase` and
/// to/from the canonical vCard text encoding (3.0 by default, 4.0 when
/// [VCardSettingsProvider.useVCard4] is opt-in).
class VCard {

  /// Creates a VCard with the given fields. All string fields default to ''.
  /// [rev] auto-generates a UTC ISO8601 revision marker if omitted.
  /// [visualConfigJson] is the raw JSON from the `visual_config` DB column;
  /// when non-null it is encoded into `X-EZQR-VISUAL` on serialisation.
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
    this.visualConfigJson,
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
    visualConfigJson: data['visual_config'] as String?,
  );

  /// Parses a vCard text [vcard] into a VCard instance. Detects the
  /// `VERSION:` line (2.1 / 3.0 / 4.0) and applies version-specific
  /// rules: line unfolding (RFC 6350 §3.2), `TEL;VALUE=uri:tel:` for
  /// 4.0, `TEL;TYPE=` for 3.0, best-effort for 2.1.
  ///
  /// Only the subset of properties used by EZQRContact (N, FN, ORG,
  /// TITLE, PHOTO, TEL, ADR, EMAIL, REV) is recognized; everything else
  /// is ignored.
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

    final lines = _unfoldLines(vcard);
    final version = _detectVersion(lines);

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.toUpperCase().startsWith('BEGIN:') ||
          line.toUpperCase().startsWith('END:') ||
          line.toUpperCase().startsWith('VERSION:')) {
        continue;
      }

      final colonIdx = line.indexOf(':');
      if (colonIdx == -1) continue;
      final propPart = line.substring(0, colonIdx);
      final value = line.substring(colonIdx + 1);
      final segments = propPart.split(';');
      var name = segments.first.toUpperCase();
      // Apple Contacts exports group related properties with an
      // `itemN.` prefix (e.g. `item1.ADR`, `item1.X-ABLabel`). The
      // prefix carries no semantic value for our subset, strip it.
      final dotIdx = name.indexOf('.');
      if (dotIdx != -1 && RegExp(r'^ITEM\d+$').hasMatch(name.substring(0, dotIdx))) {
        name = name.substring(dotIdx + 1);
      }
      final params = segments.skip(1).map((s) => s.toUpperCase()).toList();

      if (name == 'N') {
        final parts = value.split(';');
        data['nom'] = parts.isNotEmpty ? parts[0] : '';
        data['prenom'] = parts.length > 1 ? parts[1] : '';
        data['nom2'] = parts.length > 2 ? parts[2] : '';
        data['prefixe'] = parts.length > 3 ? parts[3] : '';
        data['suffixe'] = parts.length > 4 ? parts[4] : '';
      } else if (name == 'ORG') {
        // ORG components are `;`-separated (org-name;unit;unit). We keep
        // the full string — the model is single-field.
        data['org'] = value;
      } else if (name == 'TITLE') {
        data['job'] = value;
      } else if (name == 'PHOTO') {
        data['photo'] = _decodePhoto(value, params);
      } else if (name == 'TEL') {
        final typed = _classifyTel(params, version);
        final phone = _extractTelValue(value, params);
        if (typed == _TelKind.work && (data['tel_work'] ?? '').isEmpty) {
          data['tel_work'] = phone;
        } else if (typed == _TelKind.home && (data['tel_home'] ?? '').isEmpty) {
          data['tel_home'] = phone;
        } else if ((data['tel_home'] ?? '').isEmpty) {
          // Untyped TEL: store on home as best-effort.
          data['tel_home'] = phone;
        }
      } else if (name == 'ADR') {
        final kind = _classifyAdr(params);
        if (kind == _AdrKind.work && (data['adr_work'] ?? '').isEmpty) {
          data['adr_work'] = value;
        } else if (kind == _AdrKind.home && (data['adr_home'] ?? '').isEmpty) {
          data['adr_home'] = value;
        } else if ((data['adr_home'] ?? '').isEmpty) {
          data['adr_home'] = value;
        }
      } else if (name == 'EMAIL') {
        if ((data['email'] ?? '').isEmpty) data['email'] = value;
      } else if (name == 'URL') {
        // Legacy fallback: some 2.1 exporters put the photo URL in URL.
        if ((data['photo'] ?? '').isEmpty) data['photo'] = value;
      } else if (name == 'REV') {
        data['rev'] = value;
      } else if (name == 'X-EZQR-VISUAL') {
        try {
          final decoded = utf8.decode(base64Decode(value));
          jsonDecode(decoded); // validate JSON
          data['visual_config'] = decoded;
        } on Object catch (_) {}
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

  /// Work phone number (vCard `TEL;TYPE=WORK,VOICE`).
  String telWork;

  /// Home phone number (vCard `TEL;TYPE=HOME,VOICE`).
  String telHome;

  /// Work postal address (vCard `ADR;TYPE=WORK`).
  String adrWork;

  /// Home postal address (vCard `ADR;TYPE=HOME`).
  String adrHome;

  /// Email address (vCard `EMAIL`).
  String email;

  /// Revision marker, set automatically when not provided (vCard `REV`).
  String rev;

  /// Raw JSON from the `visual_config` DB column. When non-null, encoded as
  /// `X-EZQR-VISUAL:<base64>` in the serialised vCard (story 5-1).
  /// Logo is stripped before embedding to keep the QR scannable.
  String? visualConfigJson;

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

  /// Strips characters that would corrupt vCard serialization or violate
  /// the encoding contract:
  /// - `;` (vCard component separator) — stripped (story 2.3 spec).
  /// - `\r`, `\n`, `\r\n` (would inject new content lines) — stripped.
  /// - C0 control characters (U+0000–U+001F) except TAB (U+0009) — dropped.
  /// - DEL (U+007F) — dropped.
  /// - Unpaired UTF-16 surrogates (U+D800–U+DFFF) — dropped (invalid UTF-8).
  /// - Non-character code points U+FFFE / U+FFFF — dropped.
  ///
  /// Emojis and printable non-ASCII Unicode (accents, CJK, supplementary
  /// planes) are preserved. Returns '' for null or empty input.
  String clean(String? value) {
    if (value == null || value.isEmpty) return '';

    // Strip literal \n and \r escape sequences (backslash + n/r) that arrive
    // from clipboard pastes or JSON-formatted sources. These are distinct from
    // the actual CR/LF code-points handled by the rune loop below.
    // ignore: parameter_assignments
    value = value.replaceAll(r'\n', '').replaceAll(r'\r', '');

    final buffer = StringBuffer();
    for (final rune in value.runes) {
      // Drop CR/LF — would inject new content lines.
      if (rune == 0x0A || rune == 0x0D) continue;
      // Drop semicolons — would prematurely close vCard components.
      if (rune == 0x3B) continue;
      // Drop C0 controls except TAB (U+0009).
      if (rune < 0x20 && rune != 0x09) continue;
      // Drop DEL.
      if (rune == 0x7F) continue;
      // Drop unpaired surrogates (invalid UTF-8 by itself).
      if (rune >= 0xD800 && rune <= 0xDFFF) continue;
      // Drop non-character code points U+FFFE and U+FFFF.
      if (rune == 0xFFFE || rune == 0xFFFF) continue;
      buffer.writeCharCode(rune);
    }
    return buffer.toString();
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

    if (visualConfigJson != null && visualConfigJson!.isNotEmpty) {
      map['visual_config'] = visualConfigJson!;
    }

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

  /// Renders the VCard as a vCard text payload. Returns vCard 3.0
  /// (RFC 2426) by default; emits vCard 4.0 (RFC 6350) instead when
  /// [VCardSettingsProvider.useVCard4] is true.
  ///
  /// Both versions enforce CRLF (`\r\n`) between content lines and RFC
  /// 2425/6350 line folding (75-octet limit, continuation with `\r\n `).
  String toVCard() {
    if (VCardSettingsProvider.useVCard4) return _toVCard4();
    return _toVCard3();
  }

  String _toVCard3() {
    // N and FN are REQUIRED in vCard 3.0 (RFC 2426 §3.1) — emit even
    // when fully empty; the parser side handles it.
    final n = 'N:${clean(nom)};${clean(prenom)};${clean(nom2)};'
        '${clean(prefixe)};${clean(suffixe)}';
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      n,
      'FN:${_buildFn()}',
    ];

    if (org.isNotEmpty) lines.add('ORG:${clean(org)}');
    if (job.isNotEmpty) lines.add('TITLE:${clean(job)}');
    final photoLine = _buildPhotoLine(useV4: false);
    if (photoLine != null) lines.add(photoLine);

    if (telWork.isNotEmpty) {
      lines.add('TEL;TYPE=WORK,VOICE:${clean(telWork)}');
    }
    if (telHome.isNotEmpty) {
      lines.add('TEL;TYPE=HOME,VOICE:${clean(telHome)}');
    }
    if (adrWork.isNotEmpty) {
      lines.add('ADR;TYPE=WORK:${_buildAdrValue(adrWork)}');
    }
    if (adrHome.isNotEmpty) {
      lines.add('ADR;TYPE=HOME:${_buildAdrValue(adrHome)}');
    }
    if (email.isNotEmpty) {
      lines.add('EMAIL;TYPE=INTERNET:${clean(email)}');
    }
    _addVisualProperty(lines);
    lines
      ..add('REV:${clean(rev)}')
      ..add('END:VCARD');

    return _assemble(lines);
  }

  String _toVCard4() {
    final n = 'N:${clean(nom)};${clean(prenom)};${clean(nom2)};'
        '${clean(prefixe)};${clean(suffixe)}';
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:4.0',
      n,
      'FN:${_buildFn()}',
    ];

    if (org.isNotEmpty) lines.add('ORG:${clean(org)}');
    if (job.isNotEmpty) lines.add('TITLE:${clean(job)}');
    final photoLine = _buildPhotoLine(useV4: true);
    if (photoLine != null) lines.add(photoLine);

    if (telWork.isNotEmpty) {
      lines.add('TEL;TYPE=work,voice;VALUE=uri:tel:${clean(telWork)}');
    }
    if (telHome.isNotEmpty) {
      lines.add('TEL;TYPE=home,voice;VALUE=uri:tel:${clean(telHome)}');
    }
    if (adrWork.isNotEmpty) {
      lines.add(
        'ADR;TYPE=work;LABEL="${clean(adrWork)}":'
        '${_buildAdrValue(adrWork)}',
      );
    }
    if (adrHome.isNotEmpty) {
      lines.add(
        'ADR;TYPE=home;LABEL="${clean(adrHome)}":'
        '${_buildAdrValue(adrHome)}',
      );
    }
    if (email.isNotEmpty) lines.add('EMAIL:${clean(email)}');
    _addVisualProperty(lines);
    lines
      ..add('REV:${clean(rev)}')
      ..add('END:VCARD');

    return _assemble(lines);
  }

  String _buildFn() {
    // RFC 2426: FN is mandatory; we synthesize from prefix/given/family/suffix.
    final parts = <String>[
      if (prefixe.isNotEmpty) clean(prefixe),
      if (prenom.isNotEmpty) clean(prenom),
      if (nom.isNotEmpty) clean(nom),
      if (suffixe.isNotEmpty) clean(suffixe),
    ];
    if (parts.isEmpty) return clean(org);
    return parts.join(' ');
  }

  /// Builds the structured `ADR` value:
  /// `PO;Ext;Street;Locality;Region;Code;Country`. Our model has a single
  /// free-form string; we map it into the `Street` component (3rd field)
  /// so it round-trips through iOS / Google parsers that key on positional
  /// fields.
  String _buildAdrValue(String addr) {
    final cleaned = clean(addr);
    return ';;$cleaned;;;;';
  }

  String? _buildPhotoLine({required bool useV4}) {
    if (photo.isEmpty) return null;
    if (photo.startsWith('data:image/')) {
      if (useV4) return 'PHOTO:$photo';
      // vCard 3.0: data: URIs aren't standard. Translate to inline base64
      // with ENCODING=b and TYPE=<mediaType>.
      final match = RegExp(r'^data:image/([^;]+);base64,(.+)$')
          .firstMatch(photo);
      if (match != null) {
        final mediaType = match.group(1)!.toUpperCase();
        final b64 = match.group(2)!;
        return 'PHOTO;ENCODING=b;TYPE=$mediaType:$b64';
      }
      // Fallback: emit as-is (best-effort).
      return 'PHOTO:$photo';
    }
    if (useV4) return 'PHOTO;VALUE=uri:$photo';
    return 'PHOTO;VALUE=URI:$photo';
  }

  /// Appends an `X-EZQR-VISUAL` property to [lines] when [visualConfigJson]
  /// is non-null. The logo is stripped before embedding to keep the QR code
  /// scannable (story 5-1).
  void _addVisualProperty(List<String> lines) {
    final json = visualConfigJson;
    if (json == null || json.isEmpty) return;
    try {
      // Parse and re-serialise without logoBase64 to bound the QR payload.
      final map = (jsonDecode(json) as Map<String, dynamic>)
        ..remove('logoBase64');
      final compact = jsonEncode(map);
      final encoded = base64Encode(utf8.encode(compact));
      lines.add('X-EZQR-VISUAL:$encoded');
    } on Object catch (_) {
      // Malformed JSON: skip the property rather than crashing.
    }
  }

  /// Assembles content lines into the final CRLF-separated payload with
  /// RFC 2425 §5.8.1 line folding at the 75-octet boundary.
  String _assemble(List<String> lines) {
    final buffer = StringBuffer();
    for (final line in lines) {
      buffer
        ..write(_foldLine(line))
        ..write(_crlf);
    }
    return buffer.toString();
  }

  /// Folds a single content line so that no resulting physical line
  /// exceeds 75 **octets** of UTF-8 (per RFC 6350 §3.2). Continuation
  /// lines are prefixed by `\r\n ` (CRLF + single space).
  static String _foldLine(String line) {
    const limit = 75;
    final bytes = utf8.encode(line);
    if (bytes.length <= limit) return line;

    final buffer = StringBuffer();
    var offset = 0;
    var isFirst = true;
    while (offset < bytes.length) {
      // First physical line: 75 octets of content.
      // Continuation lines: leading space counts toward the 75-octet
      // limit (RFC 6350 §3.2), so content is capped at 74 octets.
      var take = isFirst ? limit : limit - 1;
      if (offset + take > bytes.length) take = bytes.length - offset;

      // Don't split a multi-byte UTF-8 sequence: back off until we land
      // on a code-unit boundary.
      while (take > 0 &&
          offset + take < bytes.length &&
          (bytes[offset + take] & 0xC0) == 0x80) {
        take--;
      }
      if (take == 0) {
        // Shouldn't happen with valid UTF-8 input, but guard anyway.
        take = limit;
      }

      final segment = utf8.decode(bytes.sublist(offset, offset + take));
      if (isFirst) {
        buffer.write(segment);
        isFirst = false;
      } else {
        buffer
          ..write(_crlf)
          ..write(' ')
          ..write(segment);
      }
      offset += take;
    }
    return buffer.toString();
  }

  /// RFC 6350 §3.2 line unfolding: merge any line starting with a single
  /// space or tab into the previous line. Supports both CRLF and LF
  /// terminators.
  static List<String> _unfoldLines(String text) {
    final raw = text.split(RegExp(r'\r?\n'));
    final out = <String>[];
    for (final line in raw) {
      if (line.isNotEmpty &&
          (line.startsWith(' ') || line.startsWith('\t')) &&
          out.isNotEmpty) {
        out[out.length - 1] = out.last + line.substring(1);
      } else {
        out.add(line);
      }
    }
    return out;
  }

  /// Detects the vCard version from the `VERSION:` header. Returns the
  /// version string (`'2.1'`, `'3.0'`, `'4.0'`); defaults to `'3.0'` when
  /// missing (best-effort for malformed input).
  static String _detectVersion(List<String> lines) {
    for (final line in lines) {
      final t = line.trim().toUpperCase();
      if (t.startsWith('VERSION:')) {
        return t.substring('VERSION:'.length).trim();
      }
    }
    return '3.0';
  }

  static _TelKind _classifyTel(List<String> params, String version) {
    final joined = params.join(',');
    final isWork = joined.contains('WORK');
    final isHome = joined.contains('HOME');
    final isCell = joined.contains('CELL') || joined.contains('MOBILE');
    if (isWork) return _TelKind.work;
    if (isHome || isCell) return _TelKind.home;
    return _TelKind.other;
  }

  static String _extractTelValue(String value, List<String> params) {
    // vCard 4.0 may encode as `tel:+33...` URI; strip the scheme.
    if (value.toLowerCase().startsWith('tel:')) {
      return value.substring(4);
    }
    return value;
  }

  static _AdrKind _classifyAdr(List<String> params) {
    final joined = params.join(',');
    if (joined.contains('WORK')) return _AdrKind.work;
    if (joined.contains('HOME')) return _AdrKind.home;
    return _AdrKind.other;
  }

  /// Decodes a `PHOTO` value into our model's flat string:
  /// - `PHOTO;ENCODING=b;TYPE=JPEG:<b64>` → `data:image/jpeg;base64,<b64>`
  /// - `PHOTO;VALUE=URI:https://...` or `PHOTO:https://...` → `https://...`
  /// - `PHOTO:data:image/...;base64,...` (4.0) → passthrough.
  static String _decodePhoto(String value, List<String> params) {
    if (value.startsWith('data:image/')) return value;
    final joined = params.join(';');
    final isBase64 = joined.contains('ENCODING=B') ||
        joined.contains('ENCODING=BASE64');
    if (isBase64) {
      var mime = 'jpeg';
      for (final p in params) {
        if (p.startsWith('TYPE=')) {
          mime = p.substring('TYPE='.length).toLowerCase();
          break;
        }
      }
      return 'data:image/$mime;base64,$value';
    }
    return value;
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

enum _TelKind { work, home, other }

enum _AdrKind { work, home, other }
