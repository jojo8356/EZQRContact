import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_qrcode_analysis/flutter_qrcode_analysis.dart';
import 'package:qr_code_app/components/text_result_page.dart';

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
        qrResult = data ?? "QR non trouvé";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR → Text")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickAndDecodeImage,
              child: const Text("Choisir une image"),
            ),
            const SizedBox(height: 20),
            TextResultPage(data: qrResult ?? "Résultat ici"),
          ],
        ),
      ),
    );
  }
}
