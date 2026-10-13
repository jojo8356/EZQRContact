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
    return LayoutBuilder(
      builder: (context, constraints) {
        var compact = false;
        var minH = 0.0;
        if (constraints.maxHeight.isFinite) {
          minH = constraints.maxHeight;
          if (minH < 280) {
            compact = true;
          }
        }
        return _EmptyBody(
          compact: compact,
          minHeight: minH,
          icon: icon,
          title: title,
          body: body,
          actionLabel: actionLabel,
          onAction: onAction,
        );
      },
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.compact,
    required this.minHeight,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final bool compact;
  final double minHeight;
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    final theme = Theme.of(context);
    var pad = AppTokens.s6;
    var well = 72.0;
    var glyph = 32.0;
    var gapAfterWell = AppTokens.s5;
    var gapBeforeCta = AppTokens.s5;
    var align = TextAlign.center;
    if (compact) {
      pad = AppTokens.s3;
      well = AppTokens.compactWell;
      glyph = AppTokens.compactIcon;
      gapAfterWell = AppTokens.s2;
      gapBeforeCta = AppTokens.s3;
      align = TextAlign.start;
    }
    final showCta = actionLabel != null && onAction != null;
    final wellBox = Container(
      width: well,
      height: well,
      decoration: BoxDecoration(
        color: c['surface-raised'],
        borderRadius: BorderRadius.circular(AppTokens.rLg),
      ),
      child: Icon(icon, size: glyph, color: c['text-muted']),
    );
    final titleText = Text(
      title,
      textAlign: align,
      style: theme.textTheme.titleMedium,
    );
    late final Widget inner;
    if (compact) {
      inner = Row(
        children: [
          wellBox,
          const SizedBox(width: AppTokens.s4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText,
                if (body != null) ...[
                  const SizedBox(height: AppTokens.s2),
                  Text(
                    body!,
                    textAlign: align,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (showCta) ...[
                  SizedBox(height: gapBeforeCta),
                  AppButton.secondary(
                    label: actionLabel!,
                    onPressed: onAction,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    } else {
      inner = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          wellBox,
          SizedBox(height: gapAfterWell),
          titleText,
          if (body != null) ...[
            const SizedBox(height: AppTokens.s2),
            Text(
              body!,
              textAlign: align,
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (showCta) ...[
            SizedBox(height: gapBeforeCta),
            AppButton.secondary(
              label: actionLabel!,
              onPressed: onAction,
            ),
          ],
        ],
      );
    }
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: inner,
            ),
          ),
        ),
      ),
    );
  }
}
