import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
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
  bool _scanned = false;

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
                builder: (context) => SafeArea(
                  child: AiBarcodeScanner(
                    borderColor: currentColors['text'],
                    overlayColor: currentColors['bg'],
                    hideGalleryButton: true,
                    hideSheetDragHandler: true,
                    hideSheetTitle: true,
                    appBarBuilder: (context, controller) => AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      foregroundColor:
                          currentColors['text'], // 🔹 couleur des icônes
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.cameraswitch_rounded),
                          onPressed: controller.switchCamera,
                        ),
                        IconButton(
                          icon: controller.torchEnabled
                              ? const Icon(Icons.flashlight_off_rounded)
                              : const Icon(Icons.flashlight_on_rounded),
                          onPressed: controller.toggleTorch,
                        ),
                      ],
                    ),
                    onDetect: (BarcodeCapture capture) async {
                      if (_scanned) return;
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
