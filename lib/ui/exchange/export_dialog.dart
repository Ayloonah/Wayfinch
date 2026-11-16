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

/// Opens Export: the list as JSON, or the events as an .ics file.
Future<void> showExportDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) =>
      HomeScope(controller: HomeScope.of(context), child: const ExportDialog()),
);

/// Opens "Message for your AI": the format rules and the list, to paste
/// into an AI along with the user's own request.
Future<void> showAiMessageDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => HomeScope(
    controller: HomeScope.of(context),
    child: const AiMessageDialog(),
  ),
);

/// The message for your AI: format rules (set by the app) and the list as
/// JSON. The user adds their own request when they paste it.
class AiMessage {
  /// Builds the parts.
  AiMessage({required this.rules, required this.json, required this.l10n});

  /// Format rules (locked).
  final String rules;

  /// "My list".
  final String json;

  /// Strings for the section headings.
  final AppLocalizations l10n;

  /// The full text to paste into an AI.
  String get full =>
      '## ${l10n.exportRulesHeading}\n$rules\n\n'
      '## ${l10n.exportListHeading}\n$json';

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

/// The export formats.
enum ExportFormat {
  /// The list as Wayfinch JSON.
  list,

  /// Events (and optionally tasks) as an iCalendar file.
  calendar,
}

/// Loads and saves the shared "What to include" choices.
mixin _IncludeOptions<T extends StatefulWidget> on State<T> {
  ExportOptions? options;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (options != null) return;
    HomeScope.of(context).loadExportOptions().then((o) {
      if (mounted) setState(() => options = o);
    });
  }

  void setOptions(ExportOptions o) {
    setState(() => options = o);
    HomeScope.of(context).saveExportOptions(o);
  }
}

/// Export: pick a format; for the list, what to include and a preview of
/// the JSON; for the calendar, whether tasks go too. Copy or save.
class ExportDialog extends StatefulWidget {
  /// Creates the dialog.
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog>
    with _IncludeOptions<ExportDialog> {
  ExportFormat _format = ExportFormat.list;
  bool _calendarTasks = false;

  String _content(ExportOptions options) {
    final controller = HomeScope.of(context);
    return switch (_format) {
      ExportFormat.list => controller.exportList(options).json,
      ExportFormat.calendar => controller.exportCalendar(
        includeTasks: _calendarTasks,
      ),
    };
  }

  Future<void> _copy(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportCopiedPlain)));
    await controller.markExported();
  }

  Future<void> _save(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    final (name, label, ext) = switch (_format) {
      ExportFormat.list => ('wayfinch-list.json', 'JSON', 'json'),
      ExportFormat.calendar => ('wayfinch.ics', 'iCalendar', 'ics'),
    };
    final location = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: [
        XTypeGroup(label: label, extensions: [ext]),
      ],
    );
    if (location == null) return;
    var path = location.path;
    if (!path.toLowerCase().endsWith('.$ext')) path = '$path.$ext';
    await File(path).writeAsString(text);
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportSaved)));
    await controller.markExported();
  }

  @override
  Widget build(BuildContext context) {
    final options = this.options;
    if (options == null) return const SizedBox.shrink();
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    final content = _content(options);
    final summary = switch (_format) {
      ExportFormat.list => l10n.exportItemCount(
        controller.exportList(options).itemCount,
      ),
      ExportFormat.calendar => l10n.exportCalendarCount(
        RegExp('BEGIN:VEVENT').allMatches(content).length,
      ),
    };
    return _ExchangeDialog(
      icon: Icons.upload_outlined,
      title: l10n.exportTitle,
      subtitle: l10n.exportSubtitle,
      side: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<ExportFormat>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ExportFormat.list,
                label: Text(l10n.exportFormatList),
              ),
              ButtonSegment(
                value: ExportFormat.calendar,
                label: Text(l10n.exportFormatCalendar),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (s) => setState(() => _format = s.single),
          ),
          const SizedBox(height: 18),
          if (_format == ExportFormat.list)
            _IncludeChecks(options: options, onChanged: setOptions)
          else ...[
            SectionLabel(l10n.exportCalendarOptions),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _calendarTasks,
              onChanged: (v) => setState(() => _calendarTasks = v ?? false),
              title: Text(
                l10n.calendarExportTasks,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(l10n.calendarExportTasksBody),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.calendarExportBody,
              style: TextStyle(color: colors.muted),
            ),
          ],
        ],
      ),
      preview: _CodePanel(
        label: l10n.exportPreview,
        parts: [(null, null, content)],
      ),
      summary: summary,
      onSave: () => _save(content),
      onCopy: () => _copy(content),
    );
  }
}

