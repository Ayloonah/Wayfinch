import 'package:flutter/material.dart';

import '../../domain/item_rules.dart';
import '../../l10n/app_localizations.dart';

/// Shows the shared Confirm / Cancel prompt for [kind], with a
/// "don't ask again" checkbox.
///
/// For [PromptKind.completeParent] the checkbox remembers either answer. For
/// the other prompts it reads "Always do this without asking" and only
/// applies with Confirm (Cancel there stops the whole action, so it is never
/// remembered). Dismissing the dialog counts as Cancel.
Future<PromptResult> showRulePrompt(
  BuildContext context,
  PromptKind kind,
  int count,
) async {
  final l10n = AppLocalizations.of(context);
  final (title, body) = switch (kind) {
    PromptKind.pushParentDue => (
      l10n.promptPushParentTitle,
      l10n.promptPushParentBody(count),
    ),
    PromptKind.closeSubtasks => (
      l10n.promptCloseSubtasksTitle,
      l10n.promptCloseSubtasksBody(count),
    ),
    PromptKind.completeParent => (
      l10n.promptCompleteParentTitle,
      l10n.promptCompleteParentBody,
    ),
  };
  final rememberLabel = kind.canRememberCancel
      ? l10n.promptRememberAnswer
      : l10n.promptAlwaysDoThis;
  var remember = false;
  final result = await showDialog<PromptResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: remember,
              onChanged: (v) => setState(() => remember = v ?? false),
              title: Text(rememberLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              PromptResult(PromptAnswer.cancel, remember: remember),
            ),
            child: Text(l10n.promptCancel),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.pop(
              context,
              PromptResult(PromptAnswer.confirm, remember: remember),
            ),
            child: Text(l10n.promptConfirm),
          ),
        ],
      ),
    ),
  );
  return result ?? PromptResult.dismissed;
}

/// Asks before deleting an item that has [subtaskCount] subtasks.
Future<bool> confirmDelete(BuildContext context, int subtaskCount) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteTitle),
      content: Text(l10n.deleteWithSubtasks(subtaskCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.promptCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return ok ?? false;
}
