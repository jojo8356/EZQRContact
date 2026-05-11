import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Outlined button with a small "punch" scale and color-flash animation
/// triggered on press, used by every form submit screen of the app.
class AnimatedSubmitButton extends StatefulWidget {
  /// Creates the animated submit button.
  const AnimatedSubmitButton({
    required this.isDark,
    required this.onPressed,
    required this.label,
    super.key,
  });

  /// True when the app is in dark mode (shifts the flash background).
  final bool isDark;

  /// Callback invoked at the end of the press animation.
  final VoidCallback onPressed;

  /// Text label displayed inside the button.
  final String label;

  @override
  State<AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1;
  Color? _bgColor;

  @override
  void initState() {
    super.initState();
    _bgColor = currentColors['bg'];
  }

  Future<void> _onTap() async {
    // petite animation de "punch"
    setState(() => _scale = 1.1);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _scale = 1.0);

    // flash couleur
    setState(
      () => _bgColor = widget.isDark ? Colors.grey[800] : Colors.grey[300],
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _bgColor = currentColors['bg']);

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // 👈 force l'arrondi
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(color: _bgColor),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: currentColors['text'],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: _onTap,
            child: Text(
              widget.label,
              style: TextStyle(
                color: currentColors['text'],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
