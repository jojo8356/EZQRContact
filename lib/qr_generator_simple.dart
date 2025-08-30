import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'components/qr_result_page.dart';
import 'tools/db/db.dart';

class GenerateSimpleQRCode extends StatefulWidget {
  const GenerateSimpleQRCode({super.key});

  @override
  GenerateSimpleQRCodeState createState() => GenerateSimpleQRCodeState();
}

class GenerateSimpleQRCodeState extends State<GenerateSimpleQRCode> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple QR Code Generator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your Text',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;
                final qrData = controller.text;
                final int id = await createSimpleQR(qrData);
                await saveQrCode(qrData, id);
                if (!context.mounted) return;

                await redirect(context, QRResultPage(data: qrData));
              },
              child: const Text('GENERATE QR CODE'),
            ),
          ],
        ),
      ),
    );
  }
}
