import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/item_enums.dart';
import 'color_math.dart';

/// Light, dark, or follow Windows.
enum ThemeModeSetting {
  /// Follow the system setting.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// The accent colors from the spec, plus the user's custom theme.
enum AccentChoice {
  /// Sky (default).
  sky,

  /// Honey.
  honey,

  /// Meadow.
  meadow,

  /// Lilac.
  lilac,

  /// Mono.
  mono,

  /// The custom theme builder's palette.
  custom,
}

/// Values for one built-in accent (spec: "Visual design and themes").
class AccentSpec {
  /// Creates an accent.
  const AccentSpec({
    required this.fill,
    required this.textOnLight,
    required this.onFillLight,
    this.darkFill,
  });

  /// Fill color (buttons, selection, progress) in light and dark.
  final Color fill;

  /// Fill override in dark mode (Mono only).
  final Color? darkFill;

  /// Accent-colored text on light backgrounds.
  final Color textOnLight;

  /// Text on the accent fill in light mode.
  final Color onFillLight;
}

/// Built-in accents.
const accentSpecs = <AccentChoice, AccentSpec>{
  AccentChoice.sky: AccentSpec(
    fill: Color(0xFF60A3EB),
    textOnLight: Color(0xFF1F5FA8),
    onFillLight: Color(0xFF10233A),
  ),
  AccentChoice.honey: AccentSpec(
    fill: Color(0xFFFABF66),
    textOnLight: Color(0xFF8A5300),
    onFillLight: Color(0xFF3A2400),
  ),
  AccentChoice.meadow: AccentSpec(
    fill: Color(0xFF3CCB6B),
    textOnLight: Color(0xFF1A7A3A),
    onFillLight: Color(0xFF0C2E17),
  ),
  AccentChoice.lilac: AccentSpec(
    fill: Color(0xFFB9A4EB),
    textOnLight: Color(0xFF6146B8),
    onFillLight: Color(0xFF241645),
  ),
  AccentChoice.mono: AccentSpec(
    fill: Color(0xFF343A40),
    darkFill: Color(0xFFDEE2E6),
    textOnLight: Color(0xFF343A40),
    onFillLight: Color(0xFFFFFFFF),
  ),
};

/// The colors a user picks in the custom theme builder. Everything else
/// (borders, muted text, text on the accent...) is derived from these.
@immutable
class CustomTheme {
  /// Creates a custom palette.
  const CustomTheme({
    required this.accent,
    required this.background,
    required this.panel,
    required this.sidebar,
    required this.text,
  });

  /// Starting point: the Sky light theme.
  static const lightStart = CustomTheme(
    accent: Color(0xFF60A3EB),
    background: Color(0xFFE9ECF1),
    panel: Color(0xFFFFFFFF),
    sidebar: Color(0xFFF4F6F9),
    text: Color(0xFF1B1F27),
  );

  /// Starting point: the Sky dark theme.
  static const darkStart = CustomTheme(
    accent: Color(0xFF60A3EB),
    background: Color(0xFF121418),
    panel: Color(0xFF1A1D23),
    sidebar: Color(0xFF16191E),
    text: Color(0xFFECEEF2),
  );

  /// Accent fill.
  final Color accent;

  /// App background.
  final Color background;

  /// Panels (list card, detail panel).
  final Color panel;

  /// Sidebar.
  final Color sidebar;

  /// Main text.
  final Color text;

  /// Whether this palette is dark (decided by the panel color).
  bool get isDarkTheme => isDark(panel);

  /// Returns a copy with some colors replaced.
  CustomTheme copyWith({
    Color? accent,
    Color? background,
    Color? panel,
    Color? sidebar,
    Color? text,
  }) => CustomTheme(
    accent: accent ?? this.accent,
    background: background ?? this.background,
    panel: panel ?? this.panel,
    sidebar: sidebar ?? this.sidebar,
    text: text ?? this.text,
  );

  /// Serializes to a JSON string.
  String encode() => jsonEncode({
    'accent': toHex(accent),
    'background': toHex(background),
    'panel': toHex(panel),
    'sidebar': toHex(sidebar),
    'text': toHex(text),
  });

  /// Reads [encode]'s output; falls back to [lightStart] for bad input.
  static CustomTheme decode(String? source) {
    if (source == null) return lightStart;
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      Color read(String key, Color fallback) =>
          parseHex(map[key] as String? ?? '') ?? fallback;
      return CustomTheme(
        accent: read('accent', lightStart.accent),
        background: read('background', lightStart.background),
        panel: read('panel', lightStart.panel),
        sidebar: read('sidebar', lightStart.sidebar),
        text: read('text', lightStart.text),
      );
    } on Object {
      return lightStart;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CustomTheme &&
      other.accent == accent &&
      other.background == background &&
      other.panel == panel &&
      other.sidebar == sidebar &&
      other.text == text;

  @override
  int get hashCode => Object.hash(accent, background, panel, sidebar, text);
}

/// Everything the user chose about the app's look.
@immutable
class ThemeSettings {
  /// Creates settings.
  const ThemeSettings({
    this.mode = ThemeModeSetting.system,
    this.accent = AccentChoice.sky,
    this.custom = CustomTheme.lightStart,
  });

