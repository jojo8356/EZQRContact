import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Small-caps section heading used above grouped content.
class SectionLabel extends StatelessWidget {
  /// Creates a section label.
  const SectionLabel(this.text, {super.key});

  /// Label copy. Rendered in uppercase.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTokens.s1,
        bottom: AppTokens.s2,
        top: AppTokens.s2,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: currentColors['navy'],
        ),
      ),
    );
  }
}
