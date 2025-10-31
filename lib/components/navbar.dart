import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

class Navbar extends StatelessWidget {
  final String currentRoute;

  const Navbar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LangProvider.notifier,
          builder: (context, value, _) {
            final lang = LangProvider.get('bottom menu');

            // 🔹 On applique un Theme local pour forcer la couleur
            return Theme(
              data: Theme.of(context).copyWith(
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: currentColors['bg'],
                  unselectedItemColor: DarkModeProvider().isDarkMode
                      ? const Color.fromARGB(255, 102, 53, 187)
                      : Color.fromARGB(255, 161, 107, 255),
                  selectedItemColor: !DarkModeProvider().isDarkMode
                      ? const Color.fromARGB(255, 102, 53, 187)
                      : Color.fromARGB(255, 161, 107, 255),
                  type: BottomNavigationBarType.fixed,
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _getIndexFromRoute(currentRoute),
                onTap: (index) {
                  final route = _getRouteFromIndex(index);
                  if (route != currentRoute) {
                    Navigator.pushReplacementNamed(context, route);
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: lang['home'],
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.style),
                    label: lang['collection'],
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history),
                    label: lang['history'],
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: lang['settings'],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case '/options':
        return 0;
      case '/collection':
        return 1;
      case '/history':
        return 2;
      case '/settings':
        return 3;
      default:
        return 0;
    }
  }

  String _getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/options';
      case 1:
        return '/collection';
      case 2:
        return '/history';
      case 3:
        return '/settings';
      default:
        return '/options';
    }
  }
}
