import 'package:flutter/material.dart';
import 'package:qr_code_app/components/coach_tour.dart';
import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Floating bottom navigation bar shown on the four root pages.
/// Highlights the entry matching [currentRoute].
class Navbar extends StatelessWidget {
  /// Creates the bottom navigation bar.
  const new({required this.currentRoute, super.key});

  /// Name of the route currently displayed (e.g. `/options`, `/history`).
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final darkProv = DarkModeProvider();

    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LangProvider.notifier,
          builder: (context, value, _) {
            final lang = LangProvider.getMap('bottom menu');
            final c = currentColors;
            final items = [
              (
                Icons.home_outlined,
                Icons.home_rounded,
                lang['home'] as String? ?? 'Home',
                '/options',
              ),
              (
                Icons.style_outlined,
                Icons.style_rounded,
                lang['collection'] as String? ?? 'Collection',
                '/collection',
              ),
              (
                Icons.history_outlined,
                Icons.history_rounded,
                lang['history'] as String? ?? 'History',
                '/history',
              ),
              (
                Icons.settings_outlined,
                Icons.settings_rounded,
                lang['settings'] as String? ?? 'Settings',
                '/settings',
              ),
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s4,
                0,
                AppTokens.s4,
                AppTokens.s3,
              ),
              child: SafeArea(
                top: false,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c['surface'],
                    borderRadius: BorderRadius.circular(AppTokens.rLg),
                    border: Border.all(color: c['border']!),
                    boxShadow: paperShadow(c['shadow']!, float: true),
                  ),
                  child: SizedBox(
                    height: AppTokens.navH,
                    child: Row(
                      children: [
                        for (final item in items)
                          Expanded(
                            child: _NavItem(
                              key: _coachKeyForRoute(
                                item.$4,
                                currentRoute,
                              ),
                              icon: item.$1,
                              selectedIcon: item.$2,
                              label: item.$3,
                              selected: currentRoute == item.$4,
                              onTap: () {
                                if (item.$4 == currentRoute) return;
                                Navigator.of(context).pushReplacementNamed(
                                  item.$4,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Key? _coachKeyForRoute(String route, String currentRoute) {
  // The GlobalKey can live on only one Navbar. During a tab switch both
  // the outgoing and incoming bars are on screen; attaching the key on
  // every page made Collection vanish (3 items) then reappear (4).
  if (currentRoute != '/options') {
    return null;
  }
  if (route == '/collection') {
    return coachCollectionKey;
  }
  return null;
}

class _NavItem extends StatelessWidget {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    var color = c['text-muted']!;
    var labelColor = c['text-muted']!;
    var itemIcon = icon;
    Color? tickColor = Colors.transparent;
    if (selected) {
      color = c['button-color']!;
      labelColor = c['text']!;
      itemIcon = selectedIcon;
      tickColor = c['button-color'];
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.rMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            itemIcon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 2),
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              color: tickColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
