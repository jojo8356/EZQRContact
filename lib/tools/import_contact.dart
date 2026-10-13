import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_app/components/contact_app.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

// Max contacts processed in one parallel batch. Limits peak isolate count
// while still saturating all CPU cores on typical phones (4–8 cores).
const _batchSize = 8;

/// Shows a dialog explaining that contacts permission is permanently denied
/// and offering a button to open the app settings page.
Future<void> _showPermissionDeniedDialog(BuildContext context) {
  final lang = LangProvider.section('permissions');
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: currentColors['bg'],
      title: Text(
        (lang['contacts_denied_title'] as String?) ??
            'Accès aux contacts requis',
        style: TextStyle(color: currentColors['text']),
      ),
      content: Text(
        (lang['contacts_denied_body'] as String?) ??
            "La permission a été refusée. Activez l'accès aux contacts"
            ' dans les Paramètres.',
        style: TextStyle(color: currentColors['text']),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            LangProvider.getString('close'),
            style: TextStyle(color: currentColors['button-color']),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await openAppSettings();
          },
          child: Text(
            (lang['open_settings'] as String?) ?? 'Ouvrir les Paramètres',
            style: TextStyle(color: currentColors['button-color']),
          ),
        ),
      ],
    ),
  );
}

/// Lowercase `prenom|nom` key used to skip duplicate imports.
String contactNameKey(Map<String, dynamic> row) {
  final prenom = ((row['prenom'] as String?) ?? '').trim().toLowerCase();
  final nom = ((row['nom'] as String?) ?? '').trim().toLowerCase();
  if (prenom.isEmpty && nom.isEmpty) {
    return '';
  }
  return '$prenom|$nom';
}

/// Incoming device contacts minus empty names and rows already in [existing].
List<Map<String, dynamic>> contactsToImport(
  List<Map<String, dynamic>> incoming,
  List<Map<String, dynamic>> existing,
) {
  final seen = <String>{};
  for (final row in existing) {
    final key = contactNameKey(row);
    if (key.isNotEmpty) {
      seen.add(key);
    }
  }
  final out = <Map<String, dynamic>>[];
  for (final row in incoming) {
    final key = contactNameKey(row);
    if (key.isEmpty) {
      continue;
    }
    if (seen.contains(key)) {
      continue;
    }
    seen.add(key);
    out.add(row);
  }
  return out;
}

/// Concatenates every vCard row into one `.vcf` document.
String vcardsToVcf(List<Map<String, dynamic>> rows) {
  final buffer = StringBuffer();
  for (final row in rows) {
    buffer.write(VCard.fromMap(row).toVCard());
  }
  return buffer.toString();
}

Future<bool> _ensureContactsPermission(BuildContext context) async {
  // Check before requesting so we can distinguish a hard denial from a
  // first-time prompt. A permanently-denied (or restricted) status means
  // the system dialog will NOT appear — we must direct the user to Settings.
  var status = await Permission.contacts.status;

  if (status.isPermanentlyDenied || status.isRestricted) {
    if (context.mounted) await _showPermissionDeniedDialog(context);
    return false;
  }

  if (!status.isGranted) {
    status = await Permission.contacts.request();
    if (!status.isGranted) return false;
  }
  return true;
}

