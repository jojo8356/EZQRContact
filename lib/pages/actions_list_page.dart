import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/pages/qr_generator_simple.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/import_contact.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Home page of the app, presenting the five primary user actions
/// (generate simple QR / vCard, scan, import image, import contact)
/// as a vertical list of large buttons.
class OptionsListPage extends StatelessWidget {
  /// Creates the home page.
  const OptionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      if (await shouldShowGuide() && context.mounted) {
        // Await the dialog so the guide-shown flag is only persisted if
        // the popup actually appears (otherwise rapid navigation marks
        // it as seen and suppresses it forever for fast users).
        await showGuidePopup(context);
        await markGuideShown();
        debugPrint('Guide affiché et marqué comme montré.');
      }
    });
    final lang = LangProvider.getMap('menu');
    final buttons = [
      {
        'label': lang['simple'],
        'icon': Icons.qr_code_2,
        'action': () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const GenerateSimpleQRCode(),
          ),
        ),
      },
      {
        'label': lang['vcard'],
        'icon': Icons.contact_page,
        'action': () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const GenerateVCardQRCode(),
          ),
        ),
      },
      {
        'label': lang['scanner'],
        'icon': Icons.qr_code_scanner,
        'action': () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const QRScannerPage()),
        ),
      },
      {
        'label': lang['import'],
        'icon': Icons.upload_file,
        'action': () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const QrFromImagePage(),
          ),
        ),
      },
      {
        'label': lang['import_contact'],
        'icon': Icons.person_add,
        'action': () async {
          await importContacts(context);
        },
      },
    ];

    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: const AppBarCustom('Actions QR'),
      body: Center(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          itemCount: buttons.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final btn = buttons[index];
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: currentColors['button-color'],
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: Icon(btn['icon'] as IconData?, color: Colors.white),
              label: Text(
                btn['label'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () => (btn['action'] as void Function())(),
            );
          },
        ),
      ),
      bottomNavigationBar: const Navbar(currentRoute: '/options'),
    );
  }
}
