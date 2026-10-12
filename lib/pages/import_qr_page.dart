import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/modals/contact_options.dart';
import 'package:qr_code_app/pages/scan_result_page.dart';
import 'package:qr_code_app/providers/event_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Page letting the user pick an image from the gallery and decode any
/// embedded QR code. Detected vCards open [ScanResultPage]; other payloads
/// are stored as SimpleQR rows.
class QrFromImagePage extends StatefulWidget {
  /// Creates the page.
  const new({super.key});

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

      final controller = AiBarcodeScannerController(autoStart: false);
      BarcodeCapture? capture;
      try {
        capture = await controller.analyzeImage(file.path);
      } finally {
        controller.dispose();
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

      final isVCard = VCard.isVCard(rawValue);
      if (isVCard) {
        final vcard = VCard.parse(rawValue);
        final activeEvent = EventProvider().activeEvent;
        final map = await vcard.toMap()
          ..['captured_at'] = DateTime.now().toIso8601String();
        if (activeEvent != null) {
          map['event_id'] = activeEvent.id.toString();
        }
        final id = await createVCard(map);

        if (!mounted) return;
        final lang = LangProvider.section('pages.QR.scanner');
        showToast(
          context: context,
          title: lang['saved'] as String,
          color: Colors.white,
        );
        await redirect(context, ScanResultPage(vcardData: map, savedId: id));
      } else {
        await createSimpleQR(rawValue);
        if (!mounted) return;
        final lang = LangProvider.section('pages.QR.scanner');
        showToast(
          context: context,
          title: lang['flashed'] as String,
          color: Colors.white,
        );
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
    final lang = LangProvider.section('pages.QR.import');
    final home = LangProvider.getMap('home');
    final c = currentColors;
    final theme = Theme.of(context);
    VoidCallback? onPick;
    if (!_processing) {
      onPick = pickAndDecodeImage;
    }

    return Scaffold(
      backgroundColor: c['bg'],
      appBar: AppBarCustom(lang['title'] as String),
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.s5),
        child: Center(
          child: PaperCard(
            padding: const EdgeInsets.all(AppTokens.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: c['navy']!.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.rLg),
                  ),
                  child: Icon(
                    Icons.photo_outlined,
                    size: 36,
                    color: c['navy'],
                  ),
                ),
                const SizedBox(height: AppTokens.s5),
                Text(
                  lang['title'] as String,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTokens.s2),
                Text(
                  home['import_hint'] as String? ??
                      'Choisissez une capture contenant un QR.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: c['text-muted'],
                  ),
                ),
                const SizedBox(height: AppTokens.s6),
                AppButton.primary(
                  label: lang['pick'] as String,
                  icon: Icons.image_outlined,
                  onPressed: onPick,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
