import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import '../widgets/color_picker.dart';

/// The tag's color dot in the Tags view header. Opens a menu with the
/// curated palette and "Custom color..." (the full picker).
class TagColorButton extends StatelessWidget {
  /// Creates the button for [tag].
  const TagColorButton({super.key, required this.tag});

  /// The tag being edited.
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: l10n.changeTagColor,
      onPressed: () => _open(context, controller, colors, l10n),
      icon: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: colors.tagColor(tag.color),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    HomeController controller,
    WayfinchColors colors,
    AppLocalizations l10n,
  ) async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeTagColor),
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
                title: l10n.changeTagColor,
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
}
