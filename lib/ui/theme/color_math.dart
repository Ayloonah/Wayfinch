import 'dart:math' as math;
import 'dart:ui' show Color;

/// WCAG relative luminance of [color] (0 = black, 1 = white).
double relativeLuminance(Color color) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// WCAG contrast ratio between two opaque colors (1 to 21).
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Minimum contrast for normal text (WCAG AA).
const minTextContrast = 4.5;

/// Whether [color] reads as a dark background.
bool isDark(Color color) => relativeLuminance(color) < 0.18;

/// Mixes [a] into [b]: `t = 0` gives [a], `t = 1` gives [b].
Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Of [candidates], the one with the most contrast against [background].
Color mostContrasting(Color background, List<Color> candidates) {
  var best = candidates.first;
  for (final c in candidates.skip(1)) {
    if (contrastRatio(c, background) > contrastRatio(best, background)) {
      best = c;
    }
  }
  return best;
}

/// [color] darkened (on light backgrounds) or lightened (on dark ones) just
/// enough to reach [target] contrast against [background]. Keeps the hue.
/// Returns the closest it can get if the target can't be reached.
Color readableOn(
  Color color,
  Color background, {
  double target = minTextContrast,
}) {
  if (contrastRatio(color, background) >= target) return color;
  final toward = isDark(background)
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
  for (var t = 0.05; t <= 1.0; t += 0.05) {
    final candidate = mix(color, toward, t);
    if (contrastRatio(candidate, background) >= target) return candidate;
  }
  return toward;
}

/// Parses `#RRGGBB` / `RRGGBB` (or 8-digit ARGB) into an opaque color.
/// Returns null for anything else.
Color? parseHex(String input) {
  final hex = input.trim().replaceFirst('#', '');
  if (!RegExp(r'^([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(hex)) return null;
  final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return Color(value | 0xFF000000);
}

/// `#RRGGBB` for [color].
String toHex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
