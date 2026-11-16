import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

import '../domain/dates.dart';
import '../domain/item.dart';
import '../domain/reminders.dart';
import '../domain/views.dart';
import '../l10n/app_localizations.dart';
import '../ui/home/home_controller.dart';

/// A button on a notification.
class NotificationButton {
  /// Creates a button.
  const NotificationButton(this.label, this.arguments);

  /// Button text.
  final String label;

  /// What comes back to [NotificationService.handle] when it's clicked.
  final String arguments;
}

/// Shows system notifications (Windows toasts in the app; a fake in tests).
abstract interface class Notifier {
  /// Shows a notification. [payload] comes back to
  /// [NotificationService.handle] when the notification itself is clicked.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
    List<NotificationButton> buttons,
  });
}

/// Payload prefixes (internal).
const _open = 'open';
const _snooze = 'snooze';
const _digest = 'digest';

/// Reminders older than this when noticed (say, the PC was asleep) are
/// skipped rather than shown late.
const staleAfter = Duration(minutes: 30);

/// Decides when to show reminders, the morning digest and snoozed
/// reminders, holds them during quiet hours, and handles clicks on
/// notification buttons.
///
/// Its small state (last check, snoozes, held alerts, last digest day) is
/// stored in the settings table, so restarts don't repeat or lose anything.
class NotificationService {
  /// Creates the service for [home]'s data.
  NotificationService({
    required this.home,
    required this.notifier,
    required this.l10n,
    required this.locale,
    this.onOpenItem,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Items and settings.
  final HomeController home;

  /// Shows notifications.
  final Notifier notifier;

  /// Strings in the app language.
  final AppLocalizations l10n;

  /// Locale tag for date formats.
  final String locale;

  /// Called when a reminder (item id) or the digest (null) is clicked.
  final void Function(String? itemId)? onOpenItem;

  final DateTime Function() _clock;
  Timer? _timer;
  bool _ticking = false;

  static const _lastCheckKey = 'notif.lastCheck';
  static const _snoozesKey = 'notif.snoozes';
  static const _heldKey = 'notif.held';
  static const _digestKey = 'notif.digestLast';

  /// Starts checking every [every].
  void start({Duration every = const Duration(seconds: 20)}) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => tick());
    unawaited(tick());
  }

  /// Stops checking.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// One check: shows whatever came due since the last check (or holds it
  /// during quiet hours).
  Future<void> tick() async {
    if (_ticking) return;
    _ticking = true;
    try {
      await _tick();
    } finally {
      _ticking = false;
    }
  }

  Future<void> _tick() async {
    final settings = home.settings;
    final now = _clock();
    final prefs = home.notificationPrefs;
    final last = DateTime.tryParse(
      await settings.getValue(_lastCheckKey) ?? '',
    );
    await settings.setValue(_lastCheckKey, now.toIso8601String());
    // First run: start from now instead of replaying the past.
    final from = last ?? now;
    final cutoff = now.subtract(staleAfter);

    final due = <_Pending>[
      for (final a in remindersBetween(
        home.tree.all,
        prefs.defaults,
        from,
        now,
      ))
        if (!a.fireAt.isBefore(cutoff)) _Pending.reminder(a.itemId),
    ];

    // Snoozed reminders whose time has come.
    final snoozes = await _loadSnoozes();
    final stillWaiting = <_Snooze>[];
    for (final s in snoozes) {
      if (s.until.isAfter(now)) {
        stillWaiting.add(s);
      } else if (!s.until.isBefore(cutoff)) {
        due.add(_Pending.reminder(s.itemId));
      }
    }
    if (stillWaiting.length != snoozes.length) await _saveSnoozes(stillWaiting);

    final lastDigest = DateTime.tryParse(
      await settings.getValue(_digestKey) ?? '',
    );
    if (digestDue(
      now: now,
      enabled: prefs.digestEnabled,
      hour: prefs.digestHour,
      minute: prefs.digestMinute,
      lastShown: lastDigest,
    )) {
      due.add(const _Pending.digest());
      await settings.setValue(_digestKey, now.toIso8601String());
    }

    final held = await _loadHeld();
    final quiet = prefs.quietHours;
    if (quiet != null && quiet.contains(now)) {
      if (due.isNotEmpty) await _saveHeld([...held, ...due]);
      return;
    }
    if (held.isNotEmpty) await _saveHeld(const []);
    for (final p in [...held, ...due]) {
      await _show(p, now);
    }
  }

