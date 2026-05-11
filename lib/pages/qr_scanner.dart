import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Page launching the camera-based QR scanner. On detection, parses the
/// payload as a vCard or stores it as a SimpleQR row, then navigates back.
class QRScannerPage extends StatefulWidget {
  /// Creates the scanner page.
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.QR.scanner');
    return Scaffold(
      appBar: AppBarCustom(lang['title'] as String),
      backgroundColor: currentColors['bg'],
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => SafeArea(
                  child: AiBarcodeScanner(
                    borderColor: currentColors['text'] ?? Colors.white,
                    overlayColor: currentColors['bg'] ?? Colors.black,
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
                    onDetect: (capture) async {
                      if (_scanned) return;
                      _scanned = true;

                      final text = capture.barcodes.first.rawValue;

                      if (VCard.isVCard(text ?? '')) {
                        final vcard = VCard.parse(text ?? '');
                        await PhoneContacts.verifyPermission();
                        await PhoneContacts.add(await vcard.toMap());
                        await createVCard(await vcard.toMap());
                      } else {
                        await createSimpleQR(text ?? '');
                      }

                      if (context.mounted) {
                        await redirect(context, const Collection());
                      }
                    },
                  ),
                ),
              ),
            );
            _scanned = false;
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              currentColors['button-color'],
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
          child: Text(lang['scan'] as String),
        ),
      ),
    );
  }
}
