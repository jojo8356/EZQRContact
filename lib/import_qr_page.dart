import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_qrcode_analysis/flutter_qrcode_analysis.dart';
import 'package:qr_code_app/components/result_page.dart';
import 'package:qr_code_app/providers/lang.dart';

class QrFromImagePage extends StatefulWidget {
  const QrFromImagePage({super.key});

  @override
  State<QrFromImagePage> createState() => _QrFromImagePageState();
}

class _QrFromImagePageState extends State<QrFromImagePage> {
  String? qrResult;

  Future<void> pickAndDecodeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? data = await FlutterQrcodeAnalysis.analysisImage(pickedFile.path);
      setState(() {
        qrResult = data ?? LangProvider.get('QR Not Found');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get('pages')['QR']['import'];
    return Scaffold(
      appBar: AppBar(title: Text(lang['title'])),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickAndDecodeImage,
              child: Text(lang['pick']),
            ),
            const SizedBox(height: 20),
            TextResultPage(data: qrResult ?? lang['default here']),
          ],
        ),
      ),
    );
  }
}
