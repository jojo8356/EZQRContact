import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'home_page.dart';
import 'historique_page.dart'; // Crée cette page simple

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const HomePage(), const HistoryPage()];

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
                ? Colors.white70
                : Colors.black54,
            currentIndex: _selectedIndex,
            backgroundColor: darkMode.isDarkMode ? Colors.black : Colors.white,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: lang['home'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: lang['history'],
              ),
            ],
          ),
        );
      },
    );
  }
}
