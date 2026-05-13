import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
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
    });
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
        // 'replace' and 'fill' both call update (fill merges empty fields)
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

    String s(String key) => (data[key] as String?) ?? '';

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPhoto(s('photo')),
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
                          padding: const EdgeInsets.symmetric(vertical: 4),
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
                  ],
                ),
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

  Widget _buildPhoto(String photoStr) {
    Uint8List? bytes;
    if (photoStr.startsWith('data:image')) {
      try {
        bytes = base64Decode(photoStr.split(',').last);
      } on Exception catch (_) {}
    }

    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(bytes, width: 64, height: 64, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: currentColors['surface'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: currentColors['text-muted'],
      ),
    );
  }
}
