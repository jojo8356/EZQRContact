import 'package:flutter/material.dart';

class VCardView extends StatelessWidget {
  final Map<String, TextEditingController> controllers;

  const VCardView({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final fields = [
      {"label": "Nom", "controller": controllers["nom"]},
      {"label": "Prénom", "controller": controllers["prenom"]},
      {"label": "Nom2", "controller": controllers["nom2"]},
      {"label": "Préfixe", "controller": controllers["prefixe"]},
      {"label": "Suffixe", "controller": controllers["suffixe"]},
      {"label": "Organisation", "controller": controllers["org"]},
      {"label": "Job/Titre", "controller": controllers["job"]},
      {"label": "Photo URL", "controller": controllers["photo"]},
      {"label": "Téléphone travail", "controller": controllers["tel_work"]},
      {"label": "Téléphone maison", "controller": controllers["tel_home"]},
      {"label": "Adresse travail", "controller": controllers["adr_work"]},
      {"label": "Adresse maison", "controller": controllers["adr_home"]},
      {"label": "Email", "controller": controllers["email"]},
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(0),
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
                final field = f as Map<String, dynamic>; // cast
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
