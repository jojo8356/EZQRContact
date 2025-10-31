import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

class AnimatedSubmitButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onPressed;
  final String label;

  const AnimatedSubmitButton({
    super.key,
    required this.isDark,
    required this.onPressed,
    required this.label,
  });

  @override
  State<AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  Color? _bgColor;

  @override
  void initState() {
    super.initState();
    _bgColor = currentColors['bg'];
  }

  void _onTap() async {
    // petite animation de "punch"
    setState(() => _scale = 1.1);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _scale = 1.0);

    // flash couleur
    setState(
      () => _bgColor = widget.isDark ? Colors.grey[800] : Colors.grey[300],
    );
    await Future.delayed(const Duration(milliseconds: 100));
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
