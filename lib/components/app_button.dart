import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Visual treatment of an [AppButton].
enum AppButtonVariant {
  /// Copper fill — the single primary action on a screen.
  primary,

  /// Hairline outline, ink label.
  secondary,

  /// No chrome, navy/ink label.
  ghost,
}

/// ENCRE pressable button. Scale 0.98 on tap, never a 1.1 punch.
class AppButton extends StatefulWidget {
  /// Creates an ENCRE button.
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = true,
    super.key,
  });

  /// Copper filled CTA.
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  }) : variant = AppButtonVariant.primary;

  /// Outlined CTA.
  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  /// Text-only CTA.
  const AppButton.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  }) : variant = AppButtonVariant.ghost;

  /// Button label.
  final String label;

  /// Tap handler. Ignored when null (disabled).
  final VoidCallback? onPressed;

  /// Visual treatment.
  final AppButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// When true, stretches to the parent's width.
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    final copper = c['button-color']!;
    final onCopper = c['on-button']!;
    final ink = c['text']!;
    final navy = c['navy']!;
    final border = c['border']!;

    late final Color bg;
    late final Color fg;
    late final BorderSide side;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = copper;
        fg = onCopper;
        side = BorderSide.none;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = ink;
        side = BorderSide(color: border);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = navy;
        side = BorderSide.none;
    }

    var rowSize = MainAxisSize.min;
    if (widget.expanded) {
      rowSize = MainAxisSize.max;
    }
    final child = Row(
      mainAxisSize: rowSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: AppTokens.s2),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
            ),
          ),
        ),
      ],
    );

    var scale = 1.0;
    if (_pressed) {
      scale = AppTokens.pressScale;
    }
    var minWidth = AppTokens.tap;
    if (widget.expanded) {
      minWidth = double.infinity;
    }
    return AnimatedScale(
      scale: scale,
      duration: AppTokens.tMicro,
      curve: Curves.easeOut,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: AppTokens.buttonH,
          minWidth: minWidth,
        ),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rMd),
            side: side,
          ),
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(AppTokens.rMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s6,
                vertical: AppTokens.s4,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
