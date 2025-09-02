import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:qr_code_app/providers/lang.dart';

class MultiContactPickerPage extends StatefulWidget {
  final List<Contact> contacts;

  const MultiContactPickerPage({super.key, required this.contacts});

  @override
  State<MultiContactPickerPage> createState() => _MultiContactPickerPageState();
}

class _MultiContactPickerPageState extends State<MultiContactPickerPage> {
  final Map<int, bool> selectedMap = {};
  final lang = LangProvider.get('pages')['contact']['import'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lang['title'])),
      body: ListView.builder(
        itemCount: widget.contacts.length,
        itemBuilder: (context, index) {
          final c = widget.contacts[index];
          selectedMap[index] = selectedMap[index] ?? false;
          return CheckboxListTile(
            value: selectedMap[index],
            title: Text(c.displayName),
            secondary: c.photo != null
                ? CircleAvatar(backgroundImage: MemoryImage(c.photo!))
                : const CircleAvatar(child: Icon(Icons.person)),
            onChanged: (val) =>
                setState(() => selectedMap[index] = val ?? false),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, <Contact>[]),
              child: Text(lang['buttons']['cancel']),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final chosen = widget.contacts
                    .asMap()
                    .entries
                    .where((e) => selectedMap[e.key] == true)
                    .map((e) => e.value)
                    .toList();
                Navigator.pop(context, chosen);
              },
              child: Text(lang['buttons']['validate']),
            ),
          ],
        ),
      ),
    );
  }
}
