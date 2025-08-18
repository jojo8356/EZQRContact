import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/db/db.dart';
import 'package:qr_code_app/tools.dart';
import 'package:qr_code_app/vars.dart';

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
      appBar: AppBar(title: const Text("Scanner QR Code")),
      body: MobileScanner(
        fit: BoxFit.cover,
        onDetect: (capture) async {
          if (_navigated) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.format == BarcodeFormat.qrCode) {
              final String qrValue = barcode.rawValue ?? "QR invalide";
              _navigated = true;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRResultPage(data: qrValue),
                ),
              );

              _navigated = false;
              break;
            }
          }
        },
      ),
    );
  }
}

class QRResultPage extends StatelessWidget {
  final String data;
  const QRResultPage({super.key, required this.data});

  Future<void> _saveQr() async {
    int id;
    if (isVCard(data)) {
      id = await createVCard(parseVCard(data));
    } else {
      id = await createSimpleQR(data);
    }
    await saveQrCode(data, id);
  }

  @override
  Widget build(BuildContext context) {
    final actions = getActionQRCode(context);

    return FutureBuilder(
      future: _saveQr(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Votre QR Code')),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: isVCard(data)
                      ? VCardView(
                          controllers: mapToControllers(parseVCard(data)),
                        )
                      : Text(
                          data,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: actions.map((action) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton.icon(
                            onPressed: action["onPressed"] as void Function(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: action["color"] as Color,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            icon: Icon(
                              action["icon"] as IconData,
                              color: Colors.white,
                              size: 25,
                            ),
                            label: Text(
                              action["label"] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
