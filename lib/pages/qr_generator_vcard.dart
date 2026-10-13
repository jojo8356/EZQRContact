import 'dart:convert';
import 'dart:typed_data';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/components/section_label.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/models/qr_layout.dart';
import 'package:qr_code_app/models/visual_config.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/photo.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Form page that builds a vCard QR code from manually-entered fields.
class GenerateVCardQRCode extends StatefulWidget {
  /// Creates the page.
  const new({super.key});

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
  QrLayout _layout = QrLayout.minimal;
  String? _photoDataUri;

  Future<void> _pickColor(BuildContext ctx, String label) async {
    var draft = _primaryColor;
    final picked = await showDialog<Color>(
      context: ctx,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: currentColors['popup-background'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.rXl),
              ),
              title: Text(
                label,
                style: TextStyle(color: currentColors['popup-text']),
              ),
              content: SingleChildScrollView(
                child: ColorPicker(
                  color: draft,
                  onColorChanged: (c) {
                    setDialogState(() => draft = c);
                  },
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                  actionButtons: const ColorPickerActionButtons(
                    dialogActionButtons: false,
                    okButton: false,
                    closeButton: false,
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: const EdgeInsets.fromLTRB(
                AppTokens.s4,
                0,
                AppTokens.s4,
                AppTokens.s4,
              ),
              actions: [
                _DialogDisc(
                  icon: LucideIcons.x,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
                _DialogDisc(
                  icon: LucideIcons.check,
                  onTap: () => Navigator.of(dialogContext).pop(draft),
                ),
              ],
            );
          },
        );
      },
    );
    if (!mounted) return;
    if (picked == null) return;
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

  Future<void> _pickPhoto() async {
    final source = await _askPhotoSource();
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final uri = await compressPhotoForVCard(bytes);
    if (!mounted) return;
    if (uri == null) {
      final lang = LangProvider.section('pages.QR.generator');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (lang['photo_too_large'] as String?) ??
                'Photo non compressible',
          ),
        ),
      );
      return;
    }
    setState(() => _photoDataUri = uri);
  }

  Future<void> _submit() async {
    final lang = LangProvider.section('pages.QR.generator');
    final data = extractValues(controllers);
    data['photo'] = _photoDataUri ?? '';
    String? logoBase64;
    if (_logoBytes != null) {
      logoBase64 = base64Encode(_logoBytes!);
    }
    data['visual_config'] = VisualConfig(
      primaryColor: _primaryColor,
      logoBase64: logoBase64,
      layout: _layout,
    ).toJson();
    final vcard = VCard.fromMap(data);
    final id = await createVCard(data);
    await saveQrCode(
      vcard.toVCard(),
      id,
      color: _primaryColor,
      logoBytes: _logoBytes,
    );
    await PhoneContacts.add(data);
    if (!mounted) {
      return;
    }
    showToast(
      context: context,
      title: lang['card_ready'] as String,
      color: Colors.white,
      icon: Icons.share,
    );
    await redirect(context, const Collection());
  }

  Future<ImageSource?> _askPhotoSource() async {
    final lang = LangProvider.section('pages.QR.generator');
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(
              (lang['photo_camera'] as String?) ?? 'Caméra',
            ),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(
              (lang['photo_gallery'] as String?) ?? 'Galerie',
            ),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final lang = LangProvider.section('pages.QR.generator');

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;
        var hairline = Colors.black26;
        if (isDark) {
          hairline = Colors.white38;
        }

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
                SectionLabel(
                  (lang['appearance'] as String?) ?? 'Apparence',
                ),
                const SizedBox(height: 12),
                // Photo row
                Row(
                  children: [
                    Text(
                      (lang['photo'] as String?) ?? 'Photo',
                      style: TextStyle(color: currentColors['text']),
                    ),
                    const Spacer(),
                    if (_photoDataUri != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          base64Decode(
                            _photoDataUri!.split(',').last,
                          ),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _photoDataUri = null),
                        child: Icon(
                          Icons.close,
                          color: currentColors['text'],
                          size: 20,
                        ),
                      ),
                    ] else
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: hairline),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: currentColors['text'],
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Color picker row
                Row(
                  children: [
                    Text(
                      (lang['primary_color'] as String?) ??
                          'Couleur primaire',
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
                          border: Border.all(color: hairline),
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
                              border: Border.all(color: hairline),
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
                const SizedBox(height: 12),
                SectionLabel(
                  (lang['layout'] as String?) ?? 'Layout',
                ),
                const SizedBox(height: 8),
                // Layout picker
                SegmentedButton<QrLayout>(
                  selected: {_layout},
                  onSelectionChanged: (sel) =>
                      setState(() => _layout = sel.first),
                  segments: [
                    ButtonSegment(
                      value: QrLayout.minimal,
                      icon: const Icon(Icons.view_headline),
                      label: Text(
                        (lang['layout_minimal'] as String?) ??
                            'Minimal',
                      ),
                    ),
                    ButtonSegment(
                      value: QrLayout.classic,
                      icon: const Icon(Icons.credit_card),
                      label: Text(
                        (lang['layout_classic'] as String?) ??
                            'Classic',
                      ),
                    ),
                    ButtonSegment(
                      value: QrLayout.modern,
                      icon: const Icon(Icons.style),
                      label: Text(
                        (lang['layout_modern'] as String?) ??
                            'Modern',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedSubmitButton(
                  isDark: isDark,
                  label: lang['submit button'] as String,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Filled circular dialog action (10% black) for OK / close.
class _DialogDisc extends StatelessWidget {
  const new({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.appBarScrim,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: AppTokens.tap,
          height: AppTokens.tap,
          child: Icon(icon, color: currentColors['text']),
        ),
      ),
    );
  }
}

/// Builds a single themed [TextField] from the field record [f] (a
/// `{label, controller}` pair produced by `tools.buildFields`).
Widget input(Map<String, dynamic> f) {
  final textColor = currentColors['text'] ?? Colors.white;
  return TextField(
    controller: f['controller'] as TextEditingController?,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      labelText: f['label'] as String,
    ),
  );
}
