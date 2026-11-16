import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Plays a small burst of confetti when something is completed.
///
/// Wrap the app in it once; call [Celebration.burstFrom] with the widget
/// that was tapped. Skipped when the system asks for reduced motion.
class Celebration extends StatefulWidget {
  /// Wraps [child].
  const Celebration({super.key, required this.child});

  /// The app.
  final Widget child;

  /// Captures where [context]'s widget is now and returns a function that
  /// plays a burst there. Capture first, then complete: a finished item
  /// usually leaves the list, taking its widget with it.
  static VoidCallback prepare(BuildContext context) {
    final state = context.findAncestorStateOfType<_CelebrationState>();
    final box = context.findRenderObject();
    if (state == null || box is! RenderBox || !box.hasSize) return () {};
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return () {};
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final colors = WayfinchColors.of(context);
    return () {
      if (state.mounted) state._burst(center, colors);
    };
  }

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with TickerProviderStateMixin {
  final List<_Burst> _bursts = [];
  final _random = math.Random();

  void _burst(Offset globalCenter, WayfinchColors colors) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = box.globalToLocal(globalCenter);
    final palette = [
      colors.accent,
      colors.priorityMedium,
      Color(tagPalette[0].light),
      Color(tagPalette[1].light),
      Color(tagPalette[2].light),
    ];
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final burst = _Burst(
      center: center,
      controller: controller,
      particles: [
        for (var i = 0; i < 14; i++)
          _Particle(
            angle: (i / 14) * 2 * math.pi + _random.nextDouble() * 0.4,
            distance: 26 + _random.nextDouble() * 22,
            color: palette[i % palette.length],
            size: 4 + _random.nextDouble() * 3,
          ),
      ],
    );
    setState(() => _bursts.add(burst));
    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _bursts.remove(burst));
      controller.dispose();
    });
  }

  @override
  void dispose() {
    for (final b in _bursts) {
      b.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        for (final burst in _bursts)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: burst.controller,
                builder: (context, _) => CustomPaint(
                  painter: _BurstPainter(burst, burst.controller.value),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
  });

  final double angle;
  final double distance;
  final Color color;
  final double size;
}

class _Burst {
  _Burst({
    required this.center,
    required this.controller,
    required this.particles,
  });

  final Offset center;
  final AnimationController controller;
  final List<_Particle> particles;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.burst, this.t);

  final _Burst burst;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(t);
    final opacity = (1 - t).clamp(0.0, 1.0);
    for (final p in burst.particles) {
      final offset =
          burst.center +
          Offset(math.cos(p.angle), math.sin(p.angle)) * p.distance * eased +
          Offset(0, 10 * t * t); // a little gravity
      canvas.drawCircle(
        offset,
        p.size * (1 - 0.4 * t),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
