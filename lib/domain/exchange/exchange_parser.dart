import 'dart:convert';

import '../item_enums.dart';
import '../recurrence.dart';
import 'exchange_model.dart';

/// Kinds of problems found in an imported reply. The UI turns them into
/// friendly, localized messages; [ExchangeError.path] says where.
enum ExchangeErrorCode {
  /// No `{ ... }` block found in the text.
  noJson,

  /// The JSON itself is broken (detail: the parser's message).
  invalidJson,

  /// The top level isn't an object.
  notAnObject,

  /// `"format"` isn't `"wayfinch"`.
  wrongFormat,

  /// `"version"` is missing or not one this app reads (detail: the value).
  unsupportedVersion,

  /// A required field is missing (detail: the field).
  missingField,

  /// A field has the wrong kind of value (detail: the field).
  wrongType,

  /// A field the format doesn't have (detail: the field).
  unknownField,

  /// `"type"` isn't `"task"` or `"event"`.
  invalidType,

  /// The title is empty.
  emptyTitle,

  /// A date isn't `YYYY-MM-DD` or `YYYY-MM-DDTHH:mm` (detail: the field).
  invalidDate,

  /// `"priority"` isn't none/low/medium/high.
  invalidPriority,

  /// `"recurrence"` isn't a valid RRULE.
  invalidRecurrence,

  /// A field that only tasks (`due`, `done`) or only events (`start`,
  /// `end`) have, on the other kind (detail: the field).
  fieldNotForType,

  /// An event without `start` or `end` (detail: the field).
  eventNeedsTimes,

  /// An event that ends before it starts.
  endBeforeStart,

  /// The same id appears twice (detail: the id).
  duplicateId,
}

/// One problem in an imported reply.
class ExchangeError {
  /// Creates an error.
  const ExchangeError(this.code, {this.path = '', this.detail = ''});

  /// What's wrong.
  final ExchangeErrorCode code;

  /// Where, e.g. `items[2].children[0]` (empty for the whole document).
  final String path;

  /// Extra detail (field name, value...).
  final String detail;

  @override
  String toString() => 'ExchangeError($code at "$path": $detail)';
}

/// Either a valid document or a list of errors.
class ParseOutcome {
  const ParseOutcome._(this.document, this.errors);

  /// A valid document.
  factory ParseOutcome.ok(ExchangeDocument document) =>
      ParseOutcome._(document, const []);

  /// Problems found.
  factory ParseOutcome.failed(List<ExchangeError> errors) =>
      ParseOutcome._(null, errors);

  /// The document, when valid.
  final ExchangeDocument? document;

  /// Problems, when not.
  final List<ExchangeError> errors;

  /// Whether the reply is valid.
  bool get isValid => document != null;
}

/// At most this many errors are reported (the first ones are the useful
/// ones).
const maxReportedErrors = 20;

const _topKeys = {'format', 'version', 'items'};
const _itemKeys = {
  'id',
  'type',
  'title',
  'notes',
  'due',
  'start',
  'end',
  'priority',
  'tags',
  'recurrence',
  'done',
  'children',
};

/// Finds the JSON object in an AI reply: skips any text and code fences
/// around it and returns the outermost `{ ... }` block, or null.
String? extractJson(String text) {
  final start = text.indexOf('{');
  if (start < 0) return null;
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < text.length; i++) {
    final c = text[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (c == r'\') {
        escaped = true;
      } else if (c == '"') {
        inString = false;
      }
      continue;
    }
    if (c == '"') {
      inString = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return text.substring(start, i + 1);
    }
  }
  return null; // unbalanced
}

