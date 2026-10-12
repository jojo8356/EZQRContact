import 'package:flutter/material.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Three QR finder-pattern corners — the ENCRE brand mark.
class QrMark extends StatelessWidget {
  /// Creates the mark at [size] logical pixels.
  const QrMark({this.size = 22, this.color, super.key});

  /// Outer size.
  final double size;

  /// Stroke color. Defaults to copper.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final paintColor = color ?? currentColors['button-color']!;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QrMarkPainter(paintColor),
      ),
    );
  }
}

class _QrMarkPainter extends CustomPainter {
  _QrMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final inset = size.width * 0.08;
    final arm = size.width * 0.32;
    final s = size.width - inset;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + dy * arm)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + dx * arm, origin.dy);
      canvas.drawPath(path, stroke);
    }

    corner(Offset(inset, inset), 1, 1);
    corner(Offset(s, inset), -1, 1);
    corner(Offset(inset, s), 1, -1);
  }

  @override
  bool shouldRepaint(covariant _QrMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// EZQR wordmark used on the home app bar.
class EzqrWordmark extends StatelessWidget {
  /// Creates the wordmark.
  const EzqrWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = currentColors;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EZQR',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Contact',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: c['navy'],
            ),
          ),
          const SizedBox(width: 10),
          const QrMark(size: 16),
        ],
      ),
    );
  }
}
