import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../onboarding/onboarding_flow.dart' show NotificationChoices;

/// Settings › Notifications: default reminders, morning digest, quiet hours
/// and starting with Windows. Changes save right away.
class NotificationsSection extends StatelessWidget {
  /// Creates the section.
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsNotifications,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          NotificationChoices(
            prefs: controller.notificationPrefs,
            onChanged: controller.saveNotificationPrefs,
            showQuietHours: true,
          ),
        ],
      ),
    );
  }
}
