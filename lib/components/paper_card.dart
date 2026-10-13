import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Surface that reads as a sheet of paper: hairline, rest shadow, warm fill.
class PaperCard extends StatelessWidget {
  /// Creates a paper card.
  const new({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    super.key,
  });

  /// Card body.
  final Widget child;

  /// Inner padding. Defaults to 16.
  final EdgeInsetsGeometry? padding;

  /// Outer margin.
  final EdgeInsetsGeometry? margin;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    final radius = BorderRadius.circular(AppTokens.rLg);

    final body = Padding(
      padding: padding ?? const EdgeInsets.all(AppTokens.s4),
      child: child,
    );

    Widget materialChild = body;
    if (onTap != null) {
      materialChild = InkWell(onTap: onTap, child: body);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c['surface'],
          borderRadius: radius,
          border: Border.all(color: c['border']!),
          boxShadow: paperShadow(c['shadow']!),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: materialChild,
        ),
      ),
    );
  }
}
