import '../item_enums.dart';

/// The AI exchange format's identifier and the version this app writes.
/// The version is internal only: never shown in the UI.
const exchangeFormat = 'wayfinch';

/// Current exchange format version.
const exchangeVersion = 1;

/// A date, with or without a time of day, as written in the exchange format
/// (`2026-12-05` or `2026-12-05T23:59`, local time).
class ExchangeDate {
  /// Creates a date.
  const ExchangeDate(this.value, {required this.hasTime});

  /// The local date (midnight when [hasTime] is false) or date and time.
  final DateTime value;

  /// Whether a time of day was given.
  final bool hasTime;

  /// Formats as `YYYY-MM-DD` or `YYYY-MM-DDTHH:mm`.
  String format() {
    final l = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${l.year.toString().padLeft(4, '0')}-${two(l.month)}-${two(l.day)}';
    return hasTime ? '${date}T${two(l.hour)}:${two(l.minute)}' : date;
  }

  @override
  bool operator ==(Object other) =>
      other is ExchangeDate && other.value == value && other.hasTime == hasTime;

  @override
  int get hashCode => Object.hash(value, hasTime);
}

/// One item from an imported document.
///
/// For items that already exist (matched by [id]), a field that is missing
/// from the JSON means "leave it as it is"; [present] lists the keys that
/// were there. For new items, missing fields take their defaults.
class ExchangeItem {
  /// Creates an item.
  ExchangeItem({
    required this.id,
    required this.type,
    required this.title,
    required this.present,
    this.notes,
    this.due,
    this.start,
    this.end,
    this.priority = Priority.none,
    this.tags = const [],
    this.recurrence,
    this.done,
    this.children = const [],
    required this.path,
  });

  /// The id, or null for a new item.
  final String? id;

  /// Task or event.
  final ItemType type;

  /// Title.
  final String title;

  /// Keys present in the JSON object.
  final Set<String> present;

  /// Notes (null = none, or not given).
  final String? notes;

  /// Task due date.
  final ExchangeDate? due;

  /// Event start.
  final ExchangeDate? start;

  /// Event end.
  final ExchangeDate? end;

  /// Priority.
  final Priority priority;

  /// Tag names.
  final List<String> tags;

  /// RRULE, or null.
  final String? recurrence;

  /// Whether the task is done (null = not given).
  final bool? done;

  /// Subtasks, in order.
  final List<ExchangeItem> children;

  /// Where it was in the JSON, e.g. `items[2].children[0]`, for messages.
  final String path;

  /// Whether [key] was in the JSON object.
  bool has(String key) => present.contains(key);
}

/// A parsed, valid exchange document.
class ExchangeDocument {
  /// Creates a document.
  const ExchangeDocument(this.items);

  /// Top-level items, in order.
  final List<ExchangeItem> items;

  /// Every item, depth first.
  Iterable<ExchangeItem> get allItems sync* {
    Iterable<ExchangeItem> walk(List<ExchangeItem> list) sync* {
      for (final item in list) {
        yield item;
        yield* walk(item.children);
      }
    }

    yield* walk(items);
  }
}

/// The top-level shape, as shown to the AI in the format rules and as the
/// paste box's hint. JSON, so never translated.
const exchangeSkeleton =
    '{"format": "$exchangeFormat", "version": $exchangeVersion, "items": [...]}';
