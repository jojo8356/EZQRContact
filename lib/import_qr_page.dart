import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_qrcode_analysis/flutter_qrcode_analysis.dart';
import 'package:qr_code_app/components/result_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/tools.dart';

class QrFromImagePage extends StatefulWidget {
  const QrFromImagePage({super.key});

  @override
  State<QrFromImagePage> createState() => _QrFromImagePageState();
}

class _QrFromImagePageState extends State<QrFromImagePage> {
  String? qrResult;

  Future<void> pickAndDecodeImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final data = await FlutterQrcodeAnalysis.analysisImage(pickedFile.path);

        if (!mounted) return;
        await redirect(
          context,
          TextResultPage(data: data ?? LangProvider.get('QR Not Found')),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors du scan image: $e');
      if (!mounted) return;
      await redirect(context, TextResultPage(data: 'Erreur: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get('pages')['QR']['import'];
    return Scaffold(
      appBar: AppBar(title: Text(lang['title'])),
      body: Center(
        child: ElevatedButton(
          onPressed: pickAndDecodeImage,
          child: Text(lang['pick']),
        ),
      ),
    );
  }
}
