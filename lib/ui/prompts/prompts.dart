import 'package:flutter/material.dart';

import '../../domain/item_rules.dart';
import '../../l10n/app_localizations.dart';

/// Shows the shared Confirm / Cancel / Always do this prompt for [kind].
///
/// Dismissing the dialog counts as Cancel.
Future<PromptAnswer> showRulePrompt(
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
  final answer = await showDialog<PromptAnswer>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, PromptAnswer.always),
          child: Text(l10n.promptAlways),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, PromptAnswer.cancel),
          child: Text(l10n.promptCancel),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context, PromptAnswer.confirm),
          child: Text(l10n.promptConfirm),
        ),
      ],
    ),
  );
  return answer ?? PromptAnswer.cancel;
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
