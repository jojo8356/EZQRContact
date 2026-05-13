import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/pages/scan_result_page.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Page letting the user pick an image from the gallery and decode any
/// embedded QR code. Detected vCards open [ScanResultPage]; other payloads
/// are stored as SimpleQR rows.
class QrFromImagePage extends StatefulWidget {
  /// Creates the page.
  const QrFromImagePage({super.key});

  @override
  State<QrFromImagePage> createState() => _QrFromImagePageState();
}

class _QrFromImagePageState extends State<QrFromImagePage> {
  bool _processing = false;

  Future<void> pickAndDecodeImage() async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final controller = MobileScannerController();
      BarcodeCapture? capture;
      try {
        capture = await controller.analyzeImage(file.path);
      } finally {
        await controller.dispose();
      }

      if (!mounted) return;

      final rawValue = capture?.barcodes.firstOrNull?.rawValue;
      if (rawValue == null || rawValue.isEmpty) {
        final lang = LangProvider.section('pages.QR.import');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang['no qr found'] as String)),
        );
        return;
      }

      if (VCard.isVCard(rawValue)) {
        final vcard = VCard.parse(rawValue);
        final map = await vcard.toMap()
          ..['captured_at'] = DateTime.now().toIso8601String();
        final id = await createVCard(map);

        if (!mounted) return;
        await redirect(context, ScanResultPage(vcardData: map, savedId: id));
      } else {
        await createSimpleQR(rawValue);
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      debugPrint('Erreur lors du scan image: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();
    final lang = LangProvider.section('pages.QR.import');

    return Scaffold(
      backgroundColor: currentColors['bg'],
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
