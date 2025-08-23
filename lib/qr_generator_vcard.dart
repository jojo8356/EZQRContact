import 'package:flutter/material.dart';
import 'package:qr_code_app/tools.dart';
import 'components/qr_result_page.dart';
import 'db/db.dart';
import 'components/qr_save.dart';

class GenerateVCardQRCode extends StatefulWidget {
  const GenerateVCardQRCode({super.key});

  @override
  GenerateVCardQRCodeState createState() => GenerateVCardQRCodeState();
}

class GenerateVCardQRCodeState extends State<GenerateVCardQRCode> {
  // Text controllers pour chaque champ
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
    return TextField(
      controller: f["controller"],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: f["label"] as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VCard QR Code Generator'),
        centerTitle: true,
      ),
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
            ElevatedButton(
              onPressed: () async {
                final data = extractValues(controllers);
                final vcard = generateVCardFromData(data);
                int id = createVCard(data) as int;
                await saveQrCode(vcard, id);
                verifContact();
                addContact(
                  data.entries.where((entry) => entry.key != 'id')
                      as Map<String, String>,
                );

                if (!context.mounted) return;

                await redirect(context, QRResultPage(data: vcard));
              },
              child: const Text('GÉNÉRER QR CODE VCard'),
            ),
          ],
        ),
      ),
    );
  }
}