/// "Message for your AI": what to include, and a preview of exactly what
/// gets copied (format rules + my list).
class AiMessageDialog extends StatefulWidget {
  /// Creates the dialog.
  const AiMessageDialog({super.key});

  @override
  State<AiMessageDialog> createState() => _AiMessageDialogState();
}

class _AiMessageDialogState extends State<AiMessageDialog>
    with _IncludeOptions<AiMessageDialog> {
  AiMessage _message(ExportOptions options) {
    final controller = HomeScope.of(context);
    return AiMessage(
      rules: formatRules(context, controller.now),
      json: controller.exportList(options).json,
      l10n: AppLocalizations.of(context),
    );
  }

  Future<void> _copy(AiMessage message) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    await Clipboard.setData(ClipboardData(text: message.full));
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportCopied)));
    await controller.markExported();
  }

  Future<void> _save(AiMessage message) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    final location = await getSaveLocation(
      suggestedName: 'wayfinch-for-ai.txt',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Text', extensions: ['txt']),
      ],
    );
    if (location == null) return;
    await File(location.path).writeAsString(message.full);
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportSaved)));
    await controller.markExported();
  }

  @override
  Widget build(BuildContext context) {
    final options = this.options;
    if (options == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final controller = HomeScope.of(context);
    final message = _message(options);
    final items = controller.exportList(options).itemCount;
    return _ExchangeDialog(
      icon: Icons.auto_awesome_outlined,
      title: l10n.aiMessageTitle,
      subtitle: l10n.aiMessageSubtitle,
      side: _IncludeChecks(options: options, onChanged: setOptions),
      preview: _CodePanel(
        label: l10n.exportPreview,
        parts: [
          (l10n.exportRulesLabel, const Color(0xFF9FB8FF), message.rules),
          (l10n.exportListHeading, const Color(0xFFFFC078), message.json),
        ],
      ),
      summary: l10n.exportSummary(items, message.wordCount),
      onSave: () => _save(message),
      onCopy: () => _copy(message),
    );
  }
}

/// The shared layout of Export and the message for your AI: header, options
/// on the left, preview on the right, summary + Save + Copy at the bottom.
class _ExchangeDialog extends StatelessWidget {
  const _ExchangeDialog({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.side,
    required this.preview,
    required this.summary,
    required this.onSave,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget side;
  final Widget preview;
  final String summary;
  final VoidCallback onSave;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(icon: icon, title: title, subtitle: subtitle),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 300,
                      child: SingleChildScrollView(child: side),
                    ),
                    const SizedBox(width: 24),
                    Expanded(child: preview),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      summary,
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
                    onPressed: onSave,
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
                    onPressed: onCopy,
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

/// "What to include": open tasks, events, notes, done items.
class _IncludeChecks extends StatelessWidget {
  const _IncludeChecks({required this.options, required this.onChanged});

  final ExportOptions options;
  final ValueChanged<ExportOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final counts = HomeScope.of(context).exportItemCounts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.exportWhatToInclude),
        _Check(
          label: l10n.exportOpenTasks,
          count: counts.openTasks,
          value: options.openTasks,
          onChanged: (v) => onChanged(options.copyWith(openTasks: v)),
        ),
        _Check(
          label: l10n.exportEvents,
          count: counts.events,
          value: options.events,
          onChanged: (v) => onChanged(options.copyWith(events: v)),
        ),
        _Check(
          label: l10n.exportNotes,
          value: options.notes,
          onChanged: (v) => onChanged(options.copyWith(notes: v)),
        ),
        _Check(
          label: l10n.exportDoneItems,
          count: counts.doneItems,
          value: options.doneItems,
          onChanged: (v) => onChanged(options.copyWith(doneItems: v)),
        ),
      ],
    );
  }
}

/// "What gets copied": one or more labeled parts in a dark code panel.
/// A part is (label or null, label color or null, text).
class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.label, required this.parts});

  final String label;
  final List<(String?, Color?, String)> parts;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(
      fontFamily: 'Consolas',
      fontFamilyFallback: ['Courier New', 'monospace'],
      fontSize: 13,
      height: 1.6,
      color: Color(0xFFE6E9EF),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // A code panel stays dark in both themes, like most editors.
              color: const Color(0xFF1B1F27),
              borderRadius: BorderRadius.circular(16),
            ),
            // A plain scrolling column: every part is always built, so
            // select-all and search see the whole text.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (title, color, body) in parts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          SelectableText(body, style: mono),
                        ],
                      ),
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
