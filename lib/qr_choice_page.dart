import 'package:flutter/material.dart';
import 'package:qr_code_app/tools/tools.dart';

class QRChoicePage extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;

  const QRChoicePage({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Easy QR Contact App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons
              .map(
                (btn) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final args = btn["args"] ?? [];
                      await redirect(
                        context,
                        Function.apply(btn["builder"], args),
                      );
                    },
                    icon: Icon(btn["icon"], color: Colors.white, size: 25),
                    label: Text(
                      btn["label"],
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn["color"],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
