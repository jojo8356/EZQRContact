import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/pages/settings.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import '../pages/historique_page.dart'; // Crée cette page simple

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OptionsListPage(),
    const Collection(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = DarkModeProvider();
    final lang = LangProvider.get('bottom menu');
    return AnimatedBuilder(
      animation: darkMode,
      builder: (context, _) {
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: darkMode.isDarkMode
                ? Colors.white
                : const Color.fromARGB(255, 161, 107, 255),
            selectedItemColor: const Color.fromARGB(255, 102, 53, 187),
            currentIndex: _selectedIndex,
            backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: lang['home'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.style),
                label: lang['home'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: lang['history'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: lang['history'],
              ),
            ],
          ),
        );
      },
    );
  }
}
