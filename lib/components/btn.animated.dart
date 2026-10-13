import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

/// Primary submit button with a 0.98 press scale (ENCRE "stamp", not punch).
class AnimatedSubmitButton extends StatefulWidget {
  /// Creates the animated submit button.
  const new({
    required this.isDark,
    required this.onPressed,
    required this.label,
    super.key,
  });

  /// True when the app is in dark mode (kept for call-site compatibility).
  final bool isDark;

  /// Callback invoked at the end of the press animation.
  final VoidCallback onPressed;

  /// Text label displayed inside the button.
  final String label;

  @override
  State<AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton> {
  bool _pressed = false;

  Future<void> _onTap() async {
    setState(() => _pressed = true);
    await Future<void>.delayed(AppTokens.tMicro);
    if (!mounted) return;
    setState(() => _pressed = false);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    var scale = 1.0;
    if (_pressed) {
      scale = AppTokens.pressScale;
    }
    return AnimatedScale(
      scale: scale,
      duration: AppTokens.tMicro,
      curve: Curves.easeOut,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppTokens.buttonH,
          minWidth: double.infinity,
        ),
        child: Material(
          color: c['button-color'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rMd),
          ),
          child: InkWell(
            onTap: _onTap,
            borderRadius: BorderRadius.circular(AppTokens.rMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s6,
                vertical: AppTokens.s4,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: c['on-button'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
