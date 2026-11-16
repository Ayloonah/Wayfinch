import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/item.dart';
import '../../domain/item_enums.dart';
import '../../domain/views.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import '../widgets/celebration.dart';

/// Full-width indentation steps for the first levels; deeper levels keep
/// indenting with a smaller step so the page doesn't run out of room.
const fullIndentLevels = 4;

/// Left padding for a row at [depth]: 34 px per level for the first
/// [fullIndentLevels], then 16 px per extra level.
double indentFor(int depth) =>
    16.0 +
    math.min(depth, fullIndentLevels) * 34 +
    math.max(0, depth - fullIndentLevels) * 16;

/// One task or event in a list.
class ItemRow extends StatefulWidget {
  /// Creates a row for [entry].
  const ItemRow({super.key, required this.entry});

  /// What to show.
  final ItemEntry entry;

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = Formats.of(context).l10n;
    final entry = widget.entry;
    final item = entry.item;
    final selected = controller.selected?.id == item.id;
    final finished = item.isDone || item.isEnded(controller.now);
    final showAdd = !finished && (_hovered || selected);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: selected ? colors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => controller.select(item.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: EdgeInsets.fromLTRB(indentFor(entry.depth), 8, 8, 8),
              child: Row(
                children: [
                  item.isTask
                      ? _Checkbox(entry: entry)
                      : _EventBadge(colors: colors),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: entry.depth == 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: finished ? colors.muted : colors.text,
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        _Meta(entry: entry),
                      ],
                    ),
                  ),
                  if (item.priority != Priority.none) _Flag(entry: entry),
                  // Keeps its space so rows don't shift on hover.
                  SizedBox(
                    width: 40,
                    child: showAdd
                        ? IconButton(
                            tooltip: l10n.addSubtaskTooltip,
                            iconSize: 20,
                            color: colors.accentText,
                            onPressed: () => controller.addSubtask(
                              item.id,
                              l10n.newItemTitle,
                            ),
                            icon: const Icon(Icons.add),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.entry});

  final ItemEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final item = entry.item;
    final color = colors.priorityColor(item.priority) ?? colors.muted;
    return Semantics(
      checked: item.isDone,
      child: Tooltip(
        message: item.isDone ? f.l10n.markNotDone : f.l10n.markDone,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final celebrate = Celebration.prepare(context);
            if (await controller.toggleDone(item.id)) celebrate();
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isDone ? colors.accent : null,
              border: Border.all(
                color: item.isDone ? colors.accent : color,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.isDone
                ? Icon(Icons.check, size: 16, color: colors.onAccent)
                : null,
          ),
        ),
      ),
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge({required this.colors});

  final WayfinchColors colors;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: colors.accentSoft,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.schedule, size: 15, color: colors.accentText),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.entry});

  final ItemEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final item = entry.item;
    var when = f.whenLabel(item, controller.now);
    if (entry.isOverdue) when = f.l10n.overdueLabel(when);
    final tags = item.tagIds
        .map((id) => controller.tagsById[id])
        .whereType<Tag>()
        .toList();
    final parts = <Widget>[
      if (when.isNotEmpty)
        Text(
          when,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: entry.isOverdue ? colors.warningText : colors.muted,
          ),
        ),
      if (item.isRecurring)
        _IconText(icon: Icons.repeat, text: f.repeat(item.recurrence)),
      if (entry.subtasksTotal > 0)
        _IconText(
          icon: Icons.check,
          text: f.l10n.subtaskProgress(entry.subtasksDone, entry.subtasksTotal),
          bold: true,
        ),
      for (final tag in tags)
        TagChip(name: tag.name, color: colors.tagColor(tag.color)),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 13, color: colors.muted),
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: parts,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text, this.bold = false});

  final IconData icon;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: WayfinchColors.of(context).muted),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
      ),
    ],
  );
}

/// A small tag pill with a colored dot.
class TagChip extends StatelessWidget {
  /// Creates a chip for tag [name] in [color].
  const TagChip({super.key, required this.name, required this.color});

  /// Tag name.
  final String name;

  /// Tag color (the dot).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colors.subtle,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700, color: colors.text),
          ),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.entry});

  final ItemEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final priority = entry.item.priority;
    return Semantics(
      label: f.l10n.priorityFlag(f.priority(priority)),
      child: Icon(Icons.flag, size: 18, color: colors.priorityColor(priority)),
    );
  }
}
