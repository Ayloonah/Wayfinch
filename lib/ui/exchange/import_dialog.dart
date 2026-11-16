import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/exchange/exchange_model.dart';
import '../../domain/exchange/exchange_parser.dart';
import '../../domain/exchange/import_plan.dart';
import '../../domain/ics/ics_parser.dart';
import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'calendar_dialog.dart';
import 'dialog_parts.dart';
import 'export_dialog.dart' show showAiMessageDialog;
import 'import_messages.dart';

/// How long the "Imported · Undo" message stays up.
const importUndoDuration = Duration(seconds: 15);

/// Opens Import: paste (or open) the AI's reply, review, then Add or
/// Replace. Shows "Imported N changes · Undo" afterwards.
Future<void> showImportDialog(BuildContext context) async {
  final controller = HomeScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<ImportOutcome>(
    context: context,
    builder: (_) =>
        HomeScope(controller: controller, child: const ImportDialog()),
  );
  if (result == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          result.calendar
              ? l10n.calendarImported(result.count)
              : l10n.importDone(result.count),
        ),
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

/// What an import did: how many items it touched, and whether it was a
/// calendar (.ics) import.
typedef ImportOutcome = ({int count, bool calendar});

/// The Import dialog (paste step, then review step). An iCalendar file
/// (opened or pasted) goes to the calendar review instead.
class ImportDialog extends StatefulWidget {
  /// Creates the dialog.
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _text = TextEditingController();
  List<ExchangeError> _errors = const [];
  ExchangeDocument? _doc;
  ImportMode _mode = ImportMode.replace;
  final Set<String> _keep = {};
  bool _busy = false;
  IcsReadResult? _calendar;
  String? _calendarError;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _check() {
    if (looksLikeIcs(_text.text)) {
      final read = readIcs(_text.text);
      final l10n = AppLocalizations.of(context);
      setState(() {
        _calendar = read.events.isEmpty ? null : read;
        _calendarError = read.events.isEmpty ? l10n.calendarNoEvents : null;
        _errors = const [];
      });
      return;
    }
    final outcome = parseExchange(_text.text);
    setState(() {
      _errors = outcome.errors;
      _doc = outcome.document;
      _calendarError = null;
      _keep.clear();
    });
  }

  Future<void> _openCalendar() => _openFile(calendarOnly: true);

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    setState(() {
      _text.text = text;
      _errors = const [];
    });
  }

  Future<void> _openFile({bool calendarOnly = false}) async {
    final file = await openFile(
      acceptedTypeGroups: [
        if (!calendarOnly)
          const XTypeGroup(label: 'Wayfinch', extensions: ['json', 'txt']),
        const XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
    );
    if (file == null || !mounted) return;
    String text;
    try {
      text = await File(file.path).readAsString();
    } on FileSystemException {
      return;
    } on FormatException {
      return;
    }
    if (!mounted) return;
    setState(() {
      _text.text = text;
      _errors = const [];
      _calendarError = null;
    });
    // A calendar file goes straight to its review.
    if (looksLikeIcs(text)) {
      _check();
    } else if (calendarOnly) {
      setState(
        () => _calendarError = AppLocalizations.of(context).calendarNotIcs,
      );
    }
  }

  Future<void> _undoLast() async {
    final controller = HomeScope.of(context);
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importUndoTitle),
        content: Text(l10n.importUndoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.promptCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.importUndoConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await controller.undoImport();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _apply(ImportPlan plan) async {
    setState(() => _busy = true);
    final count = await HomeScope.of(context).applyImport(plan, keep: _keep);
    if (mounted) {
      Navigator.pop<ImportOutcome>(context, (count: count, calendar: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    final calendar = _calendar;
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: calendar != null
              ? CalendarImportReview(
                  read: calendar,
                  onBack: () => setState(() => _calendar = null),
                  onApplied: (count) => Navigator.pop<ImportOutcome>(context, (
                    count: count,
                    calendar: true,
                  )),
                )
              : doc == null
              ? _pasteStep()
              : _reviewStep(doc),
        ),
      ),
    );
  }

  Widget _pasteStep() {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final f = Formats.of(context);
    final messages = ImportMessages.of(context);
    final last = controller.lastImport;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogHeader(
          icon: Icons.download_outlined,
          title: l10n.importTitle,
          subtitle: l10n.importSubtitle,
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  // What to send the AI (rules + list), before pasting its
                  // reply here.
                  FilledButton.tonalIcon(
                    onPressed: () => showAiMessageDialog(context),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: Text(l10n.aiMessageButton),
                  ),
                  OutlinedButton.icon(
                    onPressed: _paste,
                    icon: const Icon(Icons.content_paste),
                    label: Text(l10n.importPaste),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(l10n.importOpenFile),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openCalendar,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(l10n.importCalendar),
                  ),
                ],
              ),
            ),
            if (last != null)
              TextButton.icon(
                onPressed: _undoLast,
                icon: const Icon(Icons.undo),
                label: Text(
                  l10n.importUndoLast(
                    f.l10n.dateWithTime(
                      f.relativeDay(last.createdAt, DateTime.now()),
                      f.time(last.createdAt),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _text,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            onChanged: (_) => setState(() => _errors = const []),
            style: const TextStyle(
              fontFamily: 'Consolas',
              fontFamilyFallback: ['Courier New', 'monospace'],
              fontSize: 13,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: exchangeSkeleton,
              filled: true,
              fillColor: colors.subtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
        ),
        if (_errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ErrorBox(messages: [for (final e in _errors) messages.error(e)]),
        ],
        if (_calendarError != null) ...[
          const SizedBox(height: 12),
          Text(
            _calendarError!,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.warningText,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.promptCancel),
            ),
            const SizedBox(width: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
              ),
              onPressed: _text.text.trim().isEmpty ? null : _check,
              child: Text(l10n.importReview),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewStep(ExchangeDocument doc) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final messages = ImportMessages.of(context);
    final plan = controller.planImportOf(doc, _mode);
    final removed = plan.removed.where((r) => !_keep.contains(r.item.id));
    final count = plan.countFor(_keep);
    final canImport = plan.errors.isEmpty && count > 0 && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogHeader(
          title: l10n.importReviewTitle,
          subtitle: l10n.importValid,
          subtitleIcon: Icon(Icons.check, size: 16, color: colors.accentText),
        ),
        const SizedBox(height: 16),
        SectionLabel(l10n.importHow),
        Row(
          children: [
            Expanded(
              child: _ModeCard(
                title: l10n.importAdd,
                body: l10n.importAddBody,
                selected: _mode == ImportMode.add,
                onTap: () => setState(() => _mode = ImportMode.add),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeCard(
                title: l10n.importReplace,
                body: l10n.importReplaceBody,
                selected: _mode == ImportMode.replace,
                onTap: () => setState(() => _mode = ImportMode.replace),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CountChip(
              text: l10n.importNewCount(plan.added.length),
              kind: ChangeKind.added,
            ),
            if (_mode == ImportMode.replace) ...[
              CountChip(
                text: l10n.importChangedCount(plan.changed.length),
                kind: ChangeKind.changed,
              ),
              CountChip(
                text: l10n.importRemovedCount(removed.length),
                kind: ChangeKind.removed,
              ),
            ],
            if (_mode == ImportMode.replace && plan.doneUntouched > 0)
              Text(
                l10n.importDoneUntouched(plan.doneUntouched),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
          ],
        ),
        if (removed.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Warning(text: l10n.importRemovedWarning(removed.length)),
        ],
        if (plan.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ErrorBox(messages: [for (final e in plan.errors) messages.error(e)]),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: plan.changes.isEmpty
                ? Center(
                    child: Text(
                      l10n.importNothing,
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
                          kept:
                              change is RemovedItem &&
                              _keep.contains(change.item.id),
                          onToggleKeep: change is RemovedItem
                              ? () => setState(() {
                                  if (!_keep.remove(change.item.id)) {
                                    _keep.add(change.item.id);
                                  }
                                })
                              : null,
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
              onPressed: () => setState(() => _doc = null),
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
              child: Text(l10n.importApply(count)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.accentSoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? colors.accent : colors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? colors.accentText : colors.muted,
                ),
                const SizedBox(width: 10),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        border: Border.all(color: colors.warningBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: colors.warningText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        border: Border.all(color: colors.warningBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.warningText),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.importErrorsTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              for (final m in messages)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• $m'),
                ),
              const SizedBox(height: 6),
              Text(
                l10n.importErrorsTip,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
