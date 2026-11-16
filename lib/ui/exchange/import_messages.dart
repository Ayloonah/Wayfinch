import 'package:flutter/widgets.dart';

import '../../domain/exchange/exchange_model.dart';
import '../../domain/exchange/exchange_parser.dart';
import '../../domain/exchange/import_plan.dart';
import '../../domain/item_enums.dart';
import '../format.dart';

/// Turns import errors and planned changes into friendly, localized text.
class ImportMessages {
  /// Creates the helper for [context]'s locale.
  ImportMessages.of(BuildContext context) : _f = Formats.of(context);

  final Formats _f;

  /// "Item 3 › subtask 1" for `items[2].children[0]`; "The list" for the
  /// document itself.
  String where(String path) {
    final l10n = _f.l10n;
    final indexes = RegExp(r'\[(\d+)\]')
        .allMatches(path)
        .map((m) => int.parse(m[1]!) + 1)
        .toList();
    if (indexes.isEmpty) return l10n.importWhereList;
    final parts = [
      l10n.importWhereItem(indexes.first),
      for (final i in indexes.skip(1)) l10n.importWhereSubtask(i),
    ];
    return parts.join(' › ');
  }

  /// One error as a sentence.
  String error(ExchangeError e) {
    final l10n = _f.l10n;
    final at = where(e.path);
    return switch (e.code) {
      ExchangeErrorCode.noJson => l10n.importErrorNoJson,
      ExchangeErrorCode.invalidJson => l10n.importErrorInvalidJson(e.detail),
      ExchangeErrorCode.notAnObject => l10n.importErrorNotObject,
      ExchangeErrorCode.wrongFormat => l10n.importErrorWrongFormat,
      // The format version is internal: never shown to the user.
      ExchangeErrorCode.unsupportedVersion => l10n.importErrorVersion,
      ExchangeErrorCode.missingField => l10n.importErrorMissing(at, e.detail),
      ExchangeErrorCode.wrongType => l10n.importErrorWrongType(at, e.detail),
      ExchangeErrorCode.unknownField => l10n.importErrorUnknownField(
        at,
        e.detail,
      ),
      ExchangeErrorCode.invalidType => l10n.importErrorType(at),
      ExchangeErrorCode.emptyTitle => l10n.importErrorEmptyTitle(at),
      ExchangeErrorCode.invalidDate => l10n.importErrorDate(at, e.detail),
      ExchangeErrorCode.invalidPriority => l10n.importErrorPriority(at),
      ExchangeErrorCode.invalidRecurrence => l10n.importErrorRecurrence(at),
      ExchangeErrorCode.fieldNotForType => l10n.importErrorFieldForType(
        at,
        e.detail,
      ),
      ExchangeErrorCode.eventNeedsTimes => l10n.importErrorEventTimes(
        at,
        e.detail,
      ),
      ExchangeErrorCode.endBeforeStart => l10n.importErrorEndBeforeStart(at),
      ExchangeErrorCode.duplicateId => l10n.importErrorDuplicateId(
        at,
        e.detail,
      ),
    };
  }

  String _date(ExchangeDate? d) {
    if (d == null) return _f.l10n.importNoDate;
    final day = _f.shortDate(d.value);
    return d.hasTime ? _f.l10n.dateWithTime(day, _f.time(d.value)) : day;
  }

  /// The detail line for a preview entry.
  String detail(PlannedChange change) {
    final l10n = _f.l10n;
    switch (change) {
      case AddedItem(:final source):
        final when = source.type == ItemType.event
            ? (source.start == null ? null : _date(source.start))
            : (source.due == null ? null : _date(source.due));
        return [?when, ...source.tags].join(' · ');
      case RemovedItem(:final item):
        final due = item.isTask ? item.due : item.start;
        if (due == null) return '';
        return l10n.importWasDue(
          _date(ExchangeDate(due, hasTime: item.isEvent || item.dueHasTime)),
        );
      case ChangedItem(:final fields):
        return fields.map(_field).join(' · ');
    }
  }

  String _field(FieldChange c) {
    final l10n = _f.l10n;
    return switch (c) {
      TitleChange(:final from) => l10n.importRenamed(from),
      DateChange(:final field, :final from, :final to) => switch (field) {
        DateField.due => l10n.importDue(_date(from), _date(to)),
        DateField.start => l10n.importStart(_date(from), _date(to)),
        DateField.end => l10n.importEnd(_date(from), _date(to)),
      },
      PriorityChange(:final from, :final to) => l10n.importPriority(
        _f.priority(from),
        _f.priority(to),
      ),
      TagsChange(:final added, :final removed) => [
        if (added.isNotEmpty) l10n.importTagsAdded(added.join(', ')),
        if (removed.isNotEmpty) l10n.importTagsRemoved(removed.join(', ')),
      ].join(' · '),
      NotesChange() => l10n.importNotesChanged,
      RecurrenceChange(:final from, :final to) => l10n.importRepeat(
        _f.repeat(from),
        _f.repeat(to),
      ),
      DoneChange(:final done) =>
        done ? l10n.importMarkedDone : l10n.importReopened,
      TypeChange(:final to) =>
        to == ItemType.event ? l10n.importNowEvent : l10n.importNowTask,
      MoveChange(:final newParentTitle) =>
        newParentTitle == null
            ? l10n.importMovedTop
            : l10n.importMovedUnder(newParentTitle),
    };
  }
}
