import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../domain/item_enums.dart';
import '../../domain/recurrence.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../list/item_row.dart' show TagChip;
import '../theme/tokens.dart';
import 'date_time_picker.dart';

/// Task / Event switch.
class TypeToggle extends StatelessWidget {
  /// Creates the toggle for [item].
  const TypeToggle({super.key, required this.item});

  /// The item being edited.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final l10n = Formats.of(context).l10n;
    return SegmentedButton<ItemType>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: ItemType.task, label: Text(l10n.typeTask)),
        ButtonSegment(value: ItemType.event, label: Text(l10n.typeEvent)),
      ],
      selected: {item.type},
      onSelectionChanged: (s) => controller.setType(item, s.single),
    );
  }
}

/// The label/value grid: when, priority, tags, repeat.
class FieldGrid extends StatelessWidget {
  /// Creates the grid for [item].
  const FieldGrid({super.key, required this.item});

  /// The item being edited.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final l10n = Formats.of(context).l10n;
    return Column(
      children: [
        if (item.isTask)
          _FieldRow(
            label: l10n.fieldDue,
            child: _DueField(item: item),
          )
        else ...[
          _FieldRow(
            label: l10n.fieldStart,
            child: _EventTimeField(item: item, isStart: true),
          ),
          _FieldRow(
            label: l10n.fieldEnd,
            child: _EventTimeField(item: item, isStart: false),
          ),
        ],
        _FieldRow(
          label: l10n.fieldPriority,
          child: _PriorityField(item: item),
        ),
        _FieldRow(
          label: l10n.fieldTags,
          child: _TagsField(item: item),
        ),
        _FieldRow(
          label: l10n.fieldRepeat,
          child: _RepeatField(item: item),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.muted,
              ),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ],
      ),
    );
  }
}

/// A compact text button used for field values.
class _ValueButton extends StatelessWidget {
  const _ValueButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, 36),
      foregroundColor: WayfinchColors.of(context).text,
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}

class _DueField extends StatelessWidget {
  const _DueField({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final f = Formats.of(context);
    final due = item.due;
    Future<void> pick() async {
      final choice = await showDateTimePicker(
        context,
        initial: due,
        initialHasTime: item.dueHasTime,
      );
      if (choice != null) {
        await controller.setDue(item.id, choice.value, hasTime: choice.hasTime);
      }
    }

    if (due == null) {
      return _ValueButton(label: f.l10n.noDueDate, onPressed: pick);
    }
    final label = item.dueHasTime
        ? f.l10n.dateDotTime(f.shortDate(due), f.time(due))
        : f.shortDate(due);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _ValueButton(label: label, onPressed: pick),
        ),
        IconButton(
          tooltip: f.l10n.clearDate,
          iconSize: 18,
          onPressed: () => controller.setDue(item.id, null, hasTime: false),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _EventTimeField extends StatelessWidget {
  const _EventTimeField({required this.item, required this.isStart});

  final Item item;
  final bool isStart;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final f = Formats.of(context);
    final value = (isStart ? item.start : item.end) ?? DateTime.now();

    Future<void> pick() async {
      final choice = await showDateTimePicker(
        context,
        initial: value,
        timeRequired: true,
      );
      if (choice == null) return;
      final next = choice.value;
      final start = item.start ?? next;
      final end = item.end ?? next;
      if (isStart) {
        // Moving the start keeps the event's length.
        final length = end.difference(start);
        await controller.save(
          item.copyWith(start: next, end: next.add(length)),
        );
      } else {
        await controller.save(
          item.copyWith(end: next.isBefore(start) ? start : next),
        );
      }
    }

    return _ValueButton(
      label: f.l10n.dateDotTime(f.shortDate(value), f.time(value)),
      onPressed: pick,
    );
  }
}

class _PriorityField extends StatelessWidget {
  const _PriorityField({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    return PopupMenuButton<Priority>(
      tooltip: f.l10n.fieldPriority,
      initialValue: item.priority,
      onSelected: (p) => controller.save(item.copyWith(priority: p)),
      itemBuilder: (context) => [
        for (final p in Priority.values.reversed)
          PopupMenuItem(
            value: p,
            child: _PriorityLabel(priority: p),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
          child: _PriorityLabel(priority: item.priority),
        ),
      ),
    );
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final color = colors.priorityColor(priority);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          color == null ? Icons.outlined_flag : Icons.flag,
          size: 16,
          color: color ?? colors.muted,
        ),
        const SizedBox(width: 8),
        Text(Formats.of(context).priority(priority)),
      ],
    );
  }
}

