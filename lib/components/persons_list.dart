import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang.dart';

class PersonsList extends StatelessWidget {
  final List<Map<String, dynamic>> persons;
  final bool isDarkMode;

  const PersonsList({
    super.key,
    required this.persons,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.get("pages")['contact'];
    if (persons.isEmpty) {
      return Center(
        child: Text(
          lang['empty'],
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: persons.length,
      itemBuilder: (context, index) {
        final person = persons[index]["data"];

        return Card(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              person["name"] ?? lang['name_unknown'],
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              person["email"] ?? lang["email_uknown"],
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        );
      },
    );
  }
}
