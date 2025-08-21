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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner")),
      body: MobileScanner(
        fit: BoxFit.cover,
        onDetect: (capture) async {
          if (_navigated) return;

          final qrCode = capture.barcodes.firstWhere(
            (b) => b.format == BarcodeFormat.qrCode,
            orElse: () =>
                Barcode(rawValue: null, format: BarcodeFormat.unknown),
          );

          if (qrCode.format == BarcodeFormat.qrCode) {
            final String qrValue = qrCode.rawValue ?? "QR invalide";
            _navigated = true;
            redirect(context, TextResultPage(data: qrValue));
            _navigated = false;
          }
        },
      ),
    );
  }
}
