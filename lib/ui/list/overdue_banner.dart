import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// "3 overdue items need a new plan" with Review and Snooze until tomorrow.
class OverdueBanner extends StatelessWidget {
  /// Creates the banner.
  const OverdueBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: colors.warningText,
    );
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          color: colors.warningBackground,
          border: Border.all(color: colors.warningBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.warningText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.overdueBanner(controller.overdueCount),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.warningText,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: colors.panel,
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: controller.reviewOverdue,
              child: Text(l10n.overdueReview, style: buttonText),
            ),
            const SizedBox(width: 4),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(0, 36)),
              onPressed: controller.snoozeBanner,
              child: Text(l10n.overdueSnooze, style: buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
