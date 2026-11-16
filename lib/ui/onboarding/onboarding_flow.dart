import 'package:flutter/material.dart';

import '../../data/encryption/key_vault.dart';
import '../../data/notification_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../app.dart' show SessionScope;
import '../home/home_controller.dart';
import '../theme/appearance_controller.dart';
import '../theme/tokens.dart';
import '../widgets/color_picker.dart' show Swatch;
import '../widgets/finch_logo.dart';
import '../security/password_widgets.dart';
import 'tutorial.dart';

enum _Step { welcome, name, password, recovery, vibe, notifications, aiLoop }

/// First-run setup: welcome, first name, optional password (+ recovery
/// code), pick your vibe, notifications, then how the AI loop works.
///
/// Nothing irreversible happens until the last step: the password (and the
/// file encryption) is applied when setup finishes.
class OnboardingFlow extends StatefulWidget {
  /// Creates the flow.
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.welcome;
  final _name = TextEditingController();
  String? _password;
  VaultSetup? _setup;
  bool _codeSaved = false;
  bool _busy = false;
  NotificationPrefs _prefs = const NotificationPrefs();

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final controller = HomeScope.of(context);
    _name.text = controller.firstName;
    NotificationPrefs.load(controller.settings).then((p) {
      if (mounted) setState(() => _prefs = p);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<_Step> get _steps => [
    _Step.welcome,
    _Step.name,
    _Step.password,
    if (_setup != null) _Step.recovery,
    _Step.vibe,
    _Step.notifications,
    _Step.aiLoop,
  ];

  bool get _canContinue => switch (_step) {
    _Step.name => _name.text.trim().isNotEmpty,
    _Step.recovery => _codeSaved,
    _ => !_busy,
  };

  void _back() {
    final i = _steps.indexOf(_step);
    if (i > 0) setState(() => _step = _steps[i - 1]);
  }

  Future<void> _next() async {
    if (_step == _Step.password) {
      if (_password == null) {
        // Skipped (or cleared): no password.
        setState(() => _setup = null);
      } else if (_setup == null) {
        setState(() => _busy = true);
        final setup = await SessionScope.maybeOf(context)!
            .preparePassword(_password!);
        if (!mounted) return;
        setState(() {
          _busy = false;
          _setup = setup;
          _codeSaved = false;
        });
      }
    }
    if (_step == _Step.aiLoop) return _finish();
    final steps = _steps;
    setState(() => _step = steps[steps.indexOf(_step) + 1]);
  }

  Future<void> _finish() async {
    final session = SessionScope.maybeOf(context)!;
    final controller = HomeScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    await controller.setFirstName(_name.text);
    await _prefs.save(controller.settings);
    await controller.createTutorial(TutorialTexts.of(l10n));
    final setup = _setup;
    // Mark done first: the database is reopened when encryption turns on.
    await session.completeOnboarding();
    if (setup != null) await session.enablePassword(setup);
  }

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final steps = _steps;
    final index = steps.indexOf(_step);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Material (not a decorated box) so list tiles inside show ink.
          child: Material(
            color: colors.panel,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colors.border),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              width: 640,
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Dots(count: steps.length, index: index),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _content(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (index > 0)
                        TextButton(
                          onPressed: _busy ? null : _back,
                          child: Text(l10n.onboardingBack),
                        ),
                      const Spacer(),
                      if (_step == _Step.password && _password == null)
                        TextButton(
                          onPressed: _busy ? null : _next,
                          child: Text(l10n.onboardingSkip),
                        )
                      else
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(140, 48),
                            backgroundColor: colors.accent,
                            foregroundColor: colors.onAccent,
                          ),
                          onPressed: _canContinue && !_busy ? _next : null,
                          child: _busy
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colors.onAccent,
                                  ),
                                )
                              : Text(switch (_step) {
                                  _Step.welcome => l10n.onboardingStart,
                                  _Step.aiLoop => l10n.onboardingFinish,
                                  _ => l10n.onboardingNext,
                                }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (_step) {
      _Step.welcome => _Page(
        hero: const FinchLogo(size: 120),
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
      ),
      _Step.name => _Page(
        title: l10n.onboardingNameTitle,
        body: l10n.onboardingNameBody,
        child: TextField(
          controller: _name,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_canContinue) _next();
          },
          decoration: InputDecoration(labelText: l10n.onboardingNameLabel),
        ),
      ),
      _Step.password => _Page(
        title: l10n.onboardingPasswordTitle,
        body: l10n.onboardingPasswordBody,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordFields(
              onChanged: (p) => setState(() {
                if (p != _password) _setup = null;
                _password = p;
              }),
            ),
            const SizedBox(height: 14),
            const PasswordWarning(),
          ],
        ),
      ),
      _Step.recovery => _Page(
        title: l10n.recoveryTitle,
        child: RecoveryCodeView(
          code: _setup!.recoveryCode,
          saved: _codeSaved,
          onSavedChanged: (v) => setState(() => _codeSaved = v),
        ),
      ),
      _Step.vibe => _Page(
        title: l10n.onboardingVibeTitle,
        body: l10n.onboardingVibeBody,
        child: const _VibePicker(),
      ),
      _Step.notifications => _Page(
        title: l10n.onboardingNotifTitle,
        body: l10n.onboardingNotifBody,
        child: NotificationChoices(
          prefs: _prefs,
          onChanged: (p) => setState(() => _prefs = p),
        ),
      ),
      _Step.aiLoop => _Page(
        title: l10n.onboardingAiTitle,
        body: l10n.onboardingAiBody,
        child: const AiLoopDiagram(),
      ),
    };
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= index ? colors.accent : colors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, this.body, this.hero, this.child});

  final String title;
  final String? body;
  final Widget? hero;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hero != null) ...[Center(child: hero), const SizedBox(height: 20)],
        Text(
          title,
          textAlign: hero != null ? TextAlign.center : TextAlign.start,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            textAlign: hero != null ? TextAlign.center : TextAlign.start,
            style: TextStyle(fontSize: 16, height: 1.45, color: colors.muted),
          ),
        ],
        if (child != null) ...[const SizedBox(height: 22), child!],
      ],
    );
  }
}

