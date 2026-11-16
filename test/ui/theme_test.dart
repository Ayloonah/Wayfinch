import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/ui/theme/color_math.dart';
import 'package:wayfinch/ui/theme/tokens.dart';

void main() {
  group('color math', () {
    test('contrast ratio matches WCAG reference values', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
      expect(contrastRatio(Colors.white, Colors.white), closeTo(1, 0.001));
      // #767676 on white is the classic 4.54:1 grey.
      expect(
        contrastRatio(const Color(0xFF767676), Colors.white),
        closeTo(4.54, 0.01),
      );
    });

    test('readableOn darkens on light and lightens on dark', () {
      const pale = Color(0xFFFFE066);
      final onWhite = readableOn(pale, Colors.white);
      expect(contrastRatio(onWhite, Colors.white), greaterThanOrEqualTo(4.5));
      const deep = Color(0xFF1A237E);
      final onBlack = readableOn(deep, const Color(0xFF121418));
      expect(
        contrastRatio(onBlack, const Color(0xFF121418)),
        greaterThanOrEqualTo(4.5),
      );
      // Already fine: unchanged.
      expect(readableOn(Colors.black, Colors.white), Colors.black);
    });

    test('hex parsing and formatting', () {
      expect(parseHex('#60A3EB'), const Color(0xFF60A3EB));
      expect(parseHex('60a3eb'), const Color(0xFF60A3EB));
      expect(parseHex('nope'), isNull);
      expect(parseHex('#123'), isNull);
      expect(toHex(const Color(0xFF0C8599)), '#0C8599');
    });
  });

  group('built-in themes', () {
    for (final accent in AccentChoice.values.where(
      (a) => a != AccentChoice.custom,
    )) {
      for (final brightness in Brightness.values) {
        test('${accent.name} ${brightness.name} passes the contrast check', () {
          final colors = WayfinchColors.resolve(brightness, accent);
          expect(contrastIssues(colors), isEmpty);
          expect(colors.brightness, brightness);
        });
      }
    }

    test('spec values: Sky light and Mono dark', () {
      final sky = WayfinchColors.resolve(Brightness.light, AccentChoice.sky);
      expect(sky.accent, const Color(0xFF60A3EB));
      expect(sky.accentText, const Color(0xFF1F5FA8));
      expect(sky.onAccent, const Color(0xFF10233A));
      expect(sky.background, const Color(0xFFE9ECF1));
      final mono = WayfinchColors.resolve(Brightness.dark, AccentChoice.mono);
      expect(mono.accent, const Color(0xFFDEE2E6));
      expect(mono.background, const Color(0xFF121418));
      expect(mono.priorityHigh, const Color(0xFFFF8787));
    });
  });

  group('custom theme', () {
    test('derives readable extras from five colors', () {
      final colors = WayfinchColors.resolve(
        Brightness.light,
        AccentChoice.custom,
        custom: CustomTheme.lightStart.copyWith(
          accent: const Color(0xFFFFE066), // pale yellow
        ),
      );
      // Text on the pale accent picks the dark option...
      expect(colors.onAccent, const Color(0xFF121418));
      // ...and accent-colored text is darkened until readable on panels.
      expect(
        contrastRatio(colors.accentText, colors.panel),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('dark panels make a dark theme, whatever the mode', () {
      final colors = WayfinchColors.resolve(
        Brightness.light,
        AccentChoice.custom,
        custom: CustomTheme.darkStart,
      );
      expect(colors.isDarkMode, isTrue);
      expect(CustomTheme.darkStart.isDarkTheme, isTrue);
      expect(CustomTheme.lightStart.isDarkTheme, isFalse);
    });

    test('warns about low contrast without blocking', () {
      final colors = WayfinchColors.resolve(
        Brightness.light,
        AccentChoice.custom,
        custom: CustomTheme.lightStart.copyWith(
          text: const Color(0xFFBBBBBB), // light grey text on white
        ),
      );
      final issues = contrastIssues(colors);
      expect(issues.keys, contains(ContrastIssue.textOnPanel));
      expect(issues[ContrastIssue.textOnPanel], lessThan(4.5));
    });

    test('encode/decode round trip, and bad input falls back', () {
      const custom = CustomTheme(
        accent: Color(0xFF123456),
        background: Color(0xFF000000),
        panel: Color(0xFF111111),
        sidebar: Color(0xFF222222),
        text: Color(0xFFEEEEEE),
      );
      expect(CustomTheme.decode(custom.encode()), custom);
      expect(CustomTheme.decode('garbage'), CustomTheme.lightStart);
      expect(CustomTheme.decode(null), CustomTheme.lightStart);
    });
  });

  group('tag colors', () {
    test('curated colors switch to their dark partner', () {
      final dark = WayfinchColors.resolve(Brightness.dark, AccentChoice.sky);
      final light = WayfinchColors.resolve(Brightness.light, AccentChoice.sky);
      final violet = tagPalette.first;
      expect(dark.tagColor(violet.light), Color(violet.dark));
      expect(light.tagColor(violet.light), Color(violet.light));
    });

    test('custom colors show exactly as picked, in light and dark', () {
      final dark = WayfinchColors.resolve(Brightness.dark, AccentChoice.sky);
      final light = WayfinchColors.resolve(Brightness.light, AccentChoice.sky);
      // A pastel on white used to get darkened until it looked unchanged.
      expect(light.tagColor(0xFFB9A4EB), const Color(0xFFB9A4EB));
      expect(dark.tagColor(0xFF123456), const Color(0xFF123456));
    });

    test('new tags cycle through the palette', () {
      expect(tagColorFor(0), tagPalette[0].light);
      expect(tagColorFor(tagPalette.length), tagPalette[0].light);
    });
  });
}
