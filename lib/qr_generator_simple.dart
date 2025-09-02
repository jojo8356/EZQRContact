import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/lang.dart';
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
    final lang = LangProvider.get('pages')['QR']['generator']['simple'];
    return Scaffold(
      appBar: AppBar(title: Text(lang['title']), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: lang['input'],
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
              child: Text(
                LangProvider.get('pages')['QR']['generator']['submit button'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
