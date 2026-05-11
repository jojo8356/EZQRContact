import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/database.dart';
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

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final lang = LangProvider.section('pages.QR.generator');

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;

        return Scaffold(
          backgroundColor: currentColors['bg'], // fond noir
          appBar: AppBarCustom(lang['vcard'] as String),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...fields.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: input(f),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSubmitButton(
                  isDark: isDark,
                  label: lang['submit button'] as String,
                  onPressed: () async {
                    final data = extractValues(controllers);
                    final vcard = VCard.fromMap(data);
                    final id = await createVCard(data);
                    await saveQrCode(vcard.toVCard(), id);
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
      fillColor: isDark ? Colors.grey[900] : Colors.white,
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
