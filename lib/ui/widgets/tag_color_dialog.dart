import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'color_picker.dart';

/// What the tag color dialog returns.
sealed class _ColorChoice {
  const _ColorChoice();
}

class _Picked extends _ColorChoice {
  const _Picked(this.color);

  final int color;
}

class _Reset extends _ColorChoice {
  const _Reset();
}

/// Opens the tag color dialog (curated palette plus "Custom color...") and
/// saves the choice. Used from the Tags view header, the sidebar (dot and
/// right-click) and a tag chip's menu in the detail panel.
Future<void> changeTagColor(BuildContext context, Tag tag) async {
  final controller = HomeScope.of(context);
  final choice = await _showDialog(
    context,
    title: AppLocalizations.of(context).tagColorTitle(tag.name),
    current: tag.color,
  );
  if (choice is _Picked) await controller.setTagColor(tag.id, choice.color);
}

/// Same dialog for the "overdue" auto tag, plus "Use default" to go back to
/// the theme's warning color.
Future<void> changeOverdueTagColor(BuildContext context) async {
  final controller = HomeScope.of(context);
  final l10n = AppLocalizations.of(context);
  final colors = WayfinchColors.of(context);
  final choice = await _showDialog(
    context,
    title: l10n.tagColorTitle(l10n.overdueTag),
    current: controller.overdueTagColor ?? colors.warningText.toARGB32(),
    canReset: controller.overdueTagColor != null,
  );
  switch (choice) {
    case _Picked(:final color):
      await controller.setOverdueTagColor(color);
    case _Reset():
      await controller.setOverdueTagColor(null);
    case null:
      break;
  }
}

Future<_ColorChoice?> _showDialog(
  BuildContext context, {
  required String title,
  required int current,
  bool canReset = false,
}) {
  final colors = WayfinchColors.of(context);
  final l10n = AppLocalizations.of(context);
  return showDialog<_ColorChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final pair in tagPalette)
              Swatch(
                size: 34,
                color: colors.tagColor(pair.light),
                selected: pair.light == current,
                onTap: () => Navigator.pop(dialogContext, _Picked(pair.light)),
              ),
          ],
        ),
      ),
      actions: [
        if (canReset)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, const _Reset()),
            child: Text(l10n.useDefaultColor),
          ),
        TextButton(
          onPressed: () async {
            final custom = await showColorPicker(
              dialogContext,
              initial: Color(current),
              title: title,
            );
            if (custom != null && dialogContext.mounted) {
              Navigator.pop(dialogContext, _Picked(custom.toARGB32()));
            }
          },
          child: Text(l10n.customColor),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.promptCancel),
        ),
      ],
    ),
  );
}
