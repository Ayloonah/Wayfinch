import 'package:flutter/material.dart';

import '../../domain/exchange/import_plan.dart';
import '../../l10n/app_localizations.dart';
import '../list/item_row.dart' show indentFor;
import '../theme/tokens.dart';

/// The kinds of change an import preview shows.
enum ChangeKind {
  /// A new item.
  added,

  /// An existing item that changes.
  changed,

  /// An item that goes away.
  removed,
}

/// Background and text colors for a [ChangeKind] badge.
(Color, Color) changeKindColors(ChangeKind kind, WayfinchColors c) =>
    switch (kind) {
      ChangeKind.added => (
        c.isDarkMode ? const Color(0xFF1E3A26) : const Color(0xFFEBF7EE),
        c.isDarkMode ? const Color(0xFF8CE99A) : const Color(0xFF22662F),
      ),
      ChangeKind.changed => (c.accentSoft, c.accentText),
      ChangeKind.removed => (c.warningBackground, c.warningText),
    };

/// A rounded count ("3 new") in an import preview.
class CountChip extends StatelessWidget {
  /// Creates the chip.
  const CountChip({super.key, required this.text, required this.kind});

  /// What it says.
  final String text;

  /// Which colors to use.
  final ChangeKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = changeKindColors(kind, WayfinchColors.of(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

/// One entry of an import preview: badge, title, detail, and (for
/// removals) a Keep button.
class ChangeRow extends StatelessWidget {
  /// Creates the row.
  const ChangeRow({
    super.key,
    required this.change,
    required this.detail,
    this.kept = false,
    this.onToggleKeep,
  });

  /// The planned change.
  final PlannedChange change;

  /// Detail text (dates, what changed).
  final String detail;

  /// Whether a removal is being kept.
  final bool kept;

  /// Toggles keeping a removal (null for other entries).
  final VoidCallback? onToggleKeep;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final (kind, label) = switch (change) {
      AddedItem() => (ChangeKind.added, l10n.importBadgeNew),
      ChangedItem() => (ChangeKind.changed, l10n.importBadgeChanged),
      RemovedItem() => (ChangeKind.removed, l10n.importBadgeRemoved),
    };
    final (bg, fg) = changeKindColors(kind, colors);
    return Opacity(
      opacity: kept ? 0.55 : 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(indentFor(change.depth) - 4, 6, 12, 6),
        child: Row(
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kept ? l10n.importBadgeKept : label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                change.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (detail.isNotEmpty)
              Flexible(
                child: Text(
                  detail,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.muted,
                  ),
                ),
              ),
            if (onToggleKeep != null) ...[
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                onPressed: onToggleKeep,
                child: Text(kept ? l10n.importRemoveAnyway : l10n.importKeep),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small uppercase section label used in the Export and Import dialogs.
class SectionLabel extends StatelessWidget {
  /// Creates the label.
  const SectionLabel(this.text, {super.key});

  /// Label text (shown in uppercase).
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: WayfinchColors.of(context).muted,
      ),
    ),
  );
}

/// Title, subtitle and close button at the top of a big dialog.
class DialogHeader extends StatelessWidget {
  /// Creates the header.
  const DialogHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.subtitleIcon,
  });

  /// Title.
  final String title;

  /// Line under the title.
  final String subtitle;

  /// Optional icon before the title.
  final IconData? icon;

  /// Optional icon before the subtitle.
  final Widget? subtitleIcon;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: colors.accentText),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (subtitleIcon != null) ...[
                    subtitleIcon!,
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).close,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
