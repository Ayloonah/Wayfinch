import 'dart:convert';

import '../item.dart';
import '../item_tree.dart';
import '../sorting.dart';
import 'exchange_model.dart';

/// "What to include" in an export.
class ExportOptions {
  /// Creates options. Defaults follow the spec: done items are off.
  const ExportOptions({
    this.openTasks = true,
    this.events = true,
    this.notes = true,
    this.doneItems = false,
  });

  /// Open tasks.
  final bool openTasks;

  /// Events that haven't ended.
  final bool events;

  /// Item notes.
  final bool notes;

  /// Completed tasks and ended events.
  final bool doneItems;

  /// Returns a copy with some options changed.
  ExportOptions copyWith({
    bool? openTasks,
    bool? events,
    bool? notes,
    bool? doneItems,
  }) => ExportOptions(
    openTasks: openTasks ?? this.openTasks,
    events: events ?? this.events,
    notes: notes ?? this.notes,
    doneItems: doneItems ?? this.doneItems,
  );

  /// Serializes for settings.
  String encode() => jsonEncode({
    'openTasks': openTasks,
    'events': events,
    'notes': notes,
    'doneItems': doneItems,
  });

  /// Reads [encode]'s output (defaults for anything missing or bad).
  static ExportOptions decode(String? source) {
    if (source == null) return const ExportOptions();
    try {
      final m = jsonDecode(source) as Map<String, dynamic>;
      return ExportOptions(
        openTasks: m['openTasks'] as bool? ?? true,
        events: m['events'] as bool? ?? true,
        notes: m['notes'] as bool? ?? true,
        doneItems: m['doneItems'] as bool? ?? false,
      );
    } on Object {
      return const ExportOptions();
    }
  }
}

/// How many items each "What to include" option covers.
class ExportCounts {
  /// Creates counts.
  const ExportCounts({
    required this.openTasks,
    required this.events,
    required this.doneItems,
  });

  /// Open tasks.
  final int openTasks;

  /// Events that haven't ended.
  final int events;

  /// Done tasks and ended events.
  final int doneItems;
}

/// Counts for the export checkboxes.
ExportCounts exportCounts(ItemTree tree, DateTime now) {
  var open = 0, events = 0, done = 0;
  for (final item in tree.all) {
    if (item.isDone || item.isEnded(now)) {
      done++;
    } else if (item.isEvent) {
      events++;
    } else {
      open++;
    }
  }
  return ExportCounts(openTasks: open, events: events, doneItems: done);
}

/// Builds the "My list" JSON for an export.
///
/// Items keep their nesting. When a parent is left out (say, a done parent
/// with done items unchecked), its included subtasks move up to the nearest
/// included ancestor, or to the top.
class ExportResult {
  /// Creates a result.
  const ExportResult(this.json, this.itemCount);

  /// Pretty-printed JSON.
  final String json;

  /// Number of items in it.
  final int itemCount;
}

/// Builds the export JSON for [tree] with [options].
ExportResult buildExportJson(
  ItemTree tree,
  Map<String, Tag> tagsById,
  ExportOptions options,
  DateTime now,
) {
  bool included(Item item) {
    if (item.isDone || item.isEnded(now)) return options.doneItems;
    return item.isEvent ? options.events : options.openTasks;
  }

  var count = 0;
  List<Map<String, Object?>> children(String? parentId) {
    final out = <Map<String, Object?>>[];
    final kids = [...tree.childrenOf(parentId)]..sort(compareItems);
    for (final kid in kids) {
      if (included(kid)) {
        count++;
        out.add(_itemJson(kid, tagsById, options, children(kid.id)));
      } else {
        // Not included: lift its included descendants up a level.
        out.addAll(children(kid.id));
      }
    }
    return out;
  }

  final doc = {
    'format': exchangeFormat,
    'version': exchangeVersion,
    'items': children(null),
  };
  return ExportResult(const JsonEncoder.withIndent('  ').convert(doc), count);
}

Map<String, Object?> _itemJson(
  Item item,
  Map<String, Tag> tagsById,
  ExportOptions options,
  List<Map<String, Object?>> children,
) {
  return {
    'id': item.id,
    'type': item.type.name,
    'title': item.title,
    if (options.notes && item.notes != null) 'notes': item.notes,
    if (item.isTask)
      'due': item.due == null
          ? null
          : ExchangeDate(item.due!, hasTime: item.dueHasTime).format(),
    if (item.isEvent && item.start != null)
      'start': ExchangeDate(item.start!, hasTime: true).format(),
    if (item.isEvent && item.end != null)
      'end': ExchangeDate(item.end!, hasTime: true).format(),
    'priority': item.priority.name,
    'tags': [
      for (final id in item.tagIds)
        if (tagsById[id] != null) tagsById[id]!.name,
    ],
    'recurrence': item.recurrence,
    if (item.isDone) 'done': true,
    if (children.isNotEmpty) 'children': children,
  };
}
