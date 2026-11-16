import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tokens.dart';

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
