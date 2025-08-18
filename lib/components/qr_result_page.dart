import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRResultPage extends StatelessWidget {
  final String data;
  const QRResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "label": "Menu",
        "color": Colors.red,
        "icon": Icons.home,
        "onPressed": () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      },
      {
        "label": "Générer",
        "color": Colors.blue,
        "icon": Icons.refresh,
        "onPressed": () {
          Navigator.pop(context, true);
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Votre QR Code')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions.map((action) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton.icon(
                        onPressed: action["onPressed"] as void Function(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action["color"] as Color,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: Icon(
                          action["icon"] as IconData,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          action["label"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
