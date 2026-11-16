import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/tag_color_dialog.dart';

/// The tag's color dot in the Tags view header; opens the color dialog.
class TagColorButton extends StatelessWidget {
  /// Creates the button for [tag].
  const TagColorButton({super.key, required this.tag});

  /// The tag being edited.
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return IconButton(
      tooltip: AppLocalizations.of(context).changeTagColor,
      onPressed: () => changeTagColor(context, tag),
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
}
