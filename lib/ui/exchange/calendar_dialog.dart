import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../domain/ics/ics_import.dart';
import '../../domain/ics/ics_parser.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'dialog_parts.dart';
import 'import_dialog.dart' show importUndoDuration;
import 'import_messages.dart';

/// Opens Calendar: import an .ics file (with a preview) or export one.
/// Shows "Imported N events · Undo" after an import.
Future<void> showCalendarDialog(BuildContext context) async {
  final controller = HomeScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final count = await showDialog<int>(
    context: context,
    builder: (_) =>
        HomeScope(controller: controller, child: const CalendarDialog()),
  );
  if (count == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.calendarImported(count)),
        duration: importUndoDuration,
        persist: false,
        behavior: SnackBarBehavior.floating,
        width: 460,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: controller.undoImport,
        ),
      ),
    );
}

/// The Calendar dialog: a start step (import or export), then a review step
/// for imports.
class CalendarDialog extends StatefulWidget {
  /// Creates the dialog.
  const CalendarDialog({super.key, this.initialText});

  /// An .ics file's text to review right away (tests).
  final String? initialText;

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  IcsReadResult? _read;
  String? _error;
  bool _includePast = false;
  bool _exportTasks = false;
  bool _busy = false;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final text = widget.initialText;
    if (text != null) _load(text);
  }

  void _load(String text) {
    final l10n = AppLocalizations.of(context);
    final read = readIcs(text);
    setState(() {
      if (!read.isCalendar) {
        _error = l10n.calendarNotIcs;
        _read = null;
      } else if (read.events.isEmpty) {
        _error = l10n.calendarNoEvents;
        _read = null;
      } else {
        _error = null;
        _read = read;
      }
    });
  }

  Future<void> _openFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
    );
    if (file == null || !mounted) return;
    String text;
    try {
      text = await File(file.path).readAsString();
    } on FileSystemException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).calendarNotIcs);
      }
      return;
    } on FormatException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).calendarNotIcs);
      }
      return;
    }
    if (mounted) _load(text);
  }

  Future<void> _export() async {
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
        .writeAsString(controller.exportCalendar(includeTasks: _exportTasks));
    messenger.showSnackBar(SnackBar(content: Text(l10n.calendarExported)));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _apply(IcsImportPlan plan) async {
    setState(() => _busy = true);
    final count = await HomeScope.of(context).applyCalendarImport(plan);
    if (mounted) Navigator.pop(context, count);
  }

  @override
  Widget build(BuildContext context) {
    final read = _read;
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: read == null ? 520 : 700,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: read == null ? _startStep() : _reviewStep(read),
        ),
      ),
    );
  }

  Widget _startStep() {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogHeader(
          icon: Icons.event_outlined,
          title: l10n.calendarTitle,
          subtitle: l10n.calendarSubtitle,
        ),
        const SizedBox(height: 20),
        _Card(
          icon: Icons.download_outlined,
          title: l10n.calendarImportTitle,
          body: l10n.calendarImportBody,
          action: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onAccent,
            ),
            onPressed: _openFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(l10n.calendarOpenFile),
          ),
          extra: _error == null
              ? null
              : Text(
                  _error!,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.warningText,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        _Card(
          icon: Icons.upload_outlined,
          title: l10n.calendarExportTitle,
          body: l10n.calendarExportBody,
          action: OutlinedButton.icon(
            onPressed: _export,
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.calendarSaveFile),
          ),
          extra: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            value: _exportTasks,
            onChanged: (v) => setState(() => _exportTasks = v ?? false),
            title: Text(l10n.calendarExportTasks),
            subtitle: Text(l10n.calendarExportTasksBody),
          ),
        ),
      ],
    );
  }

  Widget _reviewStep(IcsReadResult read) {
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
            TextButton(
              onPressed: () => setState(() => _read = null),
              child: Text(l10n.importBack),
            ),
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

/// One option on the start step: icon, title, explanation, a button and
/// optional extra content underneath.
class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget action;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.accentText),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(body, style: TextStyle(color: colors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              action,
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.only(left: 36), child: extra!),
          ],
        ],
      ),
    );
  }
}
