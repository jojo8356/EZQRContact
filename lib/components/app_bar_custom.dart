import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Themed [AppBar] that auto-rebuilds on dark-mode changes via [darkProv].
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a custom app bar showing [title], or [titleWidget] if set.
  const AppBarCustom(this.title, {this.titleWidget, super.key});

  /// Title text displayed in the app bar.
  final String title;

  /// Optional custom title widget (e.g. the EZQR wordmark).
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: darkProv,
      builder: (context, _) {
        final c = currentColors;
        return AppBar(
          backgroundColor: c['bg'],
          foregroundColor: c['text'],
          elevation: 0,
          scrolledUnderElevation: 0,
          title: titleWidget ??
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c['text'],
                ),
              ),
          iconTheme: IconThemeData(color: c['text']),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(AppTokens.hairline),
            child: Container(height: AppTokens.hairline, color: c['border']),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
        kToolbarHeight + AppTokens.hairline,
      );
}
