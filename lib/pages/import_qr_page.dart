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
import 'package:qr_code_app/tools/qr_decode.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:qr_code_app/tools/vcard.dart';

/// Page letting the user pick an image from the gallery and decode any
/// embedded QR code. Detected vCards open [ScanResultPage]; other payloads
/// are stored as SimpleQR rows.
class QrFromImagePage extends StatefulWidget {
  /// Creates the page.
  ///
  /// [pickImage], [analyzeImage], [saveVCard] and [saveSimpleQr] are test
  /// seams. Production leaves them null.
  const new({
    this.pickImage,
    this.analyzeImage,
    this.saveVCard,
    this.saveSimpleQr,
    super.key,
  });

  /// Test override for `ImagePicker.pickImage`.
  final Future<XFile?> Function()? pickImage;

  /// Test override for barcode analysis. Null/empty means no QR in the image.
  final Future<String?> Function(String path)? analyzeImage;

  /// Test override for [createVCard].
  final Future<int> Function(Map<String, dynamic> data)? saveVCard;

  /// Test override for [createSimpleQR].
  final Future<int> Function(String text)? saveSimpleQr;

  @override
  State<QrFromImagePage> createState() => _QrFromImagePageState();
}

class _QrFromImagePageState extends State<QrFromImagePage> {
  bool _processing = false;

  Future<void> pickAndDecodeImage() async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      XFile? file;
      final pick = widget.pickImage;
      if (pick != null) {
        file = await pick();
      } else {
        file = await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      if (file == null) return;

      String? rawValue;
      final analyze = widget.analyzeImage;
      if (analyze != null) {
        rawValue = await analyze(file.path);
      } else {
        rawValue = await decodeQrFromFile(file.path);
      }

      if (!mounted) return;

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
        final saveV = widget.saveVCard;
        late final int id;
        if (saveV != null) {
          id = await saveV(map);
        } else {
          id = await createVCard(map);
        }

        if (!mounted) return;
        final lang = LangProvider.section('pages.QR.scanner');
        showToast(
          context: context,
          title: lang['saved'] as String,
          color: Colors.white,
        );
        await redirect(context, ScanResultPage(vcardData: map, savedId: id));
      } else {
        final saveS = widget.saveSimpleQr;
        if (saveS != null) {
          await saveS(rawValue);
        } else {
          await createSimpleQR(rawValue);
        }
        if (!mounted) return;
        final lang = LangProvider.section('pages.QR.scanner');
        showToast(
          context: context,
          title: lang['flashed'] as String,
          color: Colors.white,
        );
        if (!context.mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
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
                  key: const Key('import-pick-image'),
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
