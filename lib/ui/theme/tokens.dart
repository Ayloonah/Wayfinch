import 'package:flutter/material.dart';

import '../../domain/item_enums.dart';

/// All theme colors in one place (values from the spec's "Visual design and
/// themes"). Milestone 3 adds dark mode, the other accents and the custom
/// theme builder on top of this.
@immutable
class WayfinchColors extends ThemeExtension<WayfinchColors> {
  /// Creates a color set.
  const WayfinchColors({
    required this.background,
    required this.panel,
    required this.sidebar,
    required this.border,
    required this.text,
    required this.muted,
    required this.subtle,
    required this.warningBackground,
    required this.warningText,
    required this.warningBorder,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
  });

  /// Light theme with the Sky accent (the default).
  static const light = WayfinchColors(
    background: Color(0xFFE9ECF1),
    panel: Color(0xFFFFFFFF),
    sidebar: Color(0xFFF4F6F9),
    border: Color(0xFFD9DEE6),
    text: Color(0xFF1B1F27),
    muted: Color(0xFF565D6A),
    subtle: Color(0xFFEEF1F5),
    warningBackground: Color(0xFFFFE2A8),
    warningText: Color(0xFF6B3A00),
    warningBorder: Color(0xFFF0B54A),
    accent: Color(0xFF60A3EB),
    accentText: Color(0xFF1F5FA8),
    onAccent: Color(0xFF10233A),
    priorityHigh: Color(0xFFE03131),
    priorityMedium: Color(0xFFE67700),
    priorityLow: Color(0xFF1971C2),
  );

  /// App background.
  final Color background;

  /// Panels (list card, detail panel).
  final Color panel;

  /// Sidebar.
  final Color sidebar;

  /// Borders.
  final Color border;

  /// Main text.
  final Color text;

  /// Secondary text.
  final Color muted;

  /// Subtle fills (inputs, chips).
  final Color subtle;

  /// Warning background (overdue).
  final Color warningBackground;

  /// Warning text (overdue).
  final Color warningText;

  /// Warning border.
  final Color warningBorder;

  /// Accent fill (buttons, selection, progress).
  final Color accent;

  /// Accent-colored text on light backgrounds.
  final Color accentText;

  /// Text on an accent fill.
  final Color onAccent;

  /// High priority.
  final Color priorityHigh;

  /// Medium priority.
  final Color priorityMedium;

  /// Low priority.
  final Color priorityLow;

  /// Soft accent tint (selected rows, nav highlight).
  Color get accentSoft => accent.withValues(alpha: 0.2);

  /// The color for [priority], or null for none.
  Color? priorityColor(Priority priority) => switch (priority) {
    Priority.high => priorityHigh,
    Priority.medium => priorityMedium,
    Priority.low => priorityLow,
    Priority.none => null,
  };

  /// Reads the colors from [context]'s theme.
  static WayfinchColors of(BuildContext context) =>
      Theme.of(context).extension<WayfinchColors>()!;

  @override
  WayfinchColors copyWith() => this;

  @override
  WayfinchColors lerp(WayfinchColors? other, double t) => other ?? this;
}

/// Curated tag colors (light theme), used in order for new tags.
const tagPalette = <int>[
  0xFF7950F2, // violet
  0xFF0C8599, // teal
  0xFFD6336C, // pink
  0xFF5C940D, // green
  0xFFE8590C, // orange
  0xFF1971C2, // blue
  0xFF862E9C, // grape
  0xFF2B8A3E, // forest
];

/// Picks the color for the tag created after [existingCount] tags.
int tagColorFor(int existingCount) =>
    tagPalette[existingCount % tagPalette.length];

/// Builds the app theme.
ThemeData buildTheme() {
  const c = WayfinchColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: c.accent,
    surface: c.panel,
  ).copyWith(primary: c.accentText, onPrimary: Colors.white);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    dividerColor: c.border,
    extensions: const [c],
    textTheme: Typography.blackMountainView.apply(
      bodyColor: c.text,
      displayColor: c.text,
    ),
  );
}