  /// Light / dark / system. Ignored while the custom theme is active (it
  /// defines its own light or dark look).
  final ThemeModeSetting mode;

  /// The accent, or [AccentChoice.custom].
  final AccentChoice accent;

  /// The custom palette (kept even when another accent is active).
  final CustomTheme custom;

  /// Returns a copy with some fields replaced.
  ThemeSettings copyWith({
    ThemeModeSetting? mode,
    AccentChoice? accent,
    CustomTheme? custom,
  }) => ThemeSettings(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    custom: custom ?? this.custom,
  );

  @override
  bool operator ==(Object other) =>
      other is ThemeSettings &&
      other.mode == mode &&
      other.accent == accent &&
      other.custom == custom;

  @override
  int get hashCode => Object.hash(mode, accent, custom);
}

/// All theme colors in one place (values from the spec's "Visual design and
/// themes").
@immutable
class WayfinchColors extends ThemeExtension<WayfinchColors> {
  /// Creates a color set.
  const WayfinchColors({
    required this.brightness,
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
  static final light = resolve(Brightness.light, AccentChoice.sky);

  /// Builds the colors for [brightness] and [accent]. [custom] is used when
  /// [accent] is [AccentChoice.custom] (and then decides brightness itself).
  static WayfinchColors resolve(
    Brightness brightness,
    AccentChoice accent, {
    CustomTheme custom = CustomTheme.lightStart,
  }) {
    if (accent == AccentChoice.custom) return _fromCustom(custom);
    final spec = accentSpecs[accent]!;
    final dark = brightness == Brightness.dark;
    final fill = dark ? (spec.darkFill ?? spec.fill) : spec.fill;
    final base = dark ? _darkBase : _lightBase;
    return base._withAccent(
      accent: fill,
      accentText: dark ? fill : spec.textOnLight,
      onAccent: dark ? const Color(0xFF121418) : spec.onFillLight,
    );
  }

  static const _lightBase = WayfinchColors(
    brightness: Brightness.light,
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

  static const _darkBase = WayfinchColors(
    brightness: Brightness.dark,
    background: Color(0xFF121418),
    panel: Color(0xFF1A1D23),
    sidebar: Color(0xFF16191E),
    border: Color(0xFF2C3039),
    text: Color(0xFFECEEF2),
    muted: Color(0xFFA7ADB9),
    subtle: Color(0xFF242830),
    warningBackground: Color(0xFF3A2A10),
    warningText: Color(0xFFFFCF7A),
    warningBorder: Color(0xFF5C4318),
    accent: Color(0xFF60A3EB),
    accentText: Color(0xFF60A3EB),
    onAccent: Color(0xFF121418),
    priorityHigh: Color(0xFFFF8787),
    priorityMedium: Color(0xFFFFC078),
    priorityLow: Color(0xFF74C0FC),
  );

  static WayfinchColors _fromCustom(CustomTheme c) {
    final base = c.isDarkTheme ? _darkBase : _lightBase;
    return WayfinchColors(
      brightness: base.brightness,
      background: c.background,
      panel: c.panel,
      sidebar: c.sidebar,
      border: mix(c.panel, c.text, 0.15),
      text: c.text,
      muted: mix(c.text, c.panel, 0.35),
      subtle: mix(c.panel, c.text, 0.06),
      warningBackground: base.warningBackground,
      warningText: base.warningText,
      warningBorder: base.warningBorder,
      accent: c.accent,
      accentText: readableOn(c.accent, c.panel),
      onAccent: mostContrasting(c.accent, const [
        Color(0xFF121418),
        Color(0xFFFFFFFF),
      ]),
      priorityHigh: base.priorityHigh,
      priorityMedium: base.priorityMedium,
      priorityLow: base.priorityLow,
    );
  }

  WayfinchColors _withAccent({
    required Color accent,
    required Color accentText,
    required Color onAccent,
  }) => WayfinchColors(
    brightness: brightness,
    background: background,
    panel: panel,
    sidebar: sidebar,
    border: border,
    text: text,
    muted: muted,
    subtle: subtle,
    warningBackground: warningBackground,
    warningText: warningText,
    warningBorder: warningBorder,
    accent: accent,
    accentText: accentText,
    onAccent: onAccent,
    priorityHigh: priorityHigh,
    priorityMedium: priorityMedium,
    priorityLow: priorityLow,
  );

  /// Light or dark.
  final Brightness brightness;

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

  /// Accent-colored text on panels.
  final Color accentText;

  /// Text on an accent fill.
  final Color onAccent;

  /// High priority.
  final Color priorityHigh;

  /// Medium priority.
  final Color priorityMedium;

  /// Low priority.
  final Color priorityLow;

  /// Whether this is a dark theme.
  bool get isDarkMode => brightness == Brightness.dark;

  /// Soft accent tint (selected rows, nav highlight).
  Color get accentSoft => accent.withValues(alpha: isDarkMode ? 0.18 : 0.2);

  /// The color for [priority], or null for none.
  Color? priorityColor(Priority priority) => switch (priority) {
    Priority.high => priorityHigh,
    Priority.medium => priorityMedium,
    Priority.low => priorityLow,
    Priority.none => null,
  };

  /// How tag color [stored] (as saved, a light-theme value) shows in this
  /// theme: curated colors switch to their dark-mode partner, and any other
  /// color is lightened or darkened until it stands out from the panel.
  Color tagColor(int stored) {
    if (isDarkMode) {
      for (final pair in tagPalette) {
        if (pair.light == stored) return Color(pair.dark);
      }
    }
    return readableOn(Color(stored), panel, target: 3);
  }

  /// Reads the colors from [context]'s theme.
  static WayfinchColors of(BuildContext context) =>
      Theme.of(context).extension<WayfinchColors>()!;

  @override
  WayfinchColors copyWith() => this;

  @override
  WayfinchColors lerp(WayfinchColors? other, double t) => other ?? this;
}

/// A curated tag color in its light- and dark-theme shades.
class TagColorPair {
  /// Creates a pair.
  const TagColorPair(this.light, this.dark);

  /// Shade used (and stored) in the light theme.
  final int light;

  /// Shade shown in the dark theme.
  final int dark;
}

/// Curated tag colors, used in order for new tags.
const tagPalette = <TagColorPair>[
  TagColorPair(0xFF7950F2, 0xFFB197FC), // violet
  TagColorPair(0xFF0C8599, 0xFF3BC9DB), // teal
  TagColorPair(0xFFD6336C, 0xFFF783AC), // pink
  TagColorPair(0xFF5C940D, 0xFFA9E34B), // lime
  TagColorPair(0xFFE8590C, 0xFFFFA94D), // orange
  TagColorPair(0xFF1971C2, 0xFF74C0FC), // blue
  TagColorPair(0xFF862E9C, 0xFFE599F7), // grape
  TagColorPair(0xFF2B8A3E, 0xFF8CE99A), // green
];

/// Picks the color for the tag created after [existingCount] tags.
int tagColorFor(int existingCount) =>
    tagPalette[existingCount % tagPalette.length].light;

/// A contrast problem in a palette.
enum ContrastIssue {
  /// Text on the background.
  textOnBackground,

  /// Text on panels.
  textOnPanel,

  /// Text on the sidebar.
  textOnSidebar,

  /// Secondary text on panels.
  mutedOnPanel,

  /// Text on the accent fill (buttons).
  textOnAccent,

  /// Accent-colored text (links, selected items) on panels.
  accentTextOnPanel,
}

/// Contrast problems in [colors] (WCAG AA, 4.5:1 for text). The custom
/// theme builder warns about these but never blocks them.
Map<ContrastIssue, double> contrastIssues(WayfinchColors colors) {
  final checks = <ContrastIssue, (Color, Color)>{
    ContrastIssue.textOnBackground: (colors.text, colors.background),
    ContrastIssue.textOnPanel: (colors.text, colors.panel),
    ContrastIssue.textOnSidebar: (colors.text, colors.sidebar),
    ContrastIssue.mutedOnPanel: (colors.muted, colors.panel),
    ContrastIssue.textOnAccent: (colors.onAccent, colors.accent),
    ContrastIssue.accentTextOnPanel: (colors.accentText, colors.panel),
  };
  return {
    for (final entry in checks.entries)
      if (contrastRatio(entry.value.$1, entry.value.$2) < minTextContrast)
        entry.key: contrastRatio(entry.value.$1, entry.value.$2),
  };
}

/// Builds the Material theme around [colors].
ThemeData buildTheme(WayfinchColors colors) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: colors.brightness,
        surface: colors.panel,
      ).copyWith(
        primary: colors.accentText,
        onPrimary: colors.isDarkMode ? colors.onAccent : Colors.white,
        onSurface: colors.text,
        outline: colors.border,
      );
  final base = colors.isDarkMode
      ? Typography.whiteMountainView
      : Typography.blackMountainView;
  return ThemeData(
    brightness: colors.brightness,
    colorScheme: scheme,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.panel,
    dividerColor: colors.border,
    extensions: [colors],
    textTheme: base.apply(
      fontFamily: 'Nunito',
      bodyColor: colors.text,
      displayColor: colors.text,
    ),
    dialogTheme: DialogThemeData(backgroundColor: colors.panel),
    popupMenuTheme: PopupMenuThemeData(color: colors.panel),
  );
}
