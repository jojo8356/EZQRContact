import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/vars.dart';

class QRResultPage extends StatelessWidget {
  final String path;
  const QRResultPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final actions = getActionQRCode(context);
    final result = LangProvider.get('pages');
    final darkMode = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        final isDark = darkMode.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white, // 👈 fond
          appBar: AppBarCustom(result['QR']['result']['title']),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(18),
                    child: Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
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
                              style: TextStyle(
                                color: Colors.white, // 👈 texte toujours blanc
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
      },
    );
  }
}
