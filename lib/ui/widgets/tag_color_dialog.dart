import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'color_picker.dart';

/// Opens the tag color dialog (curated palette plus "Custom color...") and
/// saves the choice. Used from the Tags view header, the sidebar's tag menu
/// and a tag chip's menu in the detail panel.
Future<void> changeTagColor(BuildContext context, Tag tag) async {
  final controller = HomeScope.of(context);
  final colors = WayfinchColors.of(context);
  final l10n = AppLocalizations.of(context);
  final picked = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.tagColorTitle(tag.name)),
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
                selected: pair.light == tag.color,
                onTap: () => Navigator.pop(context, pair.light),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final custom = await showColorPicker(
              context,
              initial: Color(tag.color),
              title: l10n.tagColorTitle(tag.name),
            );
            if (custom != null && context.mounted) {
              Navigator.pop(context, custom.toARGB32());
            }
          },
          child: Text(l10n.customColor),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.promptCancel),
        ),
      ],
    ),
  );
  if (picked != null) await controller.setTagColor(tag.id, picked);
}
