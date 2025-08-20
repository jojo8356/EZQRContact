import 'package:flutter/material.dart';
import 'qr_generator_simple.dart';
import 'qr_generator_vcard.dart';

class QRChoicePage extends StatelessWidget {
  const QRChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste des boutons à afficher
    final List<Map<String, dynamic>> buttons = [
      {
        "label": "Simple QR",
        "icon": Icons.qr_code,
        "color": Colors.blue,
        "builder": () => const GenerateSimpleQRCode(),
      },
      {
        "label": "VCard QR",
        "icon": Icons.perm_identity,
        "color": Colors.green,
        "builder": () => const GenerateVCardQRCode(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Easy QR Contact App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons
              .map(
                (btn) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => btn["builder"]()),
                      );
                    },
                    icon: Icon(btn["icon"], color: Colors.white, size: 25),
                    label: Text(
                      btn["label"],
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn["color"],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
