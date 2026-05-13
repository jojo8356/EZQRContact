import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/pages/historique_page.dart';
import 'package:qr_code_app/pages/onboarding_page.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/onboarding_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/perf.dart';

/// Application entry point: ensures Flutter bindings, loads the active
/// language pack, then launches [MyApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Perf.start('startup.total');
  await Future.wait([
    Perf.measure('startup.lang_init', LangProvider.init),
    Perf.measure('startup.vcard_init', VCardSettingsProvider.init),
  ]);
  Perf.end('startup.total');
  runApp(const MyApp());
  // Open the SQLite connection in the background so the collection page
  // never pays the cold-open penalty (~400 ms) on first load.
  unawaited(QRDatabase().warmUp());
}

/// Root widget. Sets up the [MaterialApp] with named routes and conditionally
/// shows onboarding on first launch.
class MyApp extends StatefulWidget {
  /// Creates the root widget.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _onboardingDone;

  @override
  void initState() {
    super.initState();
    _onboardingDone = OnboardingProvider.isDone();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) => FutureBuilder<bool>(
        future: _onboardingDone,
        builder: (context, snap) {
          // Default true to avoid flicker while future resolves.
          final done = snap.data ?? true;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: LangProvider.getString('title'),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              scaffoldBackgroundColor: currentColors['bg'],
              dialogTheme: DialogThemeData(
                backgroundColor: currentColors['popup-background'],
              ),
            ),
            initialRoute: done ? '/options' : '/onboarding',
            routes: {
              '/onboarding': (_) => const OnboardingPage(),
              '/options': (_) => const OptionsListPage(),
              '/collection': (_) => const Collection(),
              '/history': (_) => const HistoryPage(),
              '/settings': (_) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
