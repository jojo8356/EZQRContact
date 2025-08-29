import 'package:flutter/material.dart';
import 'package:flutter_toast_plus/flutter_toast_plus.dart';
import 'package:qr_code_app/providers/toast.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ToastProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚡️ Initialisation du ToastService une seule fois ici
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ToastWrapper(child: HomePage()),
    );
  }
}

class ToastWrapper extends StatelessWidget {
  final Widget child;
  const ToastWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ToastService.init(context); // context stable
    return child;
  }
}
