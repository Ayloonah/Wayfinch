import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/overdue.dart';

void main() {
  final now = DateTime(2026, 11, 15, 14, 0);

  bool overdue({
    ItemType type = ItemType.task,
    DateTime? due,
    bool dueHasTime = true,
    DateTime? doneAt,
  }) => isOverdue(
    type: type,
    due: due,
    dueHasTime: dueHasTime,
    doneAt: doneAt,
    now: now,
  );

  group('isOverdue', () {
    test('open task due in the past is overdue', () {
      expect(overdue(due: DateTime(2026, 11, 15, 13, 59)), isTrue);
    });

    test('open task due in the future is not overdue', () {
      expect(overdue(due: DateTime(2026, 11, 15, 14, 1)), isFalse);
    });

    test('due exactly now is not overdue yet', () {
      expect(overdue(due: now), isFalse);
    });

    test('done task is never overdue', () {
      expect(
        overdue(due: DateTime(2026, 11, 1), doneAt: DateTime(2026, 11, 2)),
        isFalse,
      );
    });

    test('task without a due date is never overdue', () {
      expect(overdue(), isFalse);
    });

    test('events are never overdue', () {
      expect(
        overdue(type: ItemType.event, due: DateTime(2026, 11, 1)),
        isFalse,
      );
    });

    test('date-only task is on time for its whole due day', () {
      expect(overdue(due: DateTime(2026, 11, 15), dueHasTime: false), isFalse);
    });

    test('date-only task is overdue the day after', () {
      expect(overdue(due: DateTime(2026, 11, 14), dueHasTime: false), isTrue);
    });

    test('moving the due date forward clears overdue right away', () {
      expect(overdue(due: DateTime(2026, 11, 14, 9)), isTrue);
      expect(overdue(due: DateTime(2026, 11, 16, 9)), isFalse);
    });
  });
}
