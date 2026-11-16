import 'package:flutter/material.dart';

import '../../data/notification_prefs.dart';
import '../../domain/item.dart';
import '../../domain/reminders.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// "1 hour before", "1 day before"... for a reminder offset in minutes.
String reminderLabel(AppLocalizations l10n, int minutes) => minutes == 0
    ? l10n.reminderAtTime
    : minutes < 60
    ? l10n.reminderMinutes(minutes)
    : minutes < 1440
    ? l10n.reminderHours(minutes ~/ 60)
    : l10n.reminderDays(minutes ~/ 1440);

/// The detail panel's Reminders row: chips for each reminder (click to
/// remove), "+ Reminder" to add one, and a "default" marker while the item
/// follows the global defaults.
class RemindersField extends StatelessWidget {
  /// Creates the row for [item].
  const RemindersField({super.key, required this.item});

  /// The item being edited.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    if (!canRemind(item)) {
      return Text(
        item.isTask && item.due != null
            ? l10n.remindersDateOnly
            : l10n.remindersNeedDate,
        style: TextStyle(fontSize: 13, color: colors.muted),
      );
    }
    final defaults = controller.notificationPrefs.defaults;
    final offsets = effectiveReminders(item, defaults);
    final isDefault = !item.customReminders;
    final chipStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: colors.text,
    );
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final m in offsets)
          InputChip(
            avatar: Icon(
              Icons.notifications_none,
              size: 16,
              color: colors.muted,
            ),
            label: Text(
              isDefault
                  ? l10n.reminderDefault(reminderLabel(l10n, m))
                  : reminderLabel(l10n, m),
              style: chipStyle,
            ),
            onDeleted: () => controller.setReminders(
              item,
              offsets.where((o) => o != m).toList(),
            ),
            deleteButtonTooltipMessage: l10n.reminderRemove,
          ),
        if (offsets.isEmpty)
          Text(l10n.reminderNone, style: TextStyle(color: colors.muted)),
        PopupMenuButton<int>(
          tooltip: l10n.reminderAdd,
          onSelected: (m) => controller.setReminders(item, [...offsets, m]),
          // Here 0 means "at the time" (in Settings it means "no reminder").
          itemBuilder: (context) => [
            for (final m in NotificationPrefs.reminderChoices)
              if (!offsets.contains(m))
                PopupMenuItem(value: m, child: Text(reminderLabel(l10n, m))),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              l10n.reminderAddButton,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.accentText,
              ),
            ),
          ),
        ),
        if (!isDefault)
          TextButton(
            onPressed: () => controller.useDefaultReminders(item),
            child: Text(l10n.reminderUseDefault),
          ),
      ],
    );
  }
}
