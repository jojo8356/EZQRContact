import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/pages/historique_page.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang.dart';

/// Application entry point: ensures Flutter bindings, loads the active
/// language pack, then launches [MyApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LangProvider.init();
  runApp(const MyApp());
}

/// Root widget. Sets up the [MaterialApp] with the four named routes.
class MyApp extends StatelessWidget {
  /// Creates the root widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: LangProvider.getString('title'),
      initialRoute: '/options',
      routes: {
        '/options': (_) => const OptionsListPage(),
        '/collection': (_) => const Collection(),
        '/history': (_) => const HistoryPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
