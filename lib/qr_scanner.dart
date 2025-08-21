import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/text_result_page.dart';
import 'package:qr_code_app/tools.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _navigated = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose(); // libère la caméra
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner")),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
        onDetect: (capture) async {
          if (_navigated) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.format == BarcodeFormat.qrCode) {
              final String qrValue = barcode.rawValue ?? "QR invalide";

              _navigated = true;
              _controller.stop(); // stoppe la caméra

              // Navigue vers la page résultat
              redirect(context, TextResultPage(data: qrValue));

              // Remet _navigated à false si jamais on revient sur ce scanner
              _navigated = false;
              break;
            }
          }
        },
      ),
    );
  }
}
