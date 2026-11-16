import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The Wayfinch finch logo: a small bird on a soft accent circle.
class FinchLogo extends StatelessWidget {
  /// Creates the logo at [size] pixels.
  const FinchLogo({super.key, this.size = 36});

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _FinchPainter(
        circle: colors.accentSoft,
        bird: colors.accent,
        eye: colors.panel,
      ),
    );
  }
}

class _FinchPainter extends CustomPainter {
  _FinchPainter({required this.circle, required this.bird, required this.eye});

  final Color circle;
  final Color bird;
  final Color eye;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 34);
    canvas.drawCircle(const Offset(17, 17), 17, Paint()..color = circle);
    final body = Path()
      ..moveTo(7, 20)
      ..cubicTo(7, 15, 11, 11, 16.5, 11)
      ..cubicTo(19.5, 11, 21.7, 12.5, 22.7, 14.6)
      ..lineTo(27, 15)
      ..lineTo(23.4, 17.1)
      ..cubicTo(23.4, 21.7, 19.8, 25.1, 14.8, 25.1)
      ..cubicTo(12.2, 25.1, 10.2, 24.1, 8.7, 22.5)
      ..lineTo(5.5, 23.5)
      ..close();
    canvas.drawPath(body, Paint()..color = bird);
    canvas.drawCircle(const Offset(20, 15.6), 1.4, Paint()..color = eye);
  }

  @override
  bool shouldRepaint(_FinchPainter old) =>
      old.circle != circle || old.bird != bird || old.eye != eye;
}
