import 'package:flutter/material.dart';

import '../format.dart';
import '../theme/tokens.dart';

/// What the date-and-time dialog returns.
class DateTimeChoice {
  /// Creates a choice.
  const DateTimeChoice(this.value, {required this.hasTime});

  /// The chosen date (midnight when [hasTime] is false) or date and time.
  final DateTime value;

  /// Whether a time of day was chosen.
  final bool hasTime;
}

/// Opens one dialog to pick a date and, optionally, a time, so both are
/// saved together. Returns null when cancelled.
///
/// With [timeRequired] (event start/end) the time can't be removed.
Future<DateTimeChoice?> showDateTimePicker(
  BuildContext context, {
  DateTime? initial,
  bool initialHasTime = false,
  bool timeRequired = false,
}) {
  return showDialog<DateTimeChoice>(
    context: context,
    builder: (context) => _DateTimeDialog(
      initial: initial ?? DateTime.now(),
      initialHasTime: initialHasTime || timeRequired,
      timeRequired: timeRequired,
    ),
  );
}

class _DateTimeDialog extends StatefulWidget {
  const _DateTimeDialog({
    required this.initial,
    required this.initialHasTime,
    required this.timeRequired,
  });

  final DateTime initial;
  final bool initialHasTime;
  final bool timeRequired;

  @override
  State<_DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<_DateTimeDialog> {
  late DateTime _day = DateUtils.dateOnly(widget.initial);
  late TimeOfDay? _time = widget.initialHasTime
      ? TimeOfDay.fromDateTime(widget.initial)
      : null;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final time = _time;
    Navigator.pop(
      context,
      time == null
          ? DateTimeChoice(_day, hasTime: false)
          : DateTimeChoice(
              DateTime(_day.year, _day.month, _day.day, time.hour, time.minute),
              hasTime: true,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = Formats.of(context);
    final colors = WayfinchColors.of(context);
    final now = DateTime.now();
    final time = _time;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarDatePicker(
              initialDate: _day,
              firstDate: DateTime(now.year - 10),
              lastDate: DateTime(now.year + 20),
              onDateChanged: (day) => setState(() => _day = day),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: colors.muted),
                  const SizedBox(width: 8),
                  if (time == null)
                    TextButton(
                      onPressed: _pickTime,
                      child: Text(f.l10n.addTime),
                    )
                  else ...[
                    TextButton(
                      onPressed: _pickTime,
                      child: Text(
                        f.time(DateTime(2000, 1, 1, time.hour, time.minute)),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!widget.timeRequired)
                      IconButton(
                        tooltip: f.l10n.removeTime,
                        iconSize: 18,
                        onPressed: () => setState(() => _time = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(f.l10n.promptCancel),
        ),
        FilledButton(onPressed: _save, child: Text(f.l10n.save)),
      ],
    );
  }
}
