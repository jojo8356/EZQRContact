import 'package:flutter/material.dart';
import 'package:qr_code_app/choices/add_choice.dart';
import 'package:qr_code_app/choices/photo_choice.dart';
import 'package:qr_code_app/import_contact.dart';
import 'package:qr_code_app/tools/tools.dart';
import '../qr_choice_page.dart';

class MenuActions extends StatelessWidget {
  final VoidCallback refreshData;
  final bool isDarkMode;

  const MenuActions({
    super.key,
    required this.refreshData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      {
        "color": Colors.blue,
        "icon": Icons.add,
        "onPressed": () async {
          await redirect(
            context,
            QRChoicePage(buttons: getAddChoiceButtons(context)),
          );
          refreshData();
        },
      },
      {
        "color": Colors.red,
        "icon": Icons.camera_alt,
        "onPressed": () async {
          await redirect(
            context,
            QRChoicePage(buttons: getPhotoChoiceButtons(context)),
          );
          refreshData();
        },
      },
      {
        "color": Colors.orange,
        "icon": Icons.file_upload,
        "onPressed": () async {
          await importContacts(context);
          refreshData();
        },
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildCircleButton(
            isDarkMode: isDarkMode,
            color: buttons[i]["color"] as Color,
            icon: buttons[i]["icon"] as IconData,
            onPressed: buttons[i]["onPressed"] as VoidCallback,
          ),
          if (i != buttons.length - 1) const SizedBox(width: 50),
        ],
      ],
    );
  }

  Widget _buildCircleButton({
    required bool isDarkMode,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
        backgroundColor: color,
      ),
      child: Icon(icon, size: 30, color: Colors.white),
    );
  }
}
