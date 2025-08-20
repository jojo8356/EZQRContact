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
  final Map<String, TextEditingController> controllers = {
    "nom": TextEditingController(),
    "prenom": TextEditingController(),
    "nom2": TextEditingController(),
    "prefixe": TextEditingController(),
    "suffixe": TextEditingController(),
    "org": TextEditingController(),
    "job": TextEditingController(),
    "photo": TextEditingController(),
    "telWork": TextEditingController(),
    "telHome": TextEditingController(),
    "adrWork": TextEditingController(),
    "adrHome": TextEditingController(),
    "email": TextEditingController(),
  };

  Widget input(f) {
    return TextField(
      controller: f["controller"] as TextEditingController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: f["label"] as String,
      ),
    );
  }

  String _generateVCard() {
    final now = DateTime.now().toUtc();
    final rev =
        '${now.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

    return '''
BEGIN:VCARD
VERSION:4.0
N:${controllers["nom"]!.text};${controllers["prenom"]!.text};${controllers["nom2"]!.text};${controllers["prefixe"]!.text};${controllers["suffixe"]!.text}
FN:${controllers["prefixe"]!.text} ${controllers["prenom"]!.text} ${controllers["nom"]!.text} ${controllers["suffixe"]!.text}
ORG:${controllers["org"]!.text}
TITLE:${controllers["job"]!.text}
${controllers["photo"]!.text.isNotEmpty ? 'PHOTO;MEDIATYPE=image/jpeg:${controllers["photo"]!.text}' : ''}
${controllers["telWork"]!.text.isNotEmpty ? 'TEL;TYPE=work,voice;VALUE=uri:tel:${controllers["telWork"]!.text}' : ''}
${controllers["telHome"]!.text.isNotEmpty ? 'TEL;TYPE=home,voice;VALUE=uri:tel:${controllers["telHome"]!.text}' : ''}
${controllers["adrWork"]!.text.isNotEmpty ? 'ADR;TYPE=WORK;LABEL="${controllers["adrWork"]!.text}":${controllers["adrWork"]!.text}' : ''}
${controllers["adrHome"]!.text.isNotEmpty ? 'ADR;TYPE=HOME;LABEL="${controllers["adrHome"]!.text}":${controllers["adrHome"]!.text}' : ''}
EMAIL:${controllers["email"]!.text}
REV:$rev
END:VCARD
''';
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      {"label": "Nom", "controller": controllers["nom"]},
      {"label": "Prénom", "controller": controllers["prenom"]},
      {"label": "Nom2", "controller": controllers["nom2"]},
      {"label": "Préfixe", "controller": controllers["prefixe"]},
      {"label": "Suffixe", "controller": controllers["suffixe"]},
      {"label": "Organisation", "controller": controllers["org"]},
      {"label": "Job/Titre", "controller": controllers["job"]},
      {"label": "Photo URL", "controller": controllers["photo"]},
      {"label": "Téléphone travail", "controller": controllers["telWork"]},
      {"label": "Téléphone maison", "controller": controllers["telHome"]},
      {"label": "Adresse travail", "controller": controllers["adrWork"]},
      {"label": "Adresse maison", "controller": controllers["adrHome"]},
      {"label": "Email", "controller": controllers["email"]},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur VCard QR Code'),
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
                final vcard = _generateVCard();

                // Crée la map à insérer dans SQLite
                final Map<String, dynamic> vcardData = {
                  'nom': controllers["nom"]?.text,
                  'prenom': controllers["prenom"]?.text,
                  'nom2': controllers["nom2"]?.text,
                  'prefixe': controllers["prefixe"]?.text,
                  'suffixe': controllers["suffixe"]?.text,
                  'org': controllers["org"]?.text,
                  'job': controllers["job"]?.text,
                  'photo': controllers["photo"]?.text,
                  'tel_work': controllers["telWork"]?.text,
                  'tel_home': controllers["telHome"]?.text,
                  'adr_work': controllers["adrWork"]?.text,
                  'adr_home': controllers["adrHome"]?.text,
                  'email': controllers["email"]?.text,
                  'rev': DateTime.now().toUtc().toIso8601String(),
                  'path': null,
                };
                int id = createVCard(vcardData) as int;
                await saveQrCode(vcard, id);

                if (!mounted) return;

                redirect(context, QRResultPage(data: vcard));
              },
              child: const Text('GÉNÉRER QR CODE VCard'),
            ),
          ],
        ),
      ),
    );
  }
}
