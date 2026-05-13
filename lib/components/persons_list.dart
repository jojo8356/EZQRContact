import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Scrollable list rendering imported phone contacts as cards. Falls back
/// to a centered "empty" message (translated) when [persons] is empty.
class PersonsList extends StatelessWidget {
  /// Creates the list with the given [persons] payload and theme flag.
  const PersonsList({
    required this.persons,
    required this.isDarkMode,
    super.key,
  });

  /// Each entry must contain a `data` key holding `{ name, email, ... }`.
  final List<Map<String, dynamic>> persons;

  /// True when the app is in dark mode (controls text/background colors).
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.section('pages.contact');
    if (persons.isEmpty) {
      return Center(
        child: Text(
          lang['empty'] as String,
          style: TextStyle(
            color: currentColors['text'],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: persons.length,
      itemBuilder: (context, index) {
        final person = persons[index]['data'] as Map<String, dynamic>;

        return Card(
          color: currentColors['surface'],
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              (person['name'] as String?) ?? lang['name_unknown'] as String,
              style: TextStyle(color: currentColors['text']),
            ),
            subtitle: Text(
              (person['email'] as String?) ?? lang['email_uknown'] as String,
              style: TextStyle(
                color: currentColors['text-muted'],
              ),
            ),
          ),
        );
      },
    );
  }
}
