import '../domain/reminders.dart';
import 'settings_repository.dart';

/// Notification choices: default reminders, the morning digest, quiet hours
/// and launching with Windows. Set during setup and in Settings.
class NotificationPrefs {
  /// Creates preferences. Defaults follow the spec.
  const NotificationPrefs({
    this.taskReminderMinutes = 60,
    this.eventReminderMinutes = 15,
    this.digestEnabled = true,
    this.digestHour = 8,
    this.digestMinute = 0,
    this.quietEnabled = false,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
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

  /// Whether quiet hours are on (off by default).
  final bool quietEnabled;

  /// Quiet hours start (minutes after midnight).
  final int quietStartMinutes;

  /// Quiet hours end (minutes after midnight).
  final int quietEndMinutes;

  /// Whether Wayfinch starts with Windows.
  final bool launchAtStartup;

  /// Reminder choices offered (minutes before; 0 = none).
  static const reminderChoices = [0, 5, 15, 30, 60, 120, 1440];

  static const _task = 'notif.taskReminderMinutes';
  static const _event = 'notif.eventReminderMinutes';
  static const _digest = 'notif.digestEnabled';
  static const _digestTime = 'notif.digestTime';
  static const _quiet = 'notif.quietEnabled';
  static const _quietStart = 'notif.quietStart';
  static const _quietEnd = 'notif.quietEnd';
  static const _startup = 'app.launchAtStartup';

  /// The global default reminders.
  ReminderDefaults get defaults => ReminderDefaults(
    taskMinutes: taskReminderMinutes,
    eventMinutes: eventReminderMinutes,
  );

  /// The quiet window, or null when quiet hours are off.
  QuietHours? get quietHours => quietEnabled
      ? QuietHours(startMinutes: quietStartMinutes, endMinutes: quietEndMinutes)
      : null;

  /// Returns a copy with some fields changed.
  NotificationPrefs copyWith({
    int? taskReminderMinutes,
    int? eventReminderMinutes,
    bool? digestEnabled,
    int? digestHour,
    int? digestMinute,
    bool? quietEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
    bool? launchAtStartup,
  }) => NotificationPrefs(
    taskReminderMinutes: taskReminderMinutes ?? this.taskReminderMinutes,
    eventReminderMinutes: eventReminderMinutes ?? this.eventReminderMinutes,
    digestEnabled: digestEnabled ?? this.digestEnabled,
    digestHour: digestHour ?? this.digestHour,
    digestMinute: digestMinute ?? this.digestMinute,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
    quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
    launchAtStartup: launchAtStartup ?? this.launchAtStartup,
  );

  /// Reads preferences from stored settings (defaults for anything missing).
  factory NotificationPrefs.fromMap(Map<String, String> values) {
    const d = NotificationPrefs();
    final time = (values[_digestTime] ?? '').split(':');
    int minutes(String? hhmm, int fallback) {
      final parts = (hhmm ?? '').split(':');
      if (parts.length != 2) return fallback;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      return h == null || m == null ? fallback : h * 60 + m;
    }

    return NotificationPrefs(
      taskReminderMinutes:
          int.tryParse(values[_task] ?? '') ?? d.taskReminderMinutes,
      eventReminderMinutes:
          int.tryParse(values[_event] ?? '') ?? d.eventReminderMinutes,
      digestEnabled: (values[_digest] ?? '${d.digestEnabled}') == 'true',
      digestHour: time.length == 2
          ? int.tryParse(time[0]) ?? d.digestHour
          : d.digestHour,
      digestMinute: time.length == 2
          ? int.tryParse(time[1]) ?? d.digestMinute
          : d.digestMinute,
      quietEnabled: (values[_quiet] ?? '${d.quietEnabled}') == 'true',
      quietStartMinutes: minutes(values[_quietStart], d.quietStartMinutes),
      quietEndMinutes: minutes(values[_quietEnd], d.quietEndMinutes),
      launchAtStartup: (values[_startup] ?? '${d.launchAtStartup}') == 'true',
    );
  }

  /// Reads stored preferences.
  static Future<NotificationPrefs> load(SettingsRepository settings) async =>
      NotificationPrefs.fromMap(await settings.watchAll().first);

  /// Stores these preferences.
  Future<void> save(SettingsRepository settings) async {
    String two(int n) => n.toString().padLeft(2, '0');
    String hhmm(int minutes) => '${two(minutes ~/ 60)}:${two(minutes % 60)}';
    await settings.setValue(_task, '$taskReminderMinutes');
    await settings.setValue(_event, '$eventReminderMinutes');
    await settings.setValue(_digest, '$digestEnabled');
    await settings.setValue(
      _digestTime,
      '${two(digestHour)}:${two(digestMinute)}',
    );
    await settings.setValue(_quiet, '$quietEnabled');
    await settings.setValue(_quietStart, hhmm(quietStartMinutes));
    await settings.setValue(_quietEnd, hhmm(quietEndMinutes));
    await settings.setValue(_startup, '$launchAtStartup');
  }
}
