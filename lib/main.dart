import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/pages/historique_page.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/providers/vcard_settings_provider.dart';
import 'package:qr_code_app/tools/perf.dart';

/// Application entry point: ensures Flutter bindings, loads the active
/// language pack, then launches [MyApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Perf.start('startup.total');
  await Future.wait([
    Perf.measure('startup.lang_init',   LangProvider.init),
    Perf.measure('startup.vcard_init',  VCardSettingsProvider.init),
  ]);
  Perf.end('startup.total');
  runApp(const MyApp());
}

/// Root widget. Sets up the [MaterialApp] with the four named routes.
/// Listens to [darkProv] so that [ThemeData.scaffoldBackgroundColor] and
/// dialog background stay in sync during the dark-mode transition — prevents
/// the white flash between route transitions.
class MyApp extends StatelessWidget {
  /// Creates the root widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: LangProvider.getString('title'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: currentColors['bg'],
          dialogTheme: DialogThemeData(
            backgroundColor: currentColors['popup-background'],
          ),
        ),
        initialRoute: '/options',
        routes: {
          '/options': (_) => const OptionsListPage(),
          '/collection': (_) => const Collection(),
          '/history': (_) => const HistoryPage(),
          '/settings': (_) => const SettingsPage(),
        },
      ),
    );
  }
}