/// Parses and strictly validates an AI reply.
ParseOutcome parseExchange(String text) {
  final json = extractJson(text);
  if (json == null) {
    return ParseOutcome.failed([const ExchangeError(ExchangeErrorCode.noJson)]);
  }
  Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException catch (e) {
    return ParseOutcome.failed([
      ExchangeError(ExchangeErrorCode.invalidJson, detail: e.message),
    ]);
  }
  if (decoded is! Map<String, dynamic>) {
    return ParseOutcome.failed([
      const ExchangeError(ExchangeErrorCode.notAnObject),
    ]);
  }
  final v = _Validator();
  final items = v.document(decoded);
  if (v.errors.isNotEmpty) {
    return ParseOutcome.failed(v.errors.take(maxReportedErrors).toList());
  }
  return ParseOutcome.ok(ExchangeDocument(items));
}

class _Validator {
  final errors = <ExchangeError>[];
  final _ids = <String>{};

  void _error(ExchangeErrorCode code, String path, [String detail = '']) =>
      errors.add(ExchangeError(code, path: path, detail: detail));

  List<ExchangeItem> document(Map<String, dynamic> doc) {
    for (final key in doc.keys) {
      if (!_topKeys.contains(key)) {
        _error(ExchangeErrorCode.unknownField, '', key);
      }
    }
    if (doc['format'] != exchangeFormat) {
      _error(ExchangeErrorCode.wrongFormat, 'format', '${doc['format']}');
    }
    final version = doc['version'];
    if (version != exchangeVersion) {
      _error(ExchangeErrorCode.unsupportedVersion, 'version', '$version');
    }
    final items = doc['items'];
    if (items == null) {
      _error(ExchangeErrorCode.missingField, '', 'items');
      return const [];
    }
    if (items is! List) {
      _error(ExchangeErrorCode.wrongType, 'items', 'items');
      return const [];
    }
    return _list(items, 'items');
  }

  List<ExchangeItem> _list(List<dynamic> list, String path) {
    final out = <ExchangeItem>[];
    for (var i = 0; i < list.length; i++) {
      final item = _item(list[i], '$path[$i]');
      if (item != null) out.add(item);
    }
    return out;
  }

  ExchangeItem? _item(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      _error(ExchangeErrorCode.wrongType, path, 'item');
      return null;
    }
    final before = errors.length;
    for (final key in raw.keys) {
      if (!_itemKeys.contains(key)) {
        _error(ExchangeErrorCode.unknownField, path, key);
      }
    }

    // id
    String? id;
    if (raw.containsKey('id') && raw['id'] != null) {
      final value = raw['id'];
      if (value is! String || value.trim().isEmpty) {
        _error(ExchangeErrorCode.wrongType, path, 'id');
      } else if (!_ids.add(value)) {
        _error(ExchangeErrorCode.duplicateId, path, value);
      } else {
        id = value;
      }
    }

    // type
    ItemType? type;
    final rawType = raw['type'];
    if (rawType == null) {
      if (id == null) _error(ExchangeErrorCode.missingField, path, 'type');
    } else if (rawType is! String) {
      _error(ExchangeErrorCode.wrongType, path, 'type');
    } else {
      type = ItemType.values.asNameMap()[rawType];
      if (type == null) _error(ExchangeErrorCode.invalidType, path, rawType);
    }

    // title
    var title = '';
    final rawTitle = raw['title'];
    if (rawTitle == null) {
      if (id == null) _error(ExchangeErrorCode.missingField, path, 'title');
    } else if (rawTitle is! String) {
      _error(ExchangeErrorCode.wrongType, path, 'title');
    } else if (rawTitle.trim().isEmpty) {
      _error(ExchangeErrorCode.emptyTitle, path);
    } else {
      title = rawTitle.trim();
    }

    final notes = _optionalString(raw, 'notes', path);
    final due = _date(raw, 'due', path);
    final start = _date(raw, 'start', path);
    final end = _date(raw, 'end', path);

    var priority = Priority.none;
    final rawPriority = raw['priority'];
    if (rawPriority != null) {
      final p = rawPriority is String
          ? Priority.values.asNameMap()[rawPriority]
          : null;
      if (p == null) {
        _error(ExchangeErrorCode.invalidPriority, path, '$rawPriority');
      } else {
        priority = p;
      }
    }

