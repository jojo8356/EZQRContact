import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/db/db.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false; // ✅ blocage

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get('pages')['QR']['scanner'];
    return Scaffold(
      appBar: AppBarCustom(lang['title']),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AiBarcodeScanner(
                  hideGalleryButton: true,
                  onDetect: (BarcodeCapture capture) async {
                    if (_scanned) return; // ⚠️ ignore si déjà scanné
                    _scanned = true;

                    final text = capture.barcodes.first.rawValue;
                    final vcard = VCard.parse(text ?? '');

                    await PhoneContacts.verifyPermission();
                    await PhoneContacts.add(await vcard.toMap());
                    await createVCard(await vcard.toMap());

                    if (context.mounted) {
                      await redirect(context, const Collection());
                    }
                  },
                ),
              ),
            );
            _scanned = false; // reset si on revient sur la page
          },
          child: const Text("Scan Barcode"),
        ),
      ),
    );
  }
}
