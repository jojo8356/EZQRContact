import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/db/db.dart';
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
      child: const Text('Fermer'),
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
            ElevatedButton.icon(
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
                        8, // bottom (exemple pour plus d’espace)
                      ),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      title: const Text('Infos VCard'),
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
                      title: const Text('Texte QR'),
                      content: Text(data['text'] ?? ""),
                      actions: [closeButton(context)],
                    ),
                  );
                }
              },
              icon: const Icon(Icons.remove_red_eye),
              label: const Text('Voir'),
            ),

            // Voir QR bouton
            ElevatedButton.icon(
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
              icon: const Icon(Icons.qr_code),
              label: const Text('QR'),
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
