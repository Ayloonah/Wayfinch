import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/exchange/exchange_model.dart';
import '../../domain/exchange/exchange_parser.dart';
import '../../domain/exchange/import_plan.dart';
import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../list/item_row.dart' show indentFor;
import '../theme/tokens.dart';
import 'dialog_parts.dart';
import 'import_messages.dart';

/// How long the "Imported · Undo" message stays up.
const importUndoDuration = Duration(seconds: 15);

/// Opens Import: paste (or open) the AI's reply, review, then Add or
/// Replace. Shows "Imported N changes · Undo" afterwards.
Future<void> showImportDialog(BuildContext context) async {
  final controller = HomeScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final count = await showDialog<int>(
    context: context,
    builder: (_) =>
        HomeScope(controller: controller, child: const ImportDialog()),
  );
  if (count == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.importDone(count)),
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

/// The Import dialog (paste step, then review step).
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

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _check() {
    final outcome = parseExchange(_text.text);
    setState(() {
      _errors = outcome.errors;
      _doc = outcome.document;
      _keep.clear();
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    setState(() {
      _text.text = text;
      _errors = const [];
    });
  }

  Future<void> _openFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Wayfinch', extensions: ['json', 'txt']),
      ],
    );
    if (file == null) return;
    final text = await File(file.path).readAsString();
    setState(() {
      _text.text = text;
      _errors = const [];
    });
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
    if (mounted) Navigator.pop(context, count);
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: doc == null ? _pasteStep() : _reviewStep(doc),
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
          children: [
            OutlinedButton.icon(
              onPressed: _paste,
              icon: const Icon(Icons.content_paste),
              label: Text(l10n.importPaste),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _openFile,
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(l10n.importOpenFile),
            ),
            const Spacer(),
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
            _CountChip(
              text: l10n.importNewCount(plan.added.length),
              kind: _Kind.added,
            ),
            if (_mode == ImportMode.replace) ...[
              _CountChip(
                text: l10n.importChangedCount(plan.changed.length),
                kind: _Kind.changed,
              ),
              _CountChip(
                text: l10n.importRemovedCount(removed.length),
                kind: _Kind.removed,
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
                        _ChangeRow(
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

enum _Kind { added, changed, removed }

(Color, Color) _kindColors(_Kind kind, WayfinchColors c) => switch (kind) {
  _Kind.added => (
    c.isDarkMode ? const Color(0xFF1E3A26) : const Color(0xFFEBF7EE),
    c.isDarkMode ? const Color(0xFF8CE99A) : const Color(0xFF22662F),
  ),
  _Kind.changed => (c.accentSoft, c.accentText),
  _Kind.removed => (c.warningBackground, c.warningText),
};

class _CountChip extends StatelessWidget {
  const _CountChip({required this.text, required this.kind});

  final String text;
  final _Kind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _kindColors(kind, WayfinchColors.of(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({
    required this.change,
    required this.detail,
    required this.kept,
    this.onToggleKeep,
  });

  final PlannedChange change;
  final String detail;
  final bool kept;
  final VoidCallback? onToggleKeep;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final (kind, label) = switch (change) {
      AddedItem() => (_Kind.added, l10n.importBadgeNew),
      ChangedItem() => (_Kind.changed, l10n.importBadgeChanged),
      RemovedItem() => (_Kind.removed, l10n.importBadgeRemoved),
    };
    final (bg, fg) = _kindColors(kind, colors);
    return Opacity(
      opacity: kept ? 0.55 : 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(indentFor(change.depth) - 4, 6, 12, 6),
        child: Row(
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kept ? l10n.importBadgeKept : label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                change.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (detail.isNotEmpty)
              Flexible(
                child: Text(
                  detail,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.muted,
                  ),
                ),
              ),
            if (onToggleKeep != null) ...[
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                onPressed: onToggleKeep,
                child: Text(kept ? l10n.importRemoveAnyway : l10n.importKeep),
              ),
            ],
          ],
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
