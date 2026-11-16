import 'package:flutter/material.dart';

import '../../domain/item_rules.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'appearance_section.dart';
import 'backups_section.dart';
import 'general_section.dart';
import 'import_history_section.dart';
import 'notifications_section.dart';
import 'profile_section.dart';

/// Settings. For now: what each of the three prompts does (ask, or a
/// remembered answer).
class SettingsPane extends StatelessWidget {
  /// Creates the pane.
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      children: [
        Text(
          l10n.navSettings,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        const _SettingsCard(children: [ProfileSection()]),
        const SizedBox(height: 20),
        const _SettingsCard(children: [GeneralSection()]),
        const SizedBox(height: 20),
        const _SettingsCard(children: [AppearanceSection()]),
        const SizedBox(height: 20),
        const _SettingsCard(children: [NotificationsSection()]),
        const SizedBox(height: 20),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                l10n.settingsPrompts,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                l10n.settingsPromptsHelp,
                style: TextStyle(color: colors.muted),
              ),
            ),
            for (final kind in PromptKind.values) PromptSettingRow(kind: kind),
          ],
        ),
        const SizedBox(height: 20),
        if (HomeScope.of(context).dailyBackups case final backups?) ...[
          _SettingsCard(children: [BackupsSection(service: backups)]),
          const SizedBox(height: 20),
        ],
        const _SettingsCard(children: [ImportHistorySection()]),
      ],
    );
  }
}

/// A rounded panel holding one settings section.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Material(
          color: colors.panel,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Width of every prompt choice dropdown in Settings.
const promptChoiceWidth = 250.0;

/// One prompt's setting: "Ask me" or a remembered answer.
class PromptSettingRow extends StatelessWidget {
  /// Creates the row for [kind].
  const PromptSettingRow({super.key, required this.kind});

  /// Which prompt.
  final PromptKind kind;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final l10n = AppLocalizations.of(context);
    final (situation, always, never) = switch (kind) {
      PromptKind.pushParentDue => (
        l10n.settingPushParent,
        l10n.choiceAlwaysPushParent,
        null,
      ),
      PromptKind.closeSubtasks => (
        l10n.settingCloseSubtasks,
        l10n.choiceAlwaysCloseSubtasks,
        null,
      ),
      PromptKind.completeParent => (
        l10n.settingCompleteParent,
        l10n.choiceAlwaysCompleteParent,
        l10n.choiceNeverCompleteParent,
      ),
    };
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(situation),
      // A fixed width keeps all three dropdowns lined up, whatever their
      // longest option.
      trailing: SizedBox(
        width: promptChoiceWidth,
        child: DropdownButton<PromptAnswer?>(
          isExpanded: true,
          value: controller.remembered[kind],
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onChanged: (answer) => controller.setRemembered(kind, answer),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.choiceAsk)),
            DropdownMenuItem(
              value: PromptAnswer.confirm,
              child: Text(always, overflow: TextOverflow.ellipsis),
            ),
            if (never != null)
              DropdownMenuItem(
                value: PromptAnswer.cancel,
                child: Text(never, overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }
}
