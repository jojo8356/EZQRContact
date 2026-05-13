import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/modals/qr_view.dart';
import 'package:qr_code_app/models/visual_config.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/contacts.dart';

/// Post-scan detail screen showing the parsed VCard fields. Provides a
/// button to optionally add the contact to the device address book.
class ScanResultPage extends StatefulWidget {
  /// Creates the page from [vcardData] (legacy map) and the DB row [savedId].
  const ScanResultPage({
    required this.vcardData,
    required this.savedId,
    super.key,
  });

  /// VCard fields as returned by [VCard.toMap()].
  final Map<String, dynamic> vcardData;

  /// DB row id created on save.
  final int savedId;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _contactsAdded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lang = LangProvider.section('pages.QR.scanner');
      showToast(
        context: context,
        title: lang['saved'] as String,
        color: Colors.white,
      );
      if (VCardSettingsProvider.reciprocalExchange) {
        unawaited(_showReciprocalPrompt());
      }
    });
  }

  Future<void> _showReciprocalPrompt() async {
    if (!mounted) return;
    final lang = LangProvider.section('pages.QR.scanner');
    final data = widget.vcardData;
    final prenom = (data['prenom'] as String?) ?? '';
    final nom = (data['nom'] as String?) ?? '';
    final name = '$prenom $nom'.trim().isEmpty ? '?' : '$prenom $nom'.trim();

    final promptTemplate = lang['reciprocal_prompt'] as String;
    final promptText = promptTemplate.replaceFirst('%s', name);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: currentColors['surface'],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              promptText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: currentColors['text'],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      lang['reciprocal_later'] as String,
                      style: TextStyle(color: currentColors['text']),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentColors['button-color'],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _showMyQr();
                    },
                    child: Text(lang['reciprocal_share'] as String),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyQr() async {
    if (!mounted) return;
    final qrPath = await QRDatabase().getMyCardQrPath();
    if (!mounted) return;
    if (qrPath == null) {
      final lang = LangProvider.section('pages.QR.scanner');
      showToast(
        context: context,
        title: lang['no_my_card'] as String,
        color: Colors.orange,
        icon: Icons.warning_amber,
      );
      return;
    }
    await showImageDialog(context, qrPath);
  }

  Future<void> _addToPhoneContacts() async {
    final granted = await PhoneContacts.verifyPermission();
    if (!granted || !mounted) return;

    final data = widget.vcardData;
    final nom = (data['nom'] as String?) ?? '';
    final prenom = (data['prenom'] as String?) ?? '';

    final hasName = nom.isNotEmpty || prenom.isNotEmpty;
    final exists = hasName &&
        await PhoneContacts.exists(
          nom: nom.isEmpty ? null : nom,
          prenom: prenom.isEmpty ? null : prenom,
        );

    if (!mounted) return;

    if (exists) {
      final contactLang = LangProvider.section('pages.contact.options');
      final btnLang = contactLang['buttons'] as Map<String, dynamic>;
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: currentColors['surface'],
          title: Text(
            contactLang['title'] as String,
            style: TextStyle(color: currentColors['text']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'replace'),
              child: Text(btnLang['replace'] as String),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'clone'),
              child: Text(btnLang['clone'] as String),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'fill'),
              child: Text(btnLang['empty input'] as String),
            ),
          ],
        ),
      );

      if (!mounted || result == null) return;
      if (result == 'clone') {
        await PhoneContacts.add(data);
      } else {
        await PhoneContacts.update(data);
      }
    } else {
      await PhoneContacts.add(data);
    }

    if (!mounted) return;
    setState(() => _contactsAdded = true);
    final lang = LangProvider.section('pages.QR.scanner');
    showToast(
      context: context,
      title: lang['contacts_added'] as String,
      color: Colors.white,
      icon: Icons.contacts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.vcardData;
    final lang = LangProvider.section('pages.QR.scanner');
    final vcardLang = LangProvider.getMap('VCard Input');

    final visualConfig =
        VisualConfig.fromNullableJson(data['visual_config'] as String?);
    final accentColor = visualConfig.primaryColor;

    String s(String key) => (data[key] as String?) ?? '';

    final capturedAt = data['captured_at'] as String?;
    String? captureLabel;
    if (capturedAt != null && capturedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(capturedAt).toLocal();
        final formatted =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
        final template = lang['captured_on'] as String;
        captureLabel = template.replaceFirst('%s', formatted);
      } on Exception catch (_) {}
    }

    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: AppBarCustom(lang['result_title'] as String),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: currentColors['surface'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // colored accent header from visual config
                  Container(
                    height: 8,
                    color: accentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(s('photo'), visualConfig, accentColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${s("prenom")} ${s("nom")}'.trim(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: currentColors['text'],
                                    ),
                                  ),
                                  if (s('job').isNotEmpty)
                                    Text(
                                      s('job'),
                                      style: TextStyle(
                                        color: currentColors['text-muted'],
                                      ),
                                    ),
                                  if (s('org').isNotEmpty)
                                    Text(
                                      s('org'),
                                      style: TextStyle(
                                        color: currentColors['text-muted'],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        for (final key in [
                          'tel_work',
                          'tel_home',
                          'email',
                          'adr_work',
                          'adr_home',
                        ])
                          if (s(key).isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      vcardLang[key] as String? ?? key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: currentColors['text'],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s(key),
                                      style: TextStyle(
                                        color: currentColors['text'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        if (captureLabel != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            captureLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: currentColors['text-muted'],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_contactsAdded)
              ElevatedButton.icon(
                icon: const Icon(Icons.contacts),
                label: Text(lang['add_to_contacts'] as String),
                onPressed: _addToPhoneContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentColors['button-color'],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            if (_contactsAdded)
              Row(
                children: [
                  const Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    lang['contacts_added'] as String,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.list),
              label: Text(lang['view_collection'] as String),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const Collection()),
                (route) => false,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: currentColors['text'],
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navbar(currentRoute: '/collection'),
    );
  }

  Widget _buildAvatar(
    String photoStr,
    VisualConfig visualConfig,
    Color accentColor,
  ) {
    Uint8List? photoBytes;
    if (photoStr.startsWith('data:image')) {
      try {
        photoBytes = base64Decode(photoStr.split(',').last);
      } on Exception catch (_) {}
    }

    if (photoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          photoBytes,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }

    // Show logo from visual config when no profile photo
    final logo = visualConfig.logoBase64;
    if (logo != null && logo.isNotEmpty) {
      try {
        final logoBytes = base64Decode(logo);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            logoBytes,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
        );
      } on Exception catch (_) {}
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: accentColor,
      ),
    );
  }
}
