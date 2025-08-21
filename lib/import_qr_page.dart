import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  String? _fileName;
  String? _qrText = "Aucun fichier décodé";

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      print(path);
      if (path != null && path.isNotEmpty) {
        try {
          String? qrText = await QrCodeToolsPlugin.decodeFrom(path);
          setState(() {
            _fileName = path;
            _qrText = qrText ?? "Aucun QR code trouvé";
          });
          print('Texte du QR code : $qrText');
        } catch (e) {
          print('Erreur : $e');
          setState(() {
            _qrText = 'Erreur lors du décodage';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Importer un fichier")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload, size: 25),
              label: const Text("Importer", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _qrText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