/// Light/dark/system and the accent, applied live, plus a tiny preview.
class _VibePicker extends StatelessWidget {
  const _VibePicker();

  @override
  Widget build(BuildContext context) {
    final appearance = AppearanceScope.of(context);
    final settings = appearance.value;
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final accents = AccentChoice.values.where((a) => a != AccentChoice.custom);
    String name(AccentChoice a) => switch (a) {
      AccentChoice.sky => l10n.accentSky,
      AccentChoice.honey => l10n.accentHoney,
      AccentChoice.meadow => l10n.accentMeadow,
      AccentChoice.lilac => l10n.accentLilac,
      AccentChoice.mono => l10n.accentMono,
      AccentChoice.custom => l10n.accentCustom,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ThemeModeSetting>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: ThemeModeSetting.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: ThemeModeSetting.light,
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: ThemeModeSetting.dark,
              label: Text(l10n.themeDark),
            ),
          ],
          selected: {settings.mode},
          onSelectionChanged: (s) {
            if (settings.accent == AccentChoice.custom) {
              appearance.setAccent(AccentChoice.sky);
            }
            appearance.setMode(s.single);
          },
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final a in accents)
              Column(
                children: [
                  Swatch(
                    size: 42,
                    color: colors.isDarkMode
                        ? (accentSpecs[a]!.darkFill ?? accentSpecs[a]!.fill)
                        : accentSpecs[a]!.fill,
                    selected: settings.accent == a,
                    tooltip: name(a),
                    onTap: () => appearance.setAccent(a),
                  ),
                  const SizedBox(height: 4),
                  Text(name(a), style: const TextStyle(fontSize: 13)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 18),
        const _MiniPreview(),
      ],
    );
  }
}

/// A tiny mock of the app in the current colors.
class _MiniPreview extends StatelessWidget {
  const _MiniPreview();

