import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../domain/item_enums.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../prompts/prompts.dart';
import '../theme/tokens.dart';
import '../widgets/celebration.dart';
import 'detail_fields.dart';

/// How long the "Deleted · Undo" message stays up.
const undoDuration = Duration(seconds: 10);

/// The right-hand panel for editing the selected item. Every change saves
/// right away; there's no Save button.
class DetailPanel extends StatelessWidget {
  /// Creates the panel for [item].
  const DetailPanel({super.key, required this.item});

  /// The item being edited.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final controller = HomeScope.of(context);
    final f = Formats.of(context);
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(left: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
              children: [
                Row(
                  children: [
                    TypeToggle(item: item),
                    const Spacer(),
                    IconButton(
                      tooltip: f.l10n.closeDetails,
                      onPressed: () => controller.select(null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ParentLink(item: item),
                const SizedBox(height: 4),
                _TitleField(key: ValueKey('title-${item.id}'), item: item),
                const SizedBox(height: 20),
                FieldGrid(item: item),
                const SizedBox(height: 22),
                SubtasksSection(item: item),
                const SizedBox(height: 22),
                _NotesField(key: ValueKey('notes-${item.id}'), item: item),
              ],
            ),
          ),
          _Actions(item: item),
        ],
      ),
    );
  }
}

/// Saves text edits shortly after typing stops (and when leaving the field).
mixin _DebouncedSave<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  late final TextEditingController text;
  final focus = FocusNode();

  /// Looked up once, so saving on dispose never touches the context.
  late HomeController controller;

  String get initialText;

  void persist(String value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = HomeScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    text = TextEditingController(text: initialText);
    focus.addListener(() {
      if (!focus.hasFocus) _flush();
    });
  }

  void onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), _flush);
  }

  void _flush() {
    _timer?.cancel();
    if (text.text != initialText) persist(text.text);
  }

  @override
  void dispose() {
    _flush();
    _timer?.cancel();
    text.dispose();
    focus.dispose();
    super.dispose();
  }
}

class _TitleField extends StatefulWidget {
  const _TitleField({super.key, required this.item});

  final Item item;

  @override
  State<_TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<_TitleField>
    with _DebouncedSave<_TitleField> {
  @override
  String get initialText => widget.item.title;

  @override
  void persist(String value) {
    final title = value.trim();
    final current = controller.tree[widget.item.id];
    if (title.isEmpty || current == null) return;
    controller.save(current.copyWith(title: title));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Right after "New item": select the title so typing replaces it.
    if (controller.takeTitleFocus(widget.item.id)) {
      text.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.text.length,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Formats.of(context).l10n;
    return TextField(
      controller: text,
      focusNode: focus,
      onChanged: onChanged,
      maxLines: null,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        hintText: l10n.titleHint,
      ),
    );
  }
}

class _NotesField extends StatefulWidget {
  const _NotesField({super.key, required this.item});

  final Item item;

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField>
    with _DebouncedSave<_NotesField> {
  @override
  String get initialText => widget.item.notes ?? '';

  @override
  void persist(String value) {
    final current = controller.tree[widget.item.id];
    if (current == null) return;
    controller.save(current.copyWith(notes: value.isEmpty ? null : value));
  }

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final l10n = Formats.of(context).l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notes,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: text,
          focusNode: focus,
          onChanged: onChanged,
          minLines: 4,
          maxLines: null,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: l10n.notesHint,
            filled: true,
            fillColor: colors.subtle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final controller = HomeScope.of(context);
    final l10n = Formats.of(context).l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Row(
        children: [
          if (item.type == ItemType.task)
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: () async {
                  final celebrate = Celebration.prepare(context);
                  if (await controller.toggleDone(item.id)) celebrate();
                },
                child: Text(item.isDone ? l10n.markAsNotDone : l10n.markAsDone),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: colors.muted,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _delete(context, controller),
              child: Tooltip(
                message: l10n.deleteItem,
                child: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, HomeController controller) async {
    final count = controller.subtaskCount(item.id);
    if (count > 0 && !await confirmDelete(context, count)) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = Formats.of(context).l10n;
    final removed = await controller.delete(item.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.deletedItem(item.title)),
          duration: undoDuration,
          persist: false,
          behavior: SnackBarBehavior.floating,
          width: 420,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => controller.undoDelete(removed),
          ),
        ),
      );
  }
}
