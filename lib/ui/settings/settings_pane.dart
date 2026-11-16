import 'package:flutter/material.dart';

import '../../domain/item_rules.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';

/// Settings. For now: turning the three prompts back on after
/// "Always do this".
class SettingsPane extends StatelessWidget {
  /// Creates the pane.
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final labels = {
      PromptKind.pushParentDue: l10n.settingAskPushParent,
      PromptKind.closeSubtasks: l10n.settingAskCloseSubtasks,
      PromptKind.completeParent: l10n.settingAskCompleteParent,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      children: [
        Text(
          l10n.navSettings,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
                    for (final kind in PromptKind.values)
                      SwitchListTile(
                        title: Text(labels[kind]!),
                        value: controller.askPrompts[kind] ?? true,
                        onChanged: (ask) =>
                            controller.setAskPrompt(kind, ask: ask),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
