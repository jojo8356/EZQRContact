import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/pages/historique_page.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/pages/settings.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LangProvider.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: LangProvider.get('title'),
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
