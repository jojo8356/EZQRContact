import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';
import '../components/qr_save.dart';

class GenerateVCardQRCode extends StatefulWidget {
  const GenerateVCardQRCode({super.key});

  @override
  GenerateVCardQRCodeState createState() => GenerateVCardQRCodeState();
}

class GenerateVCardQRCodeState extends State<GenerateVCardQRCode> {
  final List<String> fieldKeys = [
    "nom",
    "prenom",
    "nom2",
    "prefixe",
    "suffixe",
    "org",
    "job",
    "photo",
    "tel_work",
    "tel_home",
    "adr_work",
    "adr_home",
    "email",
  ];

  late final Map<String, TextEditingController> controllers = {
    for (var key in fieldKeys) key: TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final lang = LangProvider.get('pages')['QR']['generator'];

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;

        return Scaffold(
          backgroundColor: currentColors['bg'], // fond noir
          appBar: AppBarCustom(lang['vcard']),
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
                  label: lang['submit button'],
                  onPressed: () async {
                    final data = extractValues(controllers);
                    final vcard = VCard.fromMap(data);
                    int id = await createVCard(data);
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

Widget input(f) {
  final isDark = darkProv.isDarkMode;
  return TextField(
    controller: f["controller"],
    style: TextStyle(color: currentColors['text']),
    decoration: InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: currentColors['text']),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: currentColors['text']),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: currentColors['text'], width: 2),
      ),
      labelText: f["label"] as String,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    ),
  );
}
