import 'dart:convert';
import 'dart:typed_data';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/models/visual_config.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Form page that builds a vCard QR code from manually-entered fields.
class GenerateVCardQRCode extends StatefulWidget {
  /// Creates the page.
  const GenerateVCardQRCode({super.key});

  @override
  GenerateVCardQRCodeState createState() => GenerateVCardQRCodeState();
}

/// State for [GenerateVCardQRCode]: holds one [TextEditingController] per
/// vCard field and writes the resulting row + image on submit.
class GenerateVCardQRCodeState extends State<GenerateVCardQRCode> {
  /// Names of the vCard fields displayed in the form, in display order.
  final List<String> fieldKeys = [
    'nom',
    'prenom',
    'nom2',
    'prefixe',
    'suffixe',
    'org',
    'job',
    'photo',
    'tel_work',
    'tel_home',
    'adr_work',
    'adr_home',
    'email',
  ];

  /// One [TextEditingController] per [fieldKeys] entry, lazily created.
  late final Map<String, TextEditingController> controllers = {
    for (var key in fieldKeys) key: TextEditingController(),
  };

  Color _primaryColor = Colors.black;
  Uint8List? _logoBytes;

  Future<void> _pickColor(BuildContext ctx, String label) async {
    final picked = await showColorPickerDialog(
      ctx,
      _primaryColor,
      title: Text(label),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
    );
    if (!mounted) return;
    setState(() => _primaryColor = picked);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _logoBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final lang = LangProvider.section('pages.QR.generator');

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;

        return Scaffold(
          backgroundColor: currentColors['bg'],
          appBar: AppBarCustom(lang['vcard'] as String),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...fields.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: input(f),
                  ),
                ),
                const SizedBox(height: 24),
                // — Apparence section ————————————————————————————————
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (lang['appearance'] as String?) ?? 'Apparence',
                    style: TextStyle(
                      color: currentColors['text'],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Color picker row
                Row(
                  children: [
                    Text(
                      (lang['primary_color'] as String?) ?? 'Couleur primaire',
                      style: TextStyle(color: currentColors['text']),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _pickColor(
                        context,
                        (lang['primary_color'] as String?) ??
                            'Couleur primaire',
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          border: Border.all(
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Logo picker row
                Row(
                  children: [
                    Text(
                      (lang['logo'] as String?) ?? 'Logo',
                      style: TextStyle(color: currentColors['text']),
                    ),
                    const Spacer(),
                    if (_logoBytes != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          _logoBytes!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _logoBytes = null),
                        child: Icon(
                          Icons.close,
                          color: currentColors['text'],
                          size: 20,
                        ),
                      ),
                    ] else
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Tooltip(
                          message: (lang['add_logo'] as String?) ??
                              'Ajouter un logo',
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black26,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: currentColors['text'],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedSubmitButton(
                  isDark: isDark,
                  label: lang['submit button'] as String,
                  onPressed: () async {
                    final data = extractValues(controllers);
                    final logoBase64 = _logoBytes != null
                        ? base64Encode(_logoBytes!)
                        : null;
                    data['visual_config'] = VisualConfig(
                      primaryColor: _primaryColor,
                      logoBase64: logoBase64,
                    ).toJson();
                    final vcard = VCard.fromMap(data);
                    final id = await createVCard(data);
                    await saveQrCode(
                      vcard.toVCard(),
                      id,
                      color: _primaryColor,
                      logoBytes: _logoBytes,
                    );
                    await PhoneContacts.verifyPermission();
                    await PhoneContacts.add(data);
                    if (!context.mounted) return;
                    await redirect(context, const Collection());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Builds a single themed [TextField] from the field record [f] (a
/// `{label, controller}` pair produced by `tools.buildFields`).
Widget input(Map<String, dynamic> f) {
  final isDark = darkProv.isDarkMode;
  final textColor = currentColors['text'] ?? Colors.white;
  return TextField(
    controller: f['controller'] as TextEditingController?,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      filled: true,
      fillColor: currentColors['surface'],
      border: OutlineInputBorder(
        borderSide: BorderSide(color: textColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColor, width: 2),
      ),
      labelText: f['label'] as String,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    ),
  );
}
