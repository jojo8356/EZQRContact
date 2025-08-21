import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/db/db.dart';
import 'package:qr_code_app/save_file_page.dart';
import 'package:qr_code_app/tools.dart';

class OptionsQR extends StatelessWidget {
  final bool isVCard;
  final Map<String, dynamic> data;
  final bool expanded;
  final Future<void> Function() onRefresh;

  const OptionsQR({
    super.key,
    required this.isVCard,
    required this.data,
    required this.expanded,
    required this.onRefresh,
  });

  Widget closeButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Close'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Container(),
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Voir bouton
            ElevatedButton(
              onPressed: () {
                if (isVCard) {
                  final controllers = mapToControllers(data);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      actionsPadding: const EdgeInsets.fromLTRB(
                        0, // left
                        0, // top
                        20, // right
                        8, // bottom
                      ),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      title: const Text('VCard infos'),
                      content: SingleChildScrollView(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: VCardView(controllers: controllers),
                        ),
                      ),
                      actions: [closeButton(context)],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      title: const Text(
                        'QR Code Texte',
                        textAlign: TextAlign.center,
                      ),
                      content: Expanded(
                        child: Text(
                          data['text'] ?? "",
                          textAlign: TextAlign
                              .center, // centre horizontalement le texte
                        ),
                      ),
                      actions: [closeButton(context)],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.remove_red_eye),
            ),

            // Voir QR bouton
            ElevatedButton(
              onPressed: () {
                if (data['path'] != null && data['path'].isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: InteractiveViewer(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white, // fond blanc
                              borderRadius: BorderRadius.circular(
                                40,
                              ), // arrondi 50px
                            ),
                            child: Image.file(
                              File(data['path']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.qr_code),
            ),

            // Supprimer bouton
            ElevatedButton(
              onPressed: () async {
                await deleteQR(isVCard, data['id']);
                await onRefresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () async {
                String? path = '';
                if (isVCard) {
                  path = await QRDatabase().getPathFromVCard(data['id']);
                } else {
                  path = await QRDatabase().getPathFromSimpleQR(data['id']);
                }
                if (!context.mounted) return;
                await showSaveDialog(context, path!);
                await onRefresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.download, color: Colors.white),
            ),
          ],
        ),
      ),
      crossFadeState: expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
