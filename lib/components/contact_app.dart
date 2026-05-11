import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';

/// Full-screen multi-select list of device contacts. Pops back the
/// `List<Contact>` chosen by the user (or empty when cancelled).
class MultiContactPickerPage extends StatefulWidget {
  /// Creates the picker for the given [contacts].
  const MultiContactPickerPage({required this.contacts, super.key});

  /// All device contacts the user can pick from.
  final List<Contact> contacts;

  @override
  State<MultiContactPickerPage> createState() => _MultiContactPickerPageState();
}

class _MultiContactPickerPageState extends State<MultiContactPickerPage> {
  final Map<int, bool> selectedMap = {};

  @override
  Widget build(BuildContext context) {
    // Resolved per build so language switches and late-loaded translations
    // refresh the UI; field-initializer would freeze it at construction.
    final lang = LangProvider.section('pages.contact.import');
    final darkProv = DarkModeProvider();

    final bgColor = darkProv.isDarkMode ? Colors.black : Colors.white;
    final textColor = darkProv.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          lang['title'] as String,
          style: TextStyle(color: textColor),
        ),
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
                  if (c.photo != null)
                    CircleAvatar(backgroundImage: MemoryImage(c.photo!))
                  else
                    CircleAvatar(
                      backgroundColor: darkProv.isDarkMode
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
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkProv.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[300],
              ),
              onPressed: () => Navigator.pop(context, <Contact>[]),
              child: Text(
                (lang['buttons'] as Map<String, dynamic>)['cancel'] as String,
                style: TextStyle(color: textColor),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkProv.isDarkMode
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
                (lang['buttons'] as Map<String, dynamic>)['validate'] as String,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
