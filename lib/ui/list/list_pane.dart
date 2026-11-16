import 'package:flutter/material.dart';

import '../../domain/views.dart';
import '../format.dart';
import '../home/home_controller.dart';
import '../theme/tokens.dart';
import 'item_row.dart';
import 'quick_add_field.dart';

/// The middle pane: view title, quick add and the item list.
class ListPane extends StatelessWidget {
  /// Creates the pane for [view].
  const ListPane({super.key, required this.view});

  /// Which list to show.
  final AppView view;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final data = controller.view(view);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(view: view, data: data),
          const SizedBox(height: 18),
          if (view != AppView.done) ...[
            const QuickAddField(),
            const SizedBox(height: 18),
          ],
          Expanded(
            child: _ListCard(view: view, data: data),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.view, required this.data});

  final AppView view;
  final ViewData data;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final l10n = f.l10n;
    final title = switch (view) {
      AppView.today => l10n.navToday,
      AppView.upcoming => l10n.navUpcoming,
      AppView.all => l10n.navAll,
      AppView.done => l10n.navDone,
    };
    final subtitle = switch (view) {
      AppView.today => _todaySubtitle(f, controller),
      AppView.upcoming => l10n.upcomingSubtitle,
      AppView.all => l10n.allSubtitle(data.count),
      AppView.done => l10n.doneSubtitle(data.doneThisWeek),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 15, color: colors.muted),
              ),
            ],
          ),
        ),
        if (view != AppView.done)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onAccent,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            onPressed: () => controller.newItem(l10n.newItemTitle),
            icon: const Icon(Icons.add),
            label: Text(l10n.newItem),
          ),
      ],
    );
  }

  String _todaySubtitle(Formats f, HomeController controller) {
    final today = controller.view(AppView.today);
    final items = today.entries.whereType<ItemEntry>().map((e) => e.item);
    final unique = {for (final i in items) i.id: i}.values;
    final tasks = unique.where((i) => i.isTask).length;
    final events = unique.length - tasks;
    return f.l10n.todaySubtitle(
      f.longDate(controller.now),
      f.l10n.taskCount(tasks),
      f.l10n.eventCount(events),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.view, required this.data});

  final AppView view;
  final ViewData data;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    if (data.entries.isEmpty) {
      final message = switch (view) {
        AppView.today => f.l10n.emptyToday,
        AppView.upcoming => f.l10n.emptyUpcoming,
        AppView.all => f.l10n.emptyAll,
        AppView.done => f.l10n.emptyDone,
      };
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: colors.muted),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: colors.panel,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: data.entries.length,
          itemBuilder: (context, index) => switch (data.entries[index]) {
            final SectionHeader h => _SectionTitle(header: h),
            final ItemEntry e => ItemRow(
              key: ValueKey('${e.item.id}-$index'),
              entry: e,
            ),
            final HiddenDoneEntry h => _HiddenDoneRow(entry: h),
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.header});

  final SectionHeader header;

  @override
  Widget build(BuildContext context) {
    final colors = WayfinchColors.of(context);
    final f = Formats.of(context);
    final title = switch (header.kind) {
      SectionKind.overdue => f.l10n.sectionOverdue,
      SectionKind.today => f.l10n.sectionToday,
      SectionKind.day => f.relativeDay(header.day!, HomeScope.of(context).now),
    };
    final color = header.kind == SectionKind.overdue
        ? colors.warningText
        : colors.muted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        '${title.toUpperCase()}  ${header.count}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _HiddenDoneRow extends StatelessWidget {
  const _HiddenDoneRow({required this.entry});

  final HiddenDoneEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    final colors = WayfinchColors.of(context);
    final l10n = Formats.of(context).l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(indentFor(entry.depth), 0, 16, 4),
      child: Row(
        children: [
          Text(
            l10n.hiddenDone(entry.count),
            style: TextStyle(fontSize: 13, color: colors.muted),
          ),
          TextButton(
            onPressed: () => controller.toggleShowDone(entry.parentId),
            child: Text(
              entry.shown ? l10n.hide : l10n.show,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: colors.accentText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