    final tags = <String>[];
    final rawTags = raw['tags'];
    if (rawTags != null) {
      if (rawTags is! List || rawTags.any((t) => t is! String)) {
        _error(ExchangeErrorCode.wrongType, path, 'tags');
      } else {
        for (final t in rawTags.cast<String>()) {
          final name = t.trim();
          final dup = tags.any((x) => x.toLowerCase() == name.toLowerCase());
          if (name.isNotEmpty && !dup) tags.add(name);
        }
      }
    }

    final recurrence = _optionalString(raw, 'recurrence', path);
    if (recurrence != null && !isValidRrule(recurrence)) {
      _error(ExchangeErrorCode.invalidRecurrence, path, recurrence);
    }

    bool? done;
    if (raw.containsKey('done') && raw['done'] != null) {
      if (raw['done'] is! bool) {
        _error(ExchangeErrorCode.wrongType, path, 'done');
      } else {
        done = raw['done'] as bool;
      }
    }

    // Fields that belong to one kind only.
    if (type == ItemType.event) {
      for (final key in ['due', 'done']) {
        if (raw[key] != null) {
          _error(ExchangeErrorCode.fieldNotForType, path, key);
        }
      }
      // New events need both times; existing ones may leave them out.
      if (id == null || raw.containsKey('start') || raw.containsKey('end')) {
        if (raw['start'] == null) {
          _error(ExchangeErrorCode.eventNeedsTimes, path, 'start');
        }
        if (raw['end'] == null) {
          _error(ExchangeErrorCode.eventNeedsTimes, path, 'end');
        }
      }
      if (start != null && end != null && end.value.isBefore(start.value)) {
        _error(ExchangeErrorCode.endBeforeStart, path);
      }
    } else if (type == ItemType.task) {
      for (final key in ['start', 'end']) {
        if (raw[key] != null) {
          _error(ExchangeErrorCode.fieldNotForType, path, key);
        }
      }
    }

    var children = const <ExchangeItem>[];
    final rawChildren = raw['children'];
    if (rawChildren != null) {
      if (rawChildren is! List) {
        _error(ExchangeErrorCode.wrongType, path, 'children');
      } else {
        children = _list(rawChildren, '$path.children');
      }
    }

    if (errors.length != before) return null;
    return ExchangeItem(
      id: id,
      // Existing items may leave type out: it's filled in from the app.
      type: type ?? ItemType.task,
      title: title,
      present: raw.keys.toSet(),
      notes: notes,
      due: due,
      start: start,
      end: end,
      priority: priority,
      tags: tags,
      recurrence: recurrence,
      done: done,
      children: children,
      path: path,
    );
  }

  String? _optionalString(Map<String, dynamic> raw, String key, String path) {
    final value = raw[key];
    if (value == null) return null;
    if (value is! String) {
      _error(ExchangeErrorCode.wrongType, path, key);
      return null;
    }
    return value.trim().isEmpty ? null : value;
  }

  static final _datePattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2}))?)?$',
  );

  ExchangeDate? _date(Map<String, dynamic> raw, String key, String path) {
    final value = raw[key];
    if (value == null) return null;
    if (value is! String) {
      _error(ExchangeErrorCode.invalidDate, path, key);
      return null;
    }
    final m = _datePattern.firstMatch(value.trim());
    if (m == null) {
      _error(ExchangeErrorCode.invalidDate, path, key);
      return null;
    }
    final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
    final hasTime = m[4] != null;
    final h = hasTime ? int.parse(m[4]!) : 0;
    final mi = hasTime ? int.parse(m[5]!) : 0;
    final dt = DateTime(y, mo, d, h, mi);
    // Reject values DateTime would roll over (Feb 30, 25:00...).
    if (dt.year != y ||
        dt.month != mo ||
        dt.day != d ||
        dt.hour != h ||
        dt.minute != mi) {
      _error(ExchangeErrorCode.invalidDate, path, key);
      return null;
    }
    return ExchangeDate(dt, hasTime: hasTime);
  }
}
