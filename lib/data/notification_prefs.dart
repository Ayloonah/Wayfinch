import 'settings_repository.dart';

/// Notification choices made during setup (and later in Settings).
///
/// Milestone 5 only stores these; milestone 6 uses them for reminders, the
/// daily digest and launching at startup.
class NotificationPrefs {
  /// Creates preferences. Defaults follow the spec.
  const NotificationPrefs({
    this.taskReminderMinutes = 60,
    this.eventReminderMinutes = 15,
    this.digestEnabled = true,
    this.digestHour = 8,
    this.digestMinute = 0,
    this.launchAtStartup = true,
  });

  /// Default reminder before a task is due (minutes; 0 = none).
  final int taskReminderMinutes;

  /// Default reminder before an event starts (minutes; 0 = none).
  final int eventReminderMinutes;

  /// Whether the morning digest is on.
  final bool digestEnabled;

  /// Digest time (hour).
  final int digestHour;

  /// Digest time (minute).
  final int digestMinute;

  /// Whether Wayfinch starts with Windows.
  final bool launchAtStartup;

  /// Reminder choices offered (minutes before; 0 = none).
  static const reminderChoices = [0, 5, 15, 30, 60, 120, 1440];

  static const _task = 'notif.taskReminderMinutes';
  static const _event = 'notif.eventReminderMinutes';
  static const _digest = 'notif.digestEnabled';
  static const _digestTime = 'notif.digestTime';
  static const _startup = 'app.launchAtStartup';

  /// Returns a copy with some fields changed.
  NotificationPrefs copyWith({
    int? taskReminderMinutes,
    int? eventReminderMinutes,
    bool? digestEnabled,
    int? digestHour,
    int? digestMinute,
    bool? launchAtStartup,
  }) => NotificationPrefs(
    taskReminderMinutes: taskReminderMinutes ?? this.taskReminderMinutes,
    eventReminderMinutes: eventReminderMinutes ?? this.eventReminderMinutes,
    digestEnabled: digestEnabled ?? this.digestEnabled,
    digestHour: digestHour ?? this.digestHour,
    digestMinute: digestMinute ?? this.digestMinute,
    launchAtStartup: launchAtStartup ?? this.launchAtStartup,
  );

  /// Reads stored preferences (defaults for anything missing).
  static Future<NotificationPrefs> load(SettingsRepository settings) async {
    const d = NotificationPrefs();
    final time = (await settings.getValue(_digestTime) ?? '').split(':');
    return NotificationPrefs(
      taskReminderMinutes:
          int.tryParse(await settings.getValue(_task) ?? '') ??
          d.taskReminderMinutes,
      eventReminderMinutes:
          int.tryParse(await settings.getValue(_event) ?? '') ??
          d.eventReminderMinutes,
      digestEnabled:
          (await settings.getValue(_digest) ?? '${d.digestEnabled}') == 'true',
      digestHour: time.length == 2
          ? int.tryParse(time[0]) ?? d.digestHour
          : d.digestHour,
      digestMinute: time.length == 2
          ? int.tryParse(time[1]) ?? d.digestMinute
          : d.digestMinute,
      launchAtStartup:
          (await settings.getValue(_startup) ?? '${d.launchAtStartup}') ==
          'true',
    );
  }

  /// Stores these preferences.
  Future<void> save(SettingsRepository settings) async {
    String two(int n) => n.toString().padLeft(2, '0');
    await settings.setValue(_task, '$taskReminderMinutes');
    await settings.setValue(_event, '$eventReminderMinutes');
    await settings.setValue(_digest, '$digestEnabled');
    await settings.setValue(
      _digestTime,
      '${two(digestHour)}:${two(digestMinute)}',
    );
    await settings.setValue(_startup, '$launchAtStartup');
  }
}
