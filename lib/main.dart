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
import 'package:qr_code_app/theme/app_theme.dart';
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
  const new({super.key});

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
          var initialRoute = '/onboarding';
          if (done) {
            initialRoute = '/options';
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: LangProvider.getString('title'),
            theme: buildAppTheme(
              colors: currentColors,
              isDark: darkProv.isDarkMode,
            ),
            initialRoute: initialRoute,
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }
}

/// Named routes. Tab pages skip the push animation so two Navbars never
/// overlap (that used to drop Collection from 4 items to 3).
Route<void>? _onGenerateRoute(RouteSettings settings) {
  final name = settings.name;
  late final Widget page;
  var isTab = false;
  if (name == '/onboarding') {
    page = const OnboardingPage();
  } else if (name == '/options') {
    page = const OptionsListPage();
    isTab = true;
  } else if (name == '/collection') {
    page = const Collection();
    isTab = true;
  } else if (name == '/history') {
    page = const HistoryPage();
    isTab = true;
  } else if (name == '/settings') {
    page = const SettingsPage();
    isTab = true;
  } else {
    return null;
  }
  if (isTab) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => page,
    );
  }
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => page,
  );
}