Future<void> _importMapsWithProgress(
  BuildContext context,
  List<Map<String, dynamic>> contactsMap,
) async {
  if (contactsMap.isEmpty) return;

  final total = contactsMap.length;
  final progress = ValueNotifier<int>(0);
  final lang = LangProvider.section('pages.contact.import');

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: currentColors['bg'],
          title: Text(
            (lang['importing'] as String?) ?? 'Importation en cours...',
            style: TextStyle(color: currentColors['text'], fontSize: 16),
          ),
          content: ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (context2, current, child) {
              var progressValue = 0.0;
              if (total > 0) {
                progressValue = current / total;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progressValue,
                    color: currentColors['button-color'],
                    backgroundColor:
                        currentColors['text']?.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$current / $total',
                    style: TextStyle(
                      color: currentColors['text'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  try {
    for (var start = 0; start < total; start += _batchSize) {
      final end = (start + _batchSize).clamp(0, total);
      await createVCardsBatch(contactsMap.sublist(start, end));
      progress.value = end;
    }
  } finally {
    if (context.mounted) Navigator.of(context).pop();
    progress.dispose();
  }
}

/// Pushes [MultiContactPickerPage] so the user picks device contacts,
/// then persists each selection as a VCard row behind a progress dialog.
Future<void> importContacts(BuildContext context) async {
  final allowed = await _ensureContactsPermission(context);
  if (!allowed || !context.mounted) return;

  final contacts = await FlutterContacts.getAll(
    properties: ContactProperties.all,
  );
  if (contacts.isEmpty || !context.mounted) return;

  final popped = await redirect(
    context,
    MultiContactPickerPage(contacts: contacts),
  );
  if (popped is! List<Contact> || popped.isEmpty) return;
  if (!context.mounted) return;
  await _importMapsWithProgress(context, PhoneContacts.toMapList(popped));
}

/// Imports every device contact into the collection (no picker).
/// Skips nameless rows and contacts already stored under the same name.
Future<void> importAllDeviceContacts(BuildContext context) async {
  final allowed = await _ensureContactsPermission(context);
  if (!allowed || !context.mounted) return;

  final collection = LangProvider.section('pages.collection');
  final contacts = await FlutterContacts.getAll(
    properties: ContactProperties.all,
  );
  if (!context.mounted) return;

  if (contacts.isEmpty) {
    showToast(
      context: context,
      title: (collection['import_none'] as String?) ??
          'Aucun contact sur ce téléphone',
      color: Colors.white,
    );
    return;
  }

  final confirmTemplate = (collection['import_all_confirm'] as String?) ??
      'Importer %s contacts du téléphone ?';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: currentColors['bg'],
        content: Text(
          confirmTemplate.replaceFirst('%s', '${contacts.length}'),
          style: TextStyle(color: currentColors['text']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              LangProvider.getString('close'),
              style: TextStyle(color: currentColors['text-muted']),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              (collection['import_confirm'] as String?) ?? 'Importer',
              style: TextStyle(color: currentColors['button-color']),
            ),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;

  final existing = await QRDatabase().getAllVCards();
  final toInsert = contactsToImport(
    PhoneContacts.toMapList(contacts),
    existing,
  );
  if (!context.mounted) return;

  if (toInsert.isEmpty) {
    showToast(
      context: context,
      title: (collection['import_skip'] as String?) ??
          'Déjà dans la collection',
      color: Colors.white,
    );
    return;
  }

  await _importMapsWithProgress(context, toInsert);
  if (!context.mounted) return;
  final doneTemplate =
      (collection['import_done'] as String?) ?? '%s contacts importés';
  showToast(
    context: context,
    title: doneTemplate.replaceFirst('%s', '${toInsert.length}'),
    color: Colors.white,
  );
}

/// Writes every stored vCard to a single `.vcf` file via the system saver.
Future<void> exportAllVCards(BuildContext context) async {
  final collection = LangProvider.section('pages.collection');
  final rows = await QRDatabase().getAllVCards();
  if (!context.mounted) return;

  if (rows.isEmpty) {
    showToast(
      context: context,
      title: (collection['export_none'] as String?) ??
          'Aucune carte à exporter',
      color: Colors.white,
    );
    return;
  }

  final vcf = vcardsToVcf(rows);
  await FileSaver.instance.saveAs(
    name: 'ezqr_contacts',
    bytes: Uint8List.fromList(utf8.encode(vcf)),
    fileExtension: 'vcf',
    mimeType: MimeType.text,
  );
  if (!context.mounted) return;
  final doneTemplate =
      (collection['export_done'] as String?) ?? '%s contacts exportés';
  showToast(
    context: context,
    title: doneTemplate.replaceFirst('%s', '${rows.length}'),
    color: Colors.white,
  );
}