  @override
  Widget build(BuildContext context) {
    final c = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    Widget row(String title, Color check, {bool selected = false}) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? c.accentSoft : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              border: Border.all(color: check, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: l10n.onboardingPreviewLabel,
      child: ExcludeSemantics(
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: c.background,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                width: 120,
                color: c.sidebar,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FinchLogo(size: 24),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.navToday,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: c.accentText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: c.panel,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        row(l10n.onboardingPreviewItem1, c.priorityHigh),
                        row(
                          l10n.onboardingPreviewItem2,
                          c.priorityMedium,
                          selected: true,
                        ),
                        row(l10n.onboardingPreviewItem3, c.muted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Default reminders, the morning digest, (in Settings) quiet hours, and
/// starting with Windows. Used in setup and in Settings › Notifications.
class NotificationChoices extends StatelessWidget {
  /// Creates the choices.
  const NotificationChoices({
    super.key,
    required this.prefs,
    required this.onChanged,
    this.showQuietHours = false,
  });

  /// Current choices.
  final NotificationPrefs prefs;

  /// Called with the changed choices.
  final ValueChanged<NotificationPrefs> onChanged;

  /// Whether to show the quiet-hours rows (Settings only).
  final bool showQuietHours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WayfinchColors.of(context);
    String label(int minutes) => minutes == 0
        ? l10n.reminderNone
        : minutes < 60
        ? l10n.reminderMinutes(minutes)
        : minutes < 1440
        ? l10n.reminderHours(minutes ~/ 60)
        : l10n.reminderDays(minutes ~/ 1440);
    Widget picker(int value, ValueChanged<int> set) => SizedBox(
      width: 200,
      child: DropdownButton<int>(
        isExpanded: true,
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: (v) {
          if (v != null) set(v);
        },
        items: [
          for (final m in NotificationPrefs.reminderChoices)
            DropdownMenuItem(value: m, child: Text(label(m))),
        ],
      ),
    );
    final time = TimeOfDay(hour: prefs.digestHour, minute: prefs.digestMinute);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.notifTaskReminder),
          trailing: picker(
            prefs.taskReminderMinutes,
            (v) => onChanged(prefs.copyWith(taskReminderMinutes: v)),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.notifEventReminder),
          trailing: picker(
            prefs.eventReminderMinutes,
            (v) => onChanged(prefs.copyWith(eventReminderMinutes: v)),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.notifDigest),
          subtitle: Text(l10n.notifDigestBody),
          value: prefs.digestEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(digestEnabled: v)),
        ),
        if (prefs.digestEnabled)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.notifDigestTime),
            trailing: TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  onChanged(
                    prefs.copyWith(
                      digestHour: picked.hour,
                      digestMinute: picked.minute,
                    ),
                  );
                }
              },
              child: Text(time.format(context)),
            ),
          ),
        if (showQuietHours) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.notifQuietHours),
            subtitle: Text(l10n.notifQuietHoursBody),
            value: prefs.quietEnabled,
            onChanged: (v) => onChanged(prefs.copyWith(quietEnabled: v)),
          ),
          if (prefs.quietEnabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.notifQuietFromTo),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TimeButton(
                    minutes: prefs.quietStartMinutes,
                    onPicked: (m) =>
                        onChanged(prefs.copyWith(quietStartMinutes: m)),
                  ),
                  const Text('–'),
                  _TimeButton(
                    minutes: prefs.quietEndMinutes,
                    onPicked: (m) =>
                        onChanged(prefs.copyWith(quietEndMinutes: m)),
                  ),
                ],
              ),
            ),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.notifLaunchAtStartup),
          subtitle: Text(l10n.notifLaunchAtStartupBody),
          value: prefs.launchAtStartup,
          onChanged: (v) => onChanged(prefs.copyWith(launchAtStartup: v)),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.notifTrayNote,
          style: TextStyle(fontSize: 13, color: colors.muted),
        ),
      ],
    );
  }
}

/// A time-of-day button (minutes after midnight) that opens a time picker.
class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.minutes, required this.onPicked});

  final int minutes;
  final ValueChanged<int> onPicked;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return TextButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onPicked(picked.hour * 60 + picked.minute);
      },
      child: Text(time.format(context)),
    );
  }
}

/// Copy → paste → import, as three cards with arrows (setup and Help).
class AiLoopDiagram extends StatelessWidget {
  /// Creates the diagram.
  const AiLoopDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    Widget card(IconData icon, String title, String body) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.subtle,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.accentText, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
          ],
        ),
      ),
    );
    final arrow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.arrow_forward, color: colors.muted),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        card(
          Icons.auto_awesome_outlined,
          l10n.aiLoopStep1Title,
          l10n.aiLoopStep1Body,
        ),
        arrow,
        card(Icons.forum_outlined, l10n.aiLoopStep2Title, l10n.aiLoopStep2Body),
        arrow,
        card(
          Icons.download_outlined,
          l10n.aiLoopStep3Title,
          l10n.aiLoopStep3Body,
        ),
      ],
    );
  }
}
