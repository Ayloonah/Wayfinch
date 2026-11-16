import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/exchange/exchange_export.dart';
import '../../domain/exchange/exchange_model.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'dialog_parts.dart';

/// Opens "Export for AI".
Future<void> showExportDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) =>
      HomeScope(controller: HomeScope.of(context), child: const ExportDialog()),
);

/// The text that gets copied: format rules (set by the app), the user's
/// instructions, and the list as JSON.
class ExportText {
  /// Builds the parts.
  ExportText({
    required this.rules,
    required this.instructions,
    required this.json,
    required this.l10n,
  });

  /// Format rules (locked).
  final String rules;

  /// The user's own instructions (may be empty).
  final String instructions;

  /// "My list".
  final String json;

  /// Strings for the section headings.
  final AppLocalizations l10n;

  /// The full block to paste into an AI.
  String get full {
    final parts = [
      '## ${l10n.exportRulesHeading}\n$rules',
      if (instructions.trim().isNotEmpty)
        '## ${l10n.exportInstructionsHeading}\n${instructions.trim()}',
      '## ${l10n.exportListHeading}\n$json',
    ];
    return parts.join('\n\n');
  }

  /// Rough word count, for "about N words".
  int get wordCount =>
      full.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}

/// The format rules the AI receives, with today's date so it can plan.
String formatRules(BuildContext context, DateTime now) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final today =
      '${DateFormat('yyyy-MM-dd').format(now)} '
      '(${DateFormat.EEEE(locale).format(now)})';
  return AppLocalizations.of(context).exportRules(today, exchangeSkeleton);
}

/// "Export for AI": what to include, my instructions, and a preview of
/// exactly what gets copied.
class ExportDialog extends StatefulWidget {
  /// Creates the dialog.
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportOptions? _options;
  final _instructions = TextEditingController();
  Timer? _saveTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_options != null) return;
    final controller = HomeScope.of(context);
    controller.loadExportOptions().then((o) {
      if (mounted) setState(() => _options = o);
    });
    controller.loadInstructions().then((text) {
      if (mounted) setState(() => _instructions.text = text);
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _instructions.dispose();
    super.dispose();
  }

  void _setOptions(ExportOptions o) {
    setState(() => _options = o);
    HomeScope.of(context).saveExportOptions(o);
  }

  void _onInstructions(String text) {
    setState(() {});
    final controller = HomeScope.of(context);
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 400),
      () => controller.saveInstructions(text),
    );
  }

  ExportText _text(ExportOptions options) {
    final controller = HomeScope.of(context);
    return ExportText(
      rules: formatRules(context, controller.now),
      instructions: _instructions.text,
      json: controller.exportList(options).json,
      l10n: AppLocalizations.of(context),
    );
  }

  Future<void> _copy(ExportText text) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: text.full));
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportCopied)));
  }

  Future<void> _save(ExportText text) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final location = await getSaveLocation(
      suggestedName: 'wayfinch-for-ai.txt',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Text', extensions: ['txt']),
      ],
    );
    if (location == null) return;
    await File(location.path).writeAsString(text.full);
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    if (options == null) return const SizedBox.shrink();
    final controller = HomeScope.of(context);
    final counts = controller.exportItemCounts;
    final export = controller.exportList(options);
    final text = _text(options);
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: Icons.auto_awesome_outlined,
                title: l10n.exportTitle,
                subtitle: l10n.exportSubtitle,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 330,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionLabel(l10n.exportWhatToInclude),
                          _Check(
                            label: l10n.exportOpenTasks,
                            count: counts.openTasks,
                            value: options.openTasks,
                            onChanged: (v) =>
                                _setOptions(options.copyWith(openTasks: v)),
                          ),
                          _Check(
                            label: l10n.exportEvents,
                            count: counts.events,
                            value: options.events,
                            onChanged: (v) =>
                                _setOptions(options.copyWith(events: v)),
                          ),
                          _Check(
                            label: l10n.exportNotes,
                            value: options.notes,
                            onChanged: (v) =>
                                _setOptions(options.copyWith(notes: v)),
                          ),
                          _Check(
                            label: l10n.exportDoneItems,
                            count: counts.doneItems,
                            value: options.doneItems,
                            onChanged: (v) =>
                                _setOptions(options.copyWith(doneItems: v)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SectionLabel(
                                  l10n.exportInstructionsHeading,
                                ),
                              ),
                              Text(
                                l10n.exportInstructionsSaved,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.muted,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TextField(
                              controller: _instructions,
                              onChanged: _onInstructions,
                              expands: true,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                              decoration: InputDecoration(
                                hintText: l10n.exportInstructionsHint,
                                hintMaxLines: 6,
                                filled: true,
                                fillColor: colors.subtle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: colors.border),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(child: _Preview(text: text)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.exportSummary(export.itemCount, text.wordCount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.muted,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () => _save(text),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.exportSaveFile),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    onPressed: () => _copy(text),
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(l10n.exportCopy),
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

/// "What gets copied": the three parts, color-coded, in a dark code panel.
class _Preview extends StatelessWidget {
  const _Preview({required this.text});

  final ExportText text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const mono = TextStyle(
      fontFamily: 'Consolas',
      fontFamilyFallback: ['Courier New', 'monospace'],
      fontSize: 13,
      height: 1.6,
      color: Color(0xFFE6E9EF),
    );
    Widget part(String label, Color color, String body, {IconData? icon}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 13, color: color),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SelectableText(body, style: mono),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.exportPreview),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // A code panel stays dark in both themes, like most editors.
              color: const Color(0xFF1B1F27),
              borderRadius: BorderRadius.circular(16),
            ),
            // A plain scrolling column: all three parts are always built,
            // so select-all and search see the whole text.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  part(
                    l10n.exportRulesLabel,
                    const Color(0xFF9FB8FF),
                    text.rules,
                    icon: Icons.lock_outline,
                  ),
                  if (text.instructions.trim().isNotEmpty)
                    part(
                      l10n.exportInstructionsHeading,
                      const Color(0xFF8CE99A),
                      text.instructions.trim(),
                    ),
                  part(
                    l10n.exportListHeading,
                    const Color(0xFFFFC078),
                    text.json,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.label,
    required this.value,
    required this.onChanged,
    this.count,
  });

  final String label;
  final bool value;
  final int? count;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          children: [
            if (count != null)
              TextSpan(
                text: '  ($count)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
