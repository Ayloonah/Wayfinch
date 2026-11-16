import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The Wayfinch mark: a yellow finch tucked into a checkmark.
///
/// Drawn from the same geometry as `docs/brand/wayfinch-mark.svg` (512×512
/// design grid). In dark mode the check is light, as in
/// `wayfinch-mark-dark.svg`, so it stays visible. (The white-outlined
/// version is only for the Windows app icon.)
class FinchLogo extends StatelessWidget {
  /// Creates the logo at [size] pixels.
  const FinchLogo({super.key, this.size = 36});

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = WayfinchColors.of(context).isDarkMode;
    return Semantics(
      label: 'Wayfinch',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: WayfinchMarkPainter(dark: dark),
      ),
    );
  }
}

/// Brand colors (fixed: the mark doesn't follow the accent).
const _yellow = Color(0xFFF7B84B);
const _navy = Color(0xFF23324A);
const _orange = Color(0xFFE8833A);
const _checkOnDark = Color(0xFFECEEF2);

/// Paints the mark into a square: `wayfinch-mark.svg`, or with [dark],
/// `wayfinch-mark-dark.svg` (light check). Also used by
/// `tool/render_icons_test.dart` to make the themed Windows icons.
class WayfinchMarkPainter extends CustomPainter {
  /// Creates the painter.
  WayfinchMarkPainter({required this.dark})
    : check = dark ? _checkOnDark : _navy;

  /// Whether to paint the dark-background version.
  final bool dark;

  /// Checkmark color.
  final Color check;

  // The bird is clipped to the area above the check's centerline, so it
  // tucks into the check with no gap.
  static final _above = Path()
    ..addPolygon(const [
      Offset(0, 0),
      Offset(512, 0),
      Offset(512, 135),
      Offset(202, 449),
      Offset(0, 241),
    ], true);

  static final _head = Path()
    ..addOval(Rect.fromCircle(center: const Offset(334, 126), radius: 88));

  static final _body = () {
    const center = Offset(242, 228);
    final oval = Path()
      ..addOval(Rect.fromCenter(center: center, width: 300, height: 244));
    final turn = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..rotateZ(-40 * math.pi / 180)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    return oval.transform(turn.storage);
  }();

  // Smooth dip between head and back.
  static final _dip = Path()
    ..moveTo(186, 154)
    ..quadraticBezierTo(236, 120, 266, 74)
    ..lineTo(310, 170)
    ..close();

  // Fills the crook of the check under the belly.
  static final _crook = Path()
    ..addPolygon(const [
      Offset(140, 300),
      Offset(202, 430),
      Offset(300, 330),
      Offset(240, 300),
    ], true);

  static final _wing = Path()
    ..moveTo(112, 282)
    ..cubicTo(148, 220, 214, 182, 266, 190)
    ..cubicTo(306, 196, 314, 242, 288, 272)
    ..cubicTo(258, 306, 196, 312, 156, 298)
    ..cubicTo(136, 290, 122, 284, 112, 282)
    ..close();

  static final _beak = Path()
    ..addPolygon(const [
      Offset(410, 102),
      Offset(466, 124),
      Offset(410, 148),
    ], true);

  static final _checkLine = Path()
    ..moveTo(69, 312)
    ..lineTo(202, 449)
    ..lineTo(447, 201);

  static Paint _fill(Color c) => Paint()..color = c;

  static Paint _stroke(Color c, double width) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final yellow = _fill(_yellow);
    canvas
      ..save()
      ..scale(size.width / 512)
      ..save()
      ..clipPath(_above)
      ..drawPath(_head, yellow)
      ..drawPath(_body, yellow)
      ..drawPath(_dip, yellow)
      ..drawPath(_crook, yellow)
      ..drawPath(_wing, _fill(_navy))
      ..restore()
      // Navy cap, clipped to the head.
      ..save()
      ..clipPath(_head)
      ..drawOval(
        Rect.fromCenter(center: const Offset(396, 30), width: 136, height: 116),
        _fill(_navy),
      )
      ..restore()
      ..drawPath(_beak, _fill(_orange))
      ..drawPath(_beak, _stroke(_orange, 10))
      ..drawCircle(const Offset(364, 122), 17, _fill(_navy))
      ..drawPath(_checkLine, _stroke(check, 87))
      ..restore();
  }

  @override
  bool shouldRepaint(WayfinchMarkPainter old) => old.dark != dark;
}