class _TagsField extends StatefulWidget {
  const _TagsField({required this.item});

  final Item item;

  @override
  State<_TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<_TagsField> {
  bool _adding = false;
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = Formats.of(context).l10n;
    final tags = widget.item.tagIds
        .map((id) => controller.tagsById[id])
        .whereType<Tag>();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tag in tags)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => controller.removeTag(widget.item, tag.id),
            child: Tooltip(
              message: l10n.removeTag(tag.name),
              child: TagChip(name: tag.name, color: Color(tag.color)),
            ),
          ),
        if (_adding)
          SizedBox(
            width: 140,
            child: TextField(
              controller: _text,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.tagHint,
              ),
              onSubmitted: (name) async {
                setState(() => _adding = false);
                _text.clear();
                await controller.addTag(widget.item, name);
              },
              onTapOutside: (_) => setState(() => _adding = false),
            ),
          )
        else
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: colors.muted,
              side: BorderSide(color: colors.border, width: 1.5),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => setState(() => _adding = true),
            child: Text(l10n.addTag),
          ),
      ],
    );
  }
}

class _RepeatField extends StatelessWidget {
  const _RepeatField({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final current = RepeatPreset.fromRrule(item.recurrence);
    final isCustom = item.isRecurring && current == null;
    return PopupMenuButton<String>(
      tooltip: f.l10n.fieldRepeat,
      onSelected: (rrule) => controller.save(
        item.copyWith(recurrence: rrule.isEmpty ? null : rrule),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: '', child: Text(f.l10n.repeatNone)),
        for (final preset in RepeatPreset.values)
          PopupMenuItem(
            value: preset.rrule,
            child: Text(f.repeat(preset.rrule)),
          ),
        if (isCustom)
          PopupMenuItem(
            value: item.recurrence!,
            child: Text(f.l10n.repeatCustom),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          f.repeat(item.recurrence),
          style: TextStyle(
            fontSize: 15,
            fontWeight: item.isRecurring ? FontWeight.w700 : FontWeight.w600,
            color: item.isRecurring ? colors.text : colors.muted,
          ),
        ),
      ),
    );
  }
}

/// Subtask progress bar and the "+ Add subtask" button, which creates a
/// subtask and opens it right away.
class SubtasksSection extends StatelessWidget {
  /// Creates the section for [item].
  const SubtasksSection({super.key, required this.item});

  /// The parent item.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = Formats.of(context).l10n;
    final subtasks = controller.tree.childrenOf(item.id).where((c) => c.isTask);
    final total = subtasks.length;
    final done = subtasks.where((c) => c.isDone).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.subtasks,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (total > 0)
              Text(
                l10n.subtasksProgress(done, total),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.muted,
                ),
              ),
          ],
        ),
        if (total > 0) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 10,
              backgroundColor: colors.subtle,
              color: colors.accent,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: colors.accentSoft,
              foregroundColor: colors.accentText,
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            onPressed: () => controller.addSubtask(item.id, l10n.newItemTitle),
            child: Text(l10n.addSubtask),
          ),
        ),
      ],
    );
  }
}

/// "↑ Parent title" link at the top of a subtask's details.
class ParentLink extends StatelessWidget {
  /// Creates the link for [item]'s parent.
  const ParentLink({super.key, required this.item});

  /// The subtask being edited.
  final Item item;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final parent = controller.tree[item.parentId];
    if (parent == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: colors.muted,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 32),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        onPressed: () => controller.select(parent.id),
        icon: const Icon(Icons.arrow_upward, size: 16),
        label: Text(
          Formats.of(context).l10n.subtaskOf(parent.title),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
