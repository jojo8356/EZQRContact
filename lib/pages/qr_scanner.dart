import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Chrome for [AiBarcodeScanner]. Defaults are white icons on a light
/// overlay — unreadable on papier. Copper discs, ivoire glyphs.
ScannerTheme encreScannerTheme() {
  final c = currentColors;
  return ScannerTheme(
    overlayColor: c['bg'],
    reticleColor: c['button-color'],
    controlBackgroundColor: c['button-color'],
    controlForegroundColor: c['on-button'],
    controlActiveBackgroundColor: c['text'],
    controlActiveForegroundColor: c['bg'],
    controlSize: AppTokens.compactWell,
    hintBackgroundColor: c['surface'],
    hintTextStyle: TextStyle(
      color: c['text'],
      fontWeight: FontWeight.w600,
    ),
    surfaceColor: c['surface'],
    onSurfaceColor: c['text'],
  );
}

/// Page launching the camera-based QR scanner. On vCard detection navigates
/// to [ScanResultPage]; other payloads are saved as SimpleQR rows.
class QRScannerPage extends StatefulWidget {
  /// Creates the scanner page.
  const new({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false;

  Future<void> _openScanner() async {
    final overlay = ScannerOverlayConfig(
      borderColor: currentColors['button-color'],
      backgroundColor: currentColors['bg'],
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AiBarcodeScanner(
          formats: const [BarcodeFormat.qrCode],
          galleryButtonType: GalleryButtonType.none,
          enabledActionButtons: const {
            ScannerAction.cameraSwitch,
            ScannerAction.torch,
            ScannerAction.close,
          },
          theme: encreScannerTheme(),
          overlayConfig: overlay,
          onDetect: (capture) async {
            if (_scanned) return;
            _scanned = true;

            await HapticFeedback.mediumImpact();

            final text = capture.barcodes.first.rawValue ?? '';
            await _finishScan(text);
          },
        ),
      ),
    );
    _scanned = false;
  }

  Future<void> _finishScan(String text) async {
    final isVCard = VCard.isVCard(text);
    Map<String, dynamic>? vcardData;
    int? savedId;

    if (isVCard) {
      final vcard = VCard.parse(text);
      final activeEvent = EventProvider().activeEvent;
      final map = await vcard.toMap()
        ..['captured_at'] = DateTime.now().toIso8601String();
      if (activeEvent != null) {
        map['event_id'] = activeEvent.id.toString();
      }
      savedId = await createVCard(map);
      vcardData = map;
    } else {
      await createSimpleQR(text);
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    if (!mounted) return;
    final lang = LangProvider.section('pages.QR.scanner');
    var title = lang['flashed'] as String;
    if (isVCard) {
      title = lang['saved'] as String;
    }
    showToast(
      context: context,
      title: title,
      color: Colors.white,
    );

    if (!isVCard) return;
    if (vcardData == null || savedId == null) return;
    if (!context.mounted) return;
    await redirect(
      context,
      ScanResultPage(vcardData: vcardData, savedId: savedId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.QR.scanner');
    final home = LangProvider.getMap('home');
    final c = currentColors;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarCustom(lang['title'] as String),
      backgroundColor: c['bg'],
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
                    color: c['button-color']!.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.rLg),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 36,
                    color: c['button-color'],
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
                  home['scanner_hint'] as String? ??
                      'Cadrez le QR. Rien n’est envoyé.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: c['text-muted'],
                  ),
                ),
                const SizedBox(height: AppTokens.s6),
                AppButton.primary(
                  label: lang['scan'] as String,
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: _openScanner,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
