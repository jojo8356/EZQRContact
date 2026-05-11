import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Form page that turns a single text input into a SimpleQR row + image.
class GenerateSimpleQRCode extends StatefulWidget {
  /// Creates the page.
  const GenerateSimpleQRCode({super.key});

  @override
  GenerateSimpleQRCodeState createState() => GenerateSimpleQRCodeState();
}

/// State for [GenerateSimpleQRCode]: holds the single text controller.
class GenerateSimpleQRCodeState extends State<GenerateSimpleQRCode> {
  /// Controller bound to the single text field of the form.
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final generator = LangProvider.section('pages.QR.generator');
    final lang = generator['simple'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final isDark = darkProv.isDarkMode;

        return Scaffold(
          backgroundColor: currentColors['bg'],
          appBar: AppBarCustom(lang['title'] as String),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: TextStyle(color: currentColors['text']),
                  decoration: InputDecoration(
                    labelText: lang['input'] as String?,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: currentColors['text'] ?? Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: currentColors['text'] ?? Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSubmitButton(
                  isDark: isDark,
                  label: generator['submit button'] as String,
                  onPressed: () async {
                    if (controller.text.isEmpty) return;
                    final qrData = controller.text;
                    final id = await createSimpleQR(qrData);
                    await saveQrCode(qrData, id);
                    if (!context.mounted) return;
                    await redirect(context, const Collection());
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
