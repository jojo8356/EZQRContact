import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/pages/qr_generator_simple.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/import_contact.dart';

class OptionsListPage extends StatelessWidget {
  const OptionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get('menu');
    final buttons = [
      {
        "label": lang['simple'],
        "icon": Icons.qr_code_2,
        "action": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenerateSimpleQRCode()),
        ),
      },
      {
        "label": lang['vcard'],
        "icon": Icons.contact_page,
        "action": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenerateVCardQRCode()),
        ),
      },
      {
        "label": lang['scanner'],
        "icon": Icons.qr_code_scanner,
        "action": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerPage()),
        ),
      },
      {
        "label": lang['import'],
        "icon": Icons.upload_file,
        "action": () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QrFromImagePage()),
        ),
      },
      {
        "label": lang['import_contact'],
        "icon": Icons.person_add,
        "action": () async {
          await importContacts(context);
        },
      },
    ];

    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: AppBarCustom("Actions QR"),
      body: Center(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          itemCount: buttons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final btn = buttons[index];
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: currentColors['button-color'],
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: Icon(btn["icon"] as IconData?, color: Colors.white),
              label: Text(
                btn["label"] as String,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () => (btn["action"] as void Function())(),
            );
          },
        ),
      ),
      bottomNavigationBar: const Navbar(currentRoute: '/options'),
    );
  }
}
