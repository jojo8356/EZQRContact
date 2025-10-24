import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/darkmode.dart';

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
    final darkMode = DarkModeProvider();

    final bgColor = darkMode.isDarkMode ? Colors.black : Colors.white;
    final textColor = darkMode.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(lang['title'], style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: widget.contacts.length,
        itemBuilder: (context, index) {
          final c = widget.contacts[index];
          selectedMap[index] = selectedMap[index] ?? false;
          return Theme(
            data: Theme.of(context).copyWith(unselectedWidgetColor: textColor),
            child: CheckboxListTile(
              value: selectedMap[index],
              title: Text(c.displayName, style: TextStyle(color: textColor)),
              secondary: Stack(
                clipBehavior: Clip.none,
                children: [
                  c.photo != null
                      ? CircleAvatar(backgroundImage: MemoryImage(c.photo!))
                      : CircleAvatar(
                          backgroundColor: darkMode.isDarkMode
                              ? Colors.grey[900]
                              : Colors.grey[300],
                          child: Icon(Icons.person, color: textColor),
                        ),
                ],
              ),

              onChanged: (val) =>
                  setState(() => selectedMap[index] = val ?? false),
              activeColor: Colors.blue,
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: bgColor,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMode.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[300],
              ),
              onPressed: () => Navigator.pop(context, <Contact>[]),
              child: Text(
                lang['buttons']['cancel'],
                style: TextStyle(color: textColor),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMode.isDarkMode
                    ? Colors.blueGrey
                    : Colors.blue,
              ),
              onPressed: () {
                final chosen = widget.contacts
                    .asMap()
                    .entries
                    .where((e) => selectedMap[e.key] == true)
                    .map((e) => e.value)
                    .toList();
                Navigator.pop(context, chosen);
              },
              child: Text(
                lang['buttons']['validate'],
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
