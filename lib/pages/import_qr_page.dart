import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Page letting the user pick an image from the gallery and scan it for
/// embedded QR codes via the platform image picker.
class QrFromImagePage extends StatefulWidget {
  /// Creates the page.
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
    } on Exception catch (e) {
      debugPrint('Erreur lors du scan image: $e');
    }
    if (!mounted) return;
    await redirect(context, const Collection());
  }

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();
    final lang = LangProvider.section('pages.QR.import');

    return Scaffold(
      backgroundColor: currentColors['bg'], // fond noir
      appBar: AppBarCustom(lang['title'] as String),
      body: Center(
        child: AnimatedSubmitButton(
          isDark: darkProv.isDarkMode,
          onPressed: pickAndDecodeImage,
          label: lang['pick'] as String,
        ),
      ),
    );
  }
}
