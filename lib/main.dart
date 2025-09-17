import 'package:flutter/material.dart';
import 'package:qr_code_app/bottom_nav.dart';
import 'package:qr_code_app/providers/lang.dart';

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
      home: const MainNavigation(),
    );
  }
}
