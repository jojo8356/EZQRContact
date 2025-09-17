import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'components/qr_result_page.dart';
import 'tools/db/db.dart';

class GenerateSimpleQRCode extends StatefulWidget {
  const GenerateSimpleQRCode({super.key});

  @override
  GenerateSimpleQRCodeState createState() => GenerateSimpleQRCodeState();
}

class GenerateSimpleQRCodeState extends State<GenerateSimpleQRCode> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final generator = LangProvider.get('pages')['QR']['generator'];
    final lang = generator['simple'];
    final darkMode = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        final isDark = darkMode.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBarCustom(lang['title']),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: lang['input'],
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSubmitButton(
                  isDark: isDark,
                  label: generator['submit button'],
                  onPressed: () async {
                    if (controller.text.isEmpty) return;
                    final qrData = controller.text;
                    final int id = await createSimpleQR(qrData);
                    final path = await saveQrCode(qrData, id);
                    if (!context.mounted) return;
                    await redirect(context, QRResultPage(path: path));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
