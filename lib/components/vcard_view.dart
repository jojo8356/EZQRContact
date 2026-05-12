import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Read-only contact card rendered from a set of vCard form controllers,
/// shown inside the "view" dialog and the post-scan preview.
class VCardView extends StatelessWidget {
  /// Creates the view from the given form controllers.
  const VCardView({required this.controllers, super.key});

  /// Form controllers keyed by vCard field name (`nom`, `prenom`, ...).
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final bgColor = currentColors['surface']!;
    final textColor = currentColors['text']!;
    final secondaryTextColor = currentColors['text-muted']!;

    return Card(
      color: bgColor, // fond adaptatif
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Photo + nom
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    controllers['photo']?.text ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 80, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // centre verticalement
                    children: [
                      Text(
                        '${controllers['prenom']?.text ?? ''} '
                        '${controllers['nom']?.text ?? ''}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (controllers['job']?.text.isNotEmpty ?? false)
                        Text(
                          controllers['job']!.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                        ),
                      if (controllers['org']?.text.isNotEmpty ?? false)
                        Text(
                          controllers['org']!.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              height: 30,
              color: secondaryTextColor, // divider adaptatif
            ),
            // Infos détaillées
            Column(
              children: fields.map((f) {
                final controller = f['controller'] as TextEditingController?;
                final value = controller?.text ?? '';
                if (value.isEmpty || f['label'] == 'Photo URL') {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          f['label'] as String? ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(value, style: TextStyle(color: textColor)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
