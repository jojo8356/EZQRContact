import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/components/result_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/tools.dart';

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get('pages')['QR']['scanner'];
    return Scaffold(
      appBar: AppBar(title: Text(lang['title'])),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
        onDetect: (capture) async {
          if (_navigated) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.format == BarcodeFormat.qrCode) {
              final String qrValue = barcode.rawValue ?? lang['invalid qr'];
              _navigated = true;
              _controller.stop();
              await redirect(context, TextResultPage(data: qrValue));
              _navigated = false;
              break;
            }
          }
        },
      ),
    );
  }
}
