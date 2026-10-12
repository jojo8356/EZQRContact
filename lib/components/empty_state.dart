import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Centered empty-state: icon well, title, body, optional CTA.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const new({
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Well icon.
  final IconData icon;

  /// Short title.
  final String title;

  /// Optional supporting line.
  final String? body;

  /// Optional CTA label.
  final String? actionLabel;

  /// Optional CTA handler.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c['surface-raised'],
                  borderRadius: BorderRadius.circular(AppTokens.rLg),
                ),
                child: Icon(icon, size: 32, color: c['text-muted']),
              ),
              const SizedBox(height: AppTokens.s5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (body != null) ...[
                const SizedBox(height: AppTokens.s2),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppTokens.s5),
                AppButton.secondary(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
