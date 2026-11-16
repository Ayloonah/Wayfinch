import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/appearance_controller.dart';
import '../theme/color_math.dart';
import '../theme/tokens.dart';
import '../widgets/color_picker.dart';

/// Settings › Appearance: light/dark/system, the accent, and the custom
/// theme builder with its contrast check. Changes apply instantly, so the
/// whole app is the live preview.
class AppearanceSection extends StatelessWidget {
  /// Creates the section.
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final settings = appearance.value;
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isCustom = settings.accent == AccentChoice.custom;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAppearance,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _Label(l10n.settingsTheme),
          const SizedBox(height: 8),
          SegmentedButton<ThemeModeSetting>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeModeSetting.system,
                label: Text(l10n.themeSystem),
                icon: const Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeModeSetting.light,
                label: Text(l10n.themeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeModeSetting.dark,
                label: Text(l10n.themeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {settings.mode},
            onSelectionChanged: isCustom
                ? null
                : (s) => appearance.setMode(s.single),
          ),
          if (isCustom) ...[
            const SizedBox(height: 6),
            Text(
              l10n.themeSetByCustom,
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
          ],
          const SizedBox(height: 20),
          _Label(l10n.settingsAccent),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final accent in AccentChoice.values)
                _AccentOption(
                  accent: accent,
                  selected: settings.accent == accent,
                ),
            ],
          ),
          if (isCustom) ...[
            const SizedBox(height: 24),
            const CustomThemeBuilder(),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: WayfinchColors.of(context).muted,
    ),
  );
}

class _AccentOption extends StatelessWidget {
  const _AccentOption({required this.accent, required this.selected});

  final AccentChoice accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final name = switch (accent) {
      AccentChoice.sky => l10n.accentSky,
      AccentChoice.honey => l10n.accentHoney,
      AccentChoice.meadow => l10n.accentMeadow,
      AccentChoice.lilac => l10n.accentLilac,
      AccentChoice.mono => l10n.accentMono,
      AccentChoice.custom => l10n.accentCustom,
    };
    final Color fill;
    if (accent == AccentChoice.custom) {
      fill = appearance.value.custom.accent;
    } else {
      final spec = accentSpecs[accent]!;
      fill = colors.isDarkMode ? (spec.darkFill ?? spec.fill) : spec.fill;
    }
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Swatch(
            size: 40,
            color: fill,
            selected: selected,
            tooltip: name,
            onTap: () => appearance.setAccent(accent),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Color pickers for the custom palette, plus contrast warnings (which
/// never block saving).
class CustomThemeBuilder extends StatelessWidget {
  /// Creates the builder.
  const CustomThemeBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final custom = appearance.value.custom;
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final rows = <(String, Color, CustomTheme Function(Color))>[
      (l10n.customAccent, custom.accent, (c) => custom.copyWith(accent: c)),
      (
        l10n.customBackground,
        custom.background,
        (c) => custom.copyWith(background: c),
      ),
      (l10n.customPanel, custom.panel, (c) => custom.copyWith(panel: c)),
      (l10n.customSidebar, custom.sidebar, (c) => custom.copyWith(sidebar: c)),
      (l10n.customText, custom.text, (c) => custom.copyWith(text: c)),
    ];
    final issues = contrastIssues(
      WayfinchColors.resolve(
        Brightness.light,
        AccentChoice.custom,
        custom: custom,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.subtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.customThemeTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => appearance.setCustom(CustomTheme.lightStart),
                child: Text(l10n.customStartLight),
              ),
              TextButton(
                onPressed: () => appearance.setCustom(CustomTheme.darkStart),
                child: Text(l10n.customStartDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final (label, color, apply) in rows)
            _ColorRow(
              label: label,
              color: color,
              onPick: (picked) => appearance.setCustom(apply(picked)),
            ),
          const SizedBox(height: 12),
          _ContrastReport(issues: issues),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onPick,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showColorPicker(
          context,
          initial: color,
          title: label,
        );
        if (picked != null) onPick(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(toHex(color), style: TextStyle(color: colors.muted)),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 16, color: colors.muted),
          ],
        ),
      ),
    );
  }
}

class _ContrastReport extends StatelessWidget {
  const _ContrastReport({required this.issues});

  final Map<ContrastIssue, double> issues;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    if (issues.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: colors.accentText),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.contrastAllGood)),
        ],
      );
    }
    String name(ContrastIssue issue) => switch (issue) {
      ContrastIssue.textOnBackground => l10n.contrastTextOnBackground,
      ContrastIssue.textOnPanel => l10n.contrastTextOnPanel,
      ContrastIssue.textOnSidebar => l10n.contrastTextOnSidebar,
      ContrastIssue.mutedOnPanel => l10n.contrastMutedOnPanel,
      ContrastIssue.textOnAccent => l10n.contrastTextOnAccent,
      ContrastIssue.accentTextOnPanel => l10n.contrastAccentTextOnPanel,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        border: Border.all(color: colors.warningBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.warningText),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contrastWarningTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            for (final entry in issues.entries)
              Text(
                l10n.contrastIssue(
                  name(entry.key),
                  entry.value.toStringAsFixed(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
