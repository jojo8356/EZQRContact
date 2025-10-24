import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/tools/tools.dart';

class VCardView extends StatelessWidget {
  final Map<String, TextEditingController> controllers;

  const VCardView({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);
    final darkMode = DarkModeProvider();

    final bgColor = darkMode.isDarkMode ? Colors.white12 : Colors.white;
    final textColor = darkMode.isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = darkMode.isDarkMode
        ? Colors.white70
        : Colors.black54;

    return Card(
      color: bgColor, // fond adaptatif
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Photo + nom
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    controllers["photo"]?.text ?? "",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 80, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // centre horizontalement
                    mainAxisAlignment:
                        MainAxisAlignment.center, // centre verticalement
                    children: [
                      Text(
                        "${controllers["prenom"]?.text ?? ""} ${controllers["nom"]?.text ?? ""}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (controllers["job"]?.text.isNotEmpty ?? false)
                        Text(
                          controllers["job"]!.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                        ),
                      if (controllers["org"]?.text.isNotEmpty ?? false)
                        Text(
                          controllers["org"]!.text,
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
                final controller = f["controller"] as TextEditingController?;
                final value = controller?.text ?? "";
                if (value.isEmpty || f["label"] == "Photo URL") {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          f["label"] as String? ?? "",
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
