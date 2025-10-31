import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
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
      await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Erreur lors du scan image: $e');
    }
    if (!mounted) return;
    await redirect(context, const Collection());
  }

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();
    final lang = LangProvider.get('pages')['QR']['import'];

    return Scaffold(
      backgroundColor: Colors.black, // fond noir
      appBar: AppBarCustom(lang['title']),
      body: Center(
        child: AnimatedSubmitButton(
          isDark: darkProv.isDarkMode,
          onPressed: pickAndDecodeImage,
          label: lang['pick'],
        ),
      ),
    );
  }
}
