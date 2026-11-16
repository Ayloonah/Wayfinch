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
