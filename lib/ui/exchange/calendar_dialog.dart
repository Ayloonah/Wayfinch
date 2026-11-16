import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../domain/ics/ics_import.dart';
import '../../domain/ics/ics_parser.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'dialog_parts.dart';
import 'import_messages.dart';

/// Whether [text] is an iCalendar file (so Import treats it as a calendar).
bool looksLikeIcs(String text) =>
    text.trimLeft().toUpperCase().startsWith('BEGIN:VCALENDAR');

/// Opens "Export to calendar": saves the events (optionally open tasks too)
/// as an .ics file.
Future<void> showCalendarExportDialog(BuildContext context) {
  final controller = HomeScope.of(context);
  return showDialog<void>(
    context: context,
    builder: (_) =>
        HomeScope(controller: controller, child: const CalendarExportDialog()),
  );
}

/// The "Export to calendar" dialog.
class CalendarExportDialog extends StatefulWidget {
  /// Creates the dialog.
  const CalendarExportDialog({super.key});

  @override
  State<CalendarExportDialog> createState() => _CalendarExportDialogState();
}

class _CalendarExportDialogState extends State<CalendarExportDialog> {
  bool _tasks = false;

  Future<void> _save() async {
    final controller = HomeScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final location = await getSaveLocation(
      suggestedName: 'wayfinch.ics',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
    );
    if (location == null) return;
    var path = location.path;
    if (!path.toLowerCase().endsWith('.ics')) path = '$path.ics';
    await File(path)
        .writeAsString(controller.exportCalendar(includeTasks: _tasks));
    messenger.showSnackBar(SnackBar(content: Text(l10n.calendarExported)));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: Icons.event_outlined,
                title: l10n.calendarExportTitle,
                subtitle: l10n.calendarExportBody,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _tasks,
                onChanged: (v) => setState(() => _tasks = v ?? false),
                title: Text(l10n.calendarExportTasks),
                subtitle: Text(l10n.calendarExportTasksBody),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.promptCancel),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    onPressed: _save,
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.calendarSaveFile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The review step of a calendar import, shown inside the Import dialog:
/// counts, "Include past events", the list of changes, Back and Import.
class CalendarImportReview extends StatefulWidget {
  /// Creates the review of [read].
  const CalendarImportReview({
    super.key,
    required this.read,
    required this.onBack,
    required this.onApplied,
  });

  /// The calendar file's events.
  final IcsReadResult read;

  /// Goes back to the paste step.
  final VoidCallback onBack;

  /// Called with the number of events added or updated.
  final ValueChanged<int> onApplied;

  @override
  State<CalendarImportReview> createState() => _CalendarImportReviewState();
}

class _CalendarImportReviewState extends State<CalendarImportReview> {
  bool _includePast = false;
  bool _busy = false;

  Future<void> _apply(IcsImportPlan plan) async {
    setState(() => _busy = true);
    final count = await HomeScope.of(context).applyCalendarImport(plan);
    if (mounted) widget.onApplied(count);
  }

  @override
  Widget build(BuildContext context) {
    final read = widget.read;
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final messages = ImportMessages.of(context);
    final plan = controller.planCalendarImport(
      read.events,
      includePast: _includePast,
      untitled: l10n.calendarUntitled,
    );
    final canImport = plan.count > 0 && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogHeader(
          icon: Icons.event_outlined,
          title: l10n.calendarReviewTitle,
          subtitle: l10n.calendarReviewSubtitle(read.events.length),
          subtitleIcon: Icon(Icons.check, size: 16, color: colors.accentText),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CountChip(
              text: l10n.importNewCount(plan.added.length),
              kind: ChangeKind.added,
            ),
            CountChip(
              text: l10n.calendarUpdatedCount(plan.updated.length),
              kind: ChangeKind.changed,
            ),
            if (plan.unchangedCount > 0)
              Text(
                l10n.calendarUnchanged(plan.unchangedCount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          value: _includePast,
          onChanged: (v) => setState(() => _includePast = v ?? false),
          title: Text(l10n.calendarIncludePast),
          subtitle: _includePast || plan.pastCount == 0
              ? null
              : Text(l10n.calendarPastLeftOut(plan.pastCount)),
        ),
        if (read.skipped > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.calendarSkipped(read.skipped),
              style: TextStyle(color: colors.muted),
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: plan.changes.isEmpty
                ? Center(
                    child: Text(
                      l10n.calendarNothing,
                      style: TextStyle(color: colors.muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(6),
                    children: [
                      for (final change in plan.changes)
                        ChangeRow(
                          change: change,
                          detail: messages.detail(change),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 18, color: colors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.importBackupNote,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
            ),
            TextButton(onPressed: widget.onBack, child: Text(l10n.importBack)),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
              ),
              onPressed: canImport ? () => _apply(plan) : null,
              child: Text(l10n.importApply(plan.count)),
            ),
          ],
        ),
      ],
    );
  }
}
