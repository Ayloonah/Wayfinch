// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wayfinch';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get navToday => 'Today';

  @override
  String get navUpcoming => 'Upcoming';

  @override
  String get navAll => 'All';

  @override
  String get navDone => 'Done';

  @override
  String get navSettings => 'Settings';

  @override
  String doneThisWeekShort(int count) {
    return '$count this week';
  }

  @override
  String todaySubtitle(String date, String tasks, String events) {
    return '$date · $tasks, $events';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get upcomingSubtitle => 'The next 7 days';

  @override
  String allSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open items',
      one: '1 open item',
      zero: 'Nothing open',
    );
    return '$_temp0';
  }

  @override
  String doneSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done this week',
      one: '1 done this week',
      zero: 'Nothing done this week yet',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'New item';

  @override
  String get newItemTitle => 'New task';

  @override
  String get quickAddLabel => 'Quick add';

  @override
  String get quickAddHint =>
      'Add a task... try \"Lab report Friday 5pm #school !high\"';

  @override
  String get sectionOverdue => 'Overdue';

  @override
  String get sectionToday => 'Today';

  @override
  String get emptyToday => 'Nothing due today. Enjoy the calm.';

  @override
  String get emptyUpcoming => 'Nothing planned for the next 7 days.';

  @override
  String get emptyAll => 'No items yet. Add one above!';

  @override
  String get emptyDone => 'Nothing done yet. You\'ve got this.';

  @override
  String hiddenDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed subtasks hidden',
      one: '1 completed subtask hidden',
    );
    return '$_temp0';
  }

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get labelToday => 'Today';

  @override
  String get labelTomorrow => 'Tomorrow';

  @override
  String get labelYesterday => 'Yesterday';

  @override
  String dateWithTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String dateDotTime(String date, String time) {
    return '$date · $time';
  }

  @override
  String timeRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String overdueLabel(String when) {
    return 'Overdue · $when';
  }

  @override
  String subtaskProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get markDone => 'Mark done';

  @override
  String get markNotDone => 'Mark not done';

  @override
  String get priorityNone => 'None';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String priorityFlag(String priority) {
    return '$priority priority';
  }

  @override
  String get repeatNone => 'Doesn\'t repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatBiweekly => 'Every 2 weeks';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get repeatCustom => 'Custom';

  @override
  String get typeTask => 'Task';

  @override
  String get typeEvent => 'Event';

  @override
  String get titleHint => 'What needs doing?';

  @override
  String get closeDetails => 'Close details';

  @override
  String get fieldDue => 'Due';

  @override
  String get fieldStart => 'Starts';

  @override
  String get fieldEnd => 'Ends';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldRepeat => 'Repeat';

  @override
  String get noDueDate => 'No due date';

  @override
  String get addTime => 'Add time';

  @override
  String get clearDate => 'Clear date';

  @override
  String get addTag => '+ Tag';

  @override
  String get tagHint => 'Find or create a tag';

  @override
  String createTag(String name) {
    return 'Create \"$name\"';
  }

  @override
  String removeTag(String name) {
    return 'Remove $name';
  }

  @override
  String get subtasks => 'Subtasks';

  @override
  String subtasksProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get addSubtask => '+ Add subtask';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Anything worth remembering';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get markAsNotDone => 'Mark as not done';

  @override
  String get deleteItem => 'Delete item';

  @override
  String get deleteTitle => 'Delete this item?';

  @override
  String deleteWithSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This also deletes its $count subtasks.',
      one: 'This also deletes its subtask.',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Delete';

  @override
  String get promptPushParentTitle => 'Push the parent\'s date?';

  @override
  String promptPushParentBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This will also push the due dates of $count parent items.',
      one: 'This will also push the parent\'s due date.',
    );
    return '$_temp0';
  }

  @override
  String get promptCloseSubtasksTitle => 'Close the subtasks too?';

  @override
  String promptCloseSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This will also close its $count open subtasks.',
      one: 'This will also close its open subtask.',
    );
    return '$_temp0';
  }

  @override
  String get promptCompleteParentTitle => 'That was the last one!';

  @override
  String get promptCompleteParentBody => 'Mark the parent done too?';

  @override
  String get promptConfirm => 'Confirm';

  @override
  String get promptCancel => 'Cancel';

  @override
  String get promptRememberAnswer => 'Remember my answer';

  @override
  String get promptAlwaysDoThis => 'Always do this without asking';

  @override
  String get settingsPrompts => 'Prompts';

  @override
  String get settingsPromptsHelp =>
      'Choose whether Wayfinch asks you first, or just does what you picked last time.';

  @override
  String get settingPushParent =>
      'A subtask\'s due date moves past its parent\'s';

  @override
  String get settingCloseSubtasks =>
      'A parent is marked done with open subtasks';

  @override
  String get settingCompleteParent => 'The last open subtask is marked done';

  @override
  String get choiceAsk => 'Ask me';

  @override
  String get choiceAlwaysPushParent => 'Push the parent\'s date';

  @override
  String get choiceAlwaysCloseSubtasks => 'Close the subtasks';

  @override
  String get choiceAlwaysCompleteParent => 'Mark the parent done';

  @override
  String get choiceNeverCompleteParent => 'Leave the parent open';

  @override
  String deletedItem(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get undo => 'Undo';

  @override
  String get addSubtaskTooltip => 'Add a subtask';

  @override
  String subtaskOf(String title) {
    return 'Subtask of $title';
  }

  @override
  String get removeTime => 'Remove time';

  @override
  String get save => 'Save';

  @override
  String overdueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue items need a new plan',
      one: '1 overdue item needs a new plan',
    );
    return '$_temp0';
  }

  @override
  String get overdueReview => 'Review';

  @override
  String get overdueSnooze => 'Snooze until tomorrow';

  @override
  String get overdueTag => 'overdue';

  @override
  String get autoTag => 'auto';

  @override
  String get sidebarTags => 'Tags';

  @override
  String get emptyTag => 'Nothing open with this tag.';

  @override
  String get emptyOverdue => 'Nothing overdue. Nicely done!';

  @override
  String get changeTagColor => 'Change color';

  @override
  String get changeTagColorMenu => 'Change color...';

  @override
  String tagColorTitle(String name) {
    return 'Color for \"$name\"';
  }

  @override
  String get customColor => 'Custom color...';

  @override
  String get useDefaultColor => 'Use default';

  @override
  String get colorArea => 'Saturation and brightness';

  @override
  String get colorHue => 'Hue';

  @override
  String get colorHex => 'Hex';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSetByCustom => 'Your custom theme decides light or dark.';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get accentSky => 'Sky';

  @override
  String get accentHoney => 'Honey';

  @override
  String get accentMeadow => 'Meadow';

  @override
  String get accentLilac => 'Lilac';

  @override
  String get accentMono => 'Mono';

  @override
  String get accentCustom => 'Custom';

  @override
  String get customThemeTitle => 'Custom theme';

  @override
  String get customStartLight => 'Start from light';

  @override
  String get customStartDark => 'Start from dark';

  @override
  String get customAccent => 'Accent';

  @override
  String get customBackground => 'Background';

  @override
  String get customPanel => 'Panels';

  @override
  String get customSidebar => 'Sidebar';

  @override
  String get customText => 'Text';

  @override
  String get contrastAllGood => 'Everything should be easy to read.';

  @override
  String get contrastWarningTitle => 'Text may be hard to read here:';

  @override
  String get contrastTextOnBackground => 'Text on the background';

  @override
  String get contrastTextOnPanel => 'Text on panels';

  @override
  String get contrastTextOnSidebar => 'Text on the sidebar';

  @override
  String get contrastMutedOnPanel => 'Secondary text on panels';

  @override
  String get contrastTextOnAccent => 'Text on accent buttons';

  @override
  String get contrastAccentTextOnPanel => 'Accent-colored text on panels';

  @override
  String get close => 'Close';

  @override
  String get exportTitle => 'Export for AI';

  @override
  String get exportSubtitle =>
      'Paste this into your AI with your request, then bring its reply back with Import.';

  @override
  String get exportWhatToInclude => 'What to include';

  @override
  String get exportOpenTasks => 'Open tasks';

  @override
  String get exportEvents => 'Events';

  @override
  String get exportNotes => 'Notes';

  @override
  String get exportDoneItems => 'Done items';

  @override
  String get exportInstructionsHeading => 'My instructions';

  @override
  String get exportInstructionsSaved => 'Saved for every export';

  @override
  String get exportInstructionsHint =>
      'Anything your AI should always know. For example:\nBreak big tasks into steps under 2 hours.\nI\'m usually free after 4 PM on weekdays.\nTag school stuff with \"school\".';

  @override
  String get exportPreview => 'What gets copied';

  @override
  String get exportRulesLabel => 'Format rules · set by Wayfinch';

  @override
  String get exportRulesHeading => 'Format rules';

  @override
  String get exportListHeading => 'My list';

  @override
  String exportRules(String today, String skeleton) {
    return 'You\'re helping me manage my Wayfinch to-do list. Today is $today.\nReply with ONLY valid JSON in the Wayfinch format, with no other text:\n$skeleton\nEach item has \"type\" (\"task\" or \"event\") and \"title\". It can also have \"notes\", \"priority\" (\"none\", \"low\", \"medium\" or \"high\"), \"tags\" (a list of names), \"recurrence\" (an iCal RRULE like \"FREQ=WEEKLY\", or null) and \"children\" (subtasks, same shape).\nTasks: \"due\" as \"YYYY-MM-DD\" or \"YYYY-MM-DDTHH:mm\" (or null), and \"done\": true when finished.\nEvents: \"start\" and \"end\" as \"YYYY-MM-DDTHH:mm\".\nKeep every existing \"id\" exactly as it is. New items: leave \"id\" out.\nDon\'t remove items unless I ask you to. Don\'t add any other fields.';
  }

  @override
  String exportSummary(int items, int words) {
    final intl.NumberFormat wordsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String wordsString = wordsNumberFormat.format(words);

    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items items',
      one: '1 item',
    );
    return '$_temp0 · about $wordsString words';
  }

  @override
  String get exportSaveFile => 'Save as file';

  @override
  String get exportCopy => 'Copy to clipboard';

  @override
  String get exportCopied => 'Copied! Paste it into your AI.';

  @override
  String get exportSaved => 'Saved.';

  @override
  String get importTitle => 'Import';

  @override
  String get importSubtitle =>
      'Paste your AI\'s whole reply. Extra text around the list is fine.';

  @override
  String get importPaste => 'Paste from clipboard';

  @override
  String get importOpenFile => 'Open file...';

  @override
  String get importReview => 'Review changes';

  @override
  String importUndoLast(String when) {
    return 'Undo last import ($when)';
  }

  @override
  String get importUndoTitle => 'Undo the last import?';

  @override
  String get importUndoBody =>
      'Your list goes back to exactly how it was before that import. Anything you changed since will be lost.';

  @override
  String get importUndoConfirm => 'Undo import';

  @override
  String get importErrorsTitle => 'This reply can\'t be imported yet:';

  @override
  String get importErrorsTip =>
      'Tip: ask your AI to fix these and reply with only the JSON.';

  @override
  String get importWhereList => 'The list';

  @override
  String importWhereItem(int n) {
    return 'Item $n';
  }

  @override
  String importWhereSubtask(int n) {
    return 'subtask $n';
  }

  @override
  String get importErrorNoJson =>
      'No Wayfinch list found in this text. Paste the AI\'s whole reply.';

  @override
  String importErrorInvalidJson(String detail) {
    return 'The JSON is broken: $detail';
  }

  @override
  String get importErrorNotObject =>
      'The reply should be one JSON object (the Wayfinch list), not a list or plain text.';

  @override
  String get importErrorWrongFormat =>
      'This isn\'t a Wayfinch list (\"format\" should be \"wayfinch\").';

  @override
  String get importErrorVersion =>
      'This list was made for a different version of Wayfinch.';

  @override
  String importErrorMissing(String where, String field) {
    return '$where: \"$field\" is missing.';
  }

  @override
  String importErrorWrongType(String where, String field) {
    return '$where: \"$field\" has the wrong kind of value.';
  }

  @override
  String importErrorUnknownField(String where, String field) {
    return '$where: unknown field \"$field\".';
  }

  @override
  String importErrorType(String where) {
    return '$where: \"type\" must be \"task\" or \"event\".';
  }

  @override
  String importErrorEmptyTitle(String where) {
    return '$where: the title is empty.';
  }

  @override
  String importErrorDate(String where, String field) {
    return '$where: \"$field\" should look like 2026-12-05 or 2026-12-05T17:30.';
  }

  @override
  String importErrorPriority(String where) {
    return '$where: \"priority\" must be none, low, medium or high.';
  }

  @override
  String importErrorRecurrence(String where) {
    return '$where: \"recurrence\" isn\'t a valid repeat rule.';
  }

  @override
  String importErrorFieldForType(String where, String field) {
    return '$where: \"$field\" doesn\'t belong on this kind of item.';
  }

  @override
  String importErrorEventTimes(String where, String field) {
    return '$where: events need a \"$field\".';
  }

  @override
  String importErrorEndBeforeStart(String where) {
    return '$where: the event ends before it starts.';
  }

  @override
  String importErrorDuplicateId(String where, String id) {
    return '$where: the id \"$id\" is used twice.';
  }

  @override
  String get importReviewTitle => 'Review your import';

  @override
  String get importValid => 'Wayfinch format · looks good';

  @override
  String get importHow => 'How should this be imported?';

  @override
  String get importAdd => 'Add to my list';

  @override
  String get importAddBody =>
      'New items get added. Nothing is changed or removed.';

  @override
  String get importReplace => 'Replace my list';

  @override
  String get importReplaceBody =>
      'Your list becomes your AI\'s version. History is kept for matching items, and done items stay.';

  @override
  String importNewCount(int count) {
    return '+ $count new';
  }

  @override
  String importChangedCount(int count) {
    return '$count changed';
  }

  @override
  String importRemovedCount(int count) {
    return '$count removed';
  }

  @override
  String importDoneUntouched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done items unaffected',
      one: '1 done item unaffected',
    );
    return '$_temp0';
  }

  @override
  String importRemovedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your AI removed $count items. Make sure that\'s on purpose.',
      one: 'Your AI removed 1 item. Make sure that\'s on purpose.',
    );
    return '$_temp0';
  }

  @override
  String get importNothing => 'Nothing to change. Your list already matches.';

  @override
  String get importBadgeNew => 'New';

  @override
  String get importBadgeChanged => 'Changed';

  @override
  String get importBadgeRemoved => 'Removed';

  @override
  String get importBadgeKept => 'Kept';

  @override
  String get importKeep => 'Keep this item';

  @override
  String get importRemoveAnyway => 'Remove it';

  @override
  String get importBackupNote =>
      'Your current list is backed up first. You can undo this.';

  @override
  String get importBack => 'Back';

  @override
  String importApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count changes',
      one: 'Import 1 change',
      zero: 'Nothing to import',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count changes',
      one: 'Imported 1 change',
    );
    return '$_temp0';
  }

  @override
  String get importNoDate => 'no date';

  @override
  String importWasDue(String when) {
    return 'Was due $when';
  }

  @override
  String importRenamed(String from) {
    return 'Renamed from \"$from\"';
  }

  @override
  String importDue(String from, String to) {
    return 'Due $from → $to';
  }

  @override
  String importStart(String from, String to) {
    return 'Starts $from → $to';
  }

  @override
  String importEnd(String from, String to) {
    return 'Ends $from → $to';
  }

  @override
  String importPriority(String from, String to) {
    return 'Priority $from → $to';
  }

  @override
  String importTagsAdded(String names) {
    return 'Tags added: $names';
  }

  @override
  String importTagsRemoved(String names) {
    return 'Tags removed: $names';
  }

  @override
  String get importNotesChanged => 'Notes changed';

  @override
  String importRepeat(String from, String to) {
    return 'Repeat: $from → $to';
  }

  @override
  String get importMarkedDone => 'Marked done';

  @override
  String get importReopened => 'Reopened';

  @override
  String get importNowEvent => 'Now an event';

  @override
  String get importNowTask => 'Now a task';

  @override
  String get importMovedTop => 'Moved to the top level';

  @override
  String importMovedUnder(String parent) {
    return 'Moved under \"$parent\"';
  }

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingStartView => 'Open Wayfinch in';

  @override
  String get settingsImportHistory => 'Import history';

  @override
  String settingsImportHistoryHelp(int count) {
    return 'Your list is backed up before every import. Restore any of the last $count backups; your current list is backed up first, so you can change your mind.';
  }

  @override
  String get importHistoryEmpty =>
      'No backups yet. One is made before each import.';

  @override
  String get backupBeforeImport => 'Before an import';

  @override
  String backupBeforeImportMode(String mode) {
    return 'Before an import ($mode)';
  }

  @override
  String backupBeforeImportDetail(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Before an import ($mode, $count changes)',
      one: 'Before an import ($mode, 1 change)',
    );
    return '$_temp0';
  }

  @override
  String get backupBeforeRestore => 'Before a restore';

  @override
  String backupItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreTitle => 'Restore this backup?';

  @override
  String get backupRestoreBody =>
      'Your list goes back to exactly how it was at that point. Your current list is backed up first, so you can undo this from Import history.';

  @override
  String get backupRestored => 'Backup restored.';
}
