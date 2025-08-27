import 'package:flutter/material.dart';
import 'package:qr_code_app/tools/tools.dart';

class VCardView extends StatelessWidget {
  final Map<String, TextEditingController> controllers;

  const VCardView({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final fields = buildFields(controllers);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Photo + nom
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    controllers["photo"]?.text ?? "",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controllers["prenom"]?.text ?? ""} ${controllers["nom"]?.text ?? ""}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (controllers["job"]?.text.isNotEmpty ?? false)
                        Text(
                          controllers["job"]!.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      if (controllers["org"]?.text.isNotEmpty ?? false)
                        Text(
                          controllers["org"]!.text,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            // Infos détaillées
            Column(
              children: fields.map((f) {
                final field = f; // cast
                final controller =
                    field["controller"] as TextEditingController?;
                final value = controller?.text ?? "";
                if (value.isEmpty || field["label"] == "Photo URL") {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          field["label"] as String? ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Text(value)),
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
