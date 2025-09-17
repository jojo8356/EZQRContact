import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'components/qr_result_page.dart';
import 'components/qr_save.dart';

class GenerateVCardQRCode extends StatefulWidget {
  const GenerateVCardQRCode({super.key});

  @override
  GenerateVCardQRCodeState createState() => GenerateVCardQRCodeState();
}

class GenerateVCardQRCodeState extends State<GenerateVCardQRCode> {
  final darkProv = DarkModeProvider();
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

  Widget input(f) {
    final isDark = darkProv.isDarkMode;
    return TextField(
      controller: f["controller"],
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 2,
          ),
        ),
        labelText: f["label"] as String,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final lang = LangProvider.get('pages')['QR']['generator'];

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white, // fond noir
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
                    final vcard = generateVCardFromData(data);
                    int id = await createVCard(data);
                    final path = await saveQrCode(vcard, id);
                    await verifContact();
                    await addContactToPhone(data);
                    if (!context.mounted) return;
                    await redirect(context, QRResultPage(path: path));
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
