import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_app/components/contact_app.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

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

/// Pushes [MultiContactPickerPage] so the user picks device contacts,
/// then persists each selection as a VCard row behind a progress dialog.
Future<void> importContacts(BuildContext context) async {
  // Check before requesting so we can distinguish a hard denial from a
  // first-time prompt. A permanently-denied (or restricted) status means
  // the system dialog will NOT appear — we must direct the user to Settings.
  var status = await Permission.contacts.status;

  if (status.isPermanentlyDenied || status.isRestricted) {
    if (context.mounted) await _showPermissionDeniedDialog(context);
    return;
  }

  if (!status.isGranted) {
    status = await Permission.contacts.request();
    if (!status.isGranted) return; // user dismissed the system dialog
  }

  final contacts = await FlutterContacts.getContacts(withProperties: true);
  if (contacts.isEmpty || !context.mounted) return;

  final popped = await redirect(
    context,
    MultiContactPickerPage(contacts: contacts),
  );
  if (popped is! List<Contact> || popped.isEmpty) return;
  final contactsMap = PhoneContacts.toMapList(popped);

  if (!context.mounted) return;

  final total = contactsMap.length;
  final progress = ValueNotifier<int>(0);
  final lang = LangProvider.section('pages.contact.import');

  // Non-dismissible progress dialog — user cannot interact during import.
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
            builder: (context2, current, child) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: total > 0 ? current / total : 0,
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
            ),
          ),
        ),
      ),
    ),
  );

  try {
    // Process in parallel batches: each batch inserts in one DB transaction
    // and encodes all QR PNGs concurrently via compute() isolates.
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