  /// Handles a click on a notification or one of its buttons.
  Future<void> handle(String arguments) async {
    final parts = arguments.split('|');
    switch (parts.first) {
      case _open when parts.length == 2:
        onOpenItem?.call(parts[1]);
      case _digest:
        onOpenItem?.call(null);
      case _snooze when parts.length == 3:
        final choice = SnoozeChoice.values.asNameMap()[parts[1]];
        if (choice == null) return;
        final snoozes = await _loadSnoozes();
        await _saveSnoozes([
          ...snoozes.where((s) => s.itemId != parts[2]),
          _Snooze(parts[2], snoozeUntil(_clock(), choice)),
        ]);
    }
  }

  Future<void> _show(_Pending p, DateTime now) async {
    if (p.isDigest) return _showDigest(now);
    final item = home.tree[p.itemId];
    if (item == null || item.isDone || item.isEnded(now)) return;
    await notifier.show(
      id: (item.id.hashCode ^ now.millisecondsSinceEpoch) & 0x7fffffff,
      title: item.title,
      body: _when(item, now),
      payload: '$_open|${item.id}',
      buttons: [
        NotificationButton(
          l10n.notifSnooze10,
          '$_snooze|${SnoozeChoice.tenMinutes.name}|${item.id}',
        ),
        NotificationButton(
          l10n.notifSnooze60,
          '$_snooze|${SnoozeChoice.oneHour.name}|${item.id}',
        ),
        NotificationButton(
          l10n.notifSnoozeTomorrow,
          '$_snooze|${SnoozeChoice.tomorrow.name}|${item.id}',
        ),
      ],
    );
  }

  Future<void> _showDigest(DateTime now) async {
    final today = ViewBuilder(home.tree, now).today();
    final items = {
      for (final e in today.entries.whereType<ItemEntry>()) e.item.id: e.item,
    }.values.toList();
    final name = home.firstName;
    final count = items.length;
    final title = count == 0
        ? l10n.digestNothing
        : name.isEmpty
        ? l10n.digestTitle(count)
        : l10n.digestTitleName(name, count);
    final shown = items.take(3).map((i) => '• ${i.title}').join('\n');
    final more = count > 3 ? '\n${l10n.digestMore(count - 3)}' : '';
    await notifier.show(
      id: 1,
      title: title,
      body: count == 0 ? l10n.digestNothingBody : '$shown$more',
      payload: _digest,
    );
  }

  String _when(Item item, DateTime now) {
    final at = item.isEvent ? item.start! : item.due!;
    final time = DateFormat.jm(locale).format(at);
    if (isSameDay(at, now)) {
      return item.isEvent ? l10n.notifStartsAt(time) : l10n.notifDueAt(time);
    }
    final day = DateFormat.MMMEd(locale).format(at);
    return item.isEvent
        ? l10n.notifStartsOn(day, time)
        : l10n.notifDueOn(day, time);
  }

  Future<List<_Snooze>> _loadSnoozes() async {
    final raw = await home.settings.getValue(_snoozesKey);
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          _Snooze(
            (e as Map<String, dynamic>)['item'] as String,
            DateTime.parse(e['until'] as String),
          ),
      ];
    } on Object {
      return [];
    }
  }

  Future<void> _saveSnoozes(List<_Snooze> snoozes) => home.settings.setValue(
    _snoozesKey,
    snoozes.isEmpty
        ? null
        : jsonEncode([
            for (final s in snoozes)
              {'item': s.itemId, 'until': s.until.toIso8601String()},
          ]),
  );

  Future<List<_Pending>> _loadHeld() async {
    final raw = await home.settings.getValue(_heldKey);
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          e == _digest
              ? const _Pending.digest()
              : _Pending.reminder(e as String),
      ];
    } on Object {
      return [];
    }
  }

  Future<void> _saveHeld(List<_Pending> held) => home.settings.setValue(
    _heldKey,
    held.isEmpty
        ? null
        : jsonEncode([for (final p in held) p.isDigest ? _digest : p.itemId]),
  );
}

class _Pending {
  const _Pending.reminder(this.itemId) : isDigest = false;
  const _Pending.digest() : itemId = null, isDigest = true;

  final String? itemId;
  final bool isDigest;
}

class _Snooze {
  const _Snooze(this.itemId, this.until);

  final String itemId;
  final DateTime until;
}
