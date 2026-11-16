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
  String get exportTitle => 'Export';

  @override
  String get exportSubtitle =>
      'Save or copy your list, or your events as a calendar file.';

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
  String get exportPreview => 'What gets copied';

  @override
  String get exportRulesLabel => 'Format rules · set by Wayfinch';

  @override
  String get exportRulesHeading => 'Format rules';

  @override
  String get exportListHeading => 'My list';

  @override
  String get exportFormatList => 'Your list (JSON)';

  @override
  String get exportFormatCalendar => 'Calendar (.ics)';

  @override
  String get exportCalendarOptions => 'Options';

  @override
  String exportItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String exportCalendarCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calendar events',
      one: '1 calendar event',
    );
    return '$_temp0';
  }

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
  String get exportCopiedPlain => 'Copied.';

  @override
  String get aiMessageButton => 'Message for your AI';

  @override
  String get aiMessageTitle => 'Message for your AI';

  @override
  String get aiMessageSubtitle =>
      'Copy this and paste it into your AI, then tell it what you\'d like (\"plan my final project\"). Bring its reply back here.';

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

  @override
  String greetingMorningName(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoonName(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEveningName(String name) {
    return 'Good evening, $name';
  }

  @override
  String get navHelp => 'AI instructions';

  @override
  String get onboardingStart => 'Let\'s start';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingFinish => 'Let\'s go!';

  @override
  String get onboardingSkipSetup => 'Skip setup';

  @override
  String get onboardingWelcomeTitle => 'Hi, I\'m Wayfinch!';

  @override
  String get onboardingWelcomeBody =>
      'A calm to-do list that works with your AI. Ask your AI to plan something, bring the plan here, and I\'ll help you keep track of it. Setup takes about a minute, or skip it and dive right in.';

  @override
  String get onboardingAboutTitle => 'A bit about you';

  @override
  String get onboardingAboutBody =>
      'Both are optional, and you can change them later in Settings.';

  @override
  String get onboardingNameOptional => 'First name (optional)';

  @override
  String get onboardingPasswordOptional => 'Password (optional)';

  @override
  String get onboardingNameLabel => 'First name';

  @override
  String get onboardingPasswordBody =>
      'With a password, your list is encrypted on disk, so nobody can read the file without it.';

  @override
  String get onboardingVibeTitle => 'Pick your vibe';

  @override
  String get onboardingLookTitle => 'Make it yours';

  @override
  String get onboardingLookBody =>
      'Pick a look and how Wayfinch reminds you. You can change all of this later in Settings.';

  @override
  String get onboardingPreviewLabel => 'Preview of the app in these colors';

  @override
  String get onboardingPreviewItem1 => 'Finish the report';

  @override
  String get onboardingPreviewItem2 => 'Plan the trip';

  @override
  String get onboardingPreviewItem3 => 'Water the plants';

  @override
  String get onboardingNotifTitle => 'Reminders';

  @override
  String get onboardingAiTitle => 'How to use it with your AI';

  @override
  String get onboardingAiBody =>
      'Wayfinch doesn\'t talk to any AI by itself: you stay in control of what\'s shared.';

  @override
  String get aiLoopStep1Title => '1. Copy the message';

  @override
  String get aiLoopStep1Body =>
      'In Import, \"Message for your AI\" copies the format rules and your list.';

  @override
  String get aiLoopStep2Title => '2. Ask your AI';

  @override
  String get aiLoopStep2Body => 'Paste it into any chatbot with your request.';

  @override
  String get aiLoopStep3Title => '3. Import';

  @override
  String get aiLoopStep3Body =>
      'Paste the reply back, review every change, then apply.';

  @override
  String get notifTaskReminder => 'Remind me before tasks are due';

  @override
  String get notifEventReminder => 'Remind me before events start';

  @override
  String get notifDigest => 'Morning digest';

  @override
  String get notifDigestBody => 'A short summary of your day.';

  @override
  String get notifDigestTime => 'Digest time';

  @override
  String get notifLaunchAtStartup => 'Start Wayfinch with Windows';

  @override
  String get notifLaunchAtStartupBody =>
      'Reminders only arrive while Wayfinch is running.';

  @override
  String get notifTrayNote =>
      'Closing the window will keep Wayfinch running quietly in the system tray, so reminders still arrive.';

  @override
  String get reminderNone => 'No reminder';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes before',
      one: '1 minute before',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get reminderAtTime => 'At the time';

  @override
  String reminderDefault(String label) {
    return '$label (default)';
  }

  @override
  String get reminderRemove => 'Remove reminder';

  @override
  String get reminderAdd => 'Add a reminder';

  @override
  String get reminderAddButton => '+ Reminder';

  @override
  String get reminderUseDefault => 'Use default';

  @override
  String get remindersDateOnly =>
      'Add a time to get a reminder. Date-only tasks show up in the morning digest.';

  @override
  String get remindersNeedDate => 'Add a date first.';

  @override
  String get fieldReminders => 'Reminders';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifQuietHours => 'Quiet hours';

  @override
  String get notifQuietHoursBody => 'Reminders wait until quiet hours end.';

  @override
  String get notifQuietFromTo => 'From / to';

  @override
  String get notifSnooze10 => '10 min';

  @override
  String get notifSnooze60 => '1 hour';

  @override
  String get notifSnoozeTomorrow => 'Tomorrow';

  @override
  String notifDueAt(String time) {
    return 'Due at $time';
  }

  @override
  String notifDueOn(String day, String time) {
    return 'Due $day at $time';
  }

  @override
  String notifStartsAt(String time) {
    return 'Starts at $time';
  }

  @override
  String notifStartsOn(String day, String time) {
    return 'Starts $day at $time';
  }

  @override
  String digestTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things on today',
      one: '1 thing on today',
    );
    return '$_temp0';
  }

  @override
  String digestTitleName(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Morning, $name! $count things on today',
      one: 'Morning, $name! 1 thing on today',
    );
    return '$_temp0';
  }

  @override
  String digestMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count more',
      one: '+ 1 more',
    );
    return '$_temp0';
  }

  @override
  String get digestNothing => 'A free day';

  @override
  String get digestNothingBody => 'Nothing due today. Enjoy it!';

  @override
  String get trayOpen => 'Open Wayfinch';

  @override
  String get trayQuit => 'Quit';

  @override
  String get trayHintTitle => 'Wayfinch is still here';

  @override
  String get trayHintBody =>
      'It\'s in the system tray so reminders keep coming. Right-click the icon to quit.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordConfirmLabel => 'Type it again';

  @override
  String get passwordMismatch => 'These don\'t match yet.';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get passwordWarning =>
      'If you forget your password and lose your recovery code, your list can\'t be recovered. Not by you, not by anyone.';

  @override
  String get recoveryTitle => 'Your recovery code';

  @override
  String get recoveryExplain =>
      'If you ever forget your password, this code unlocks your list instead. It\'s shown only once: save it somewhere safe (a password manager, or printed and put away).';

  @override
  String get recoveryAdvice =>
      'If you lose both your password and this code, your list can\'t be recovered. You can change your password or get a new code anytime in Settings › Profile.';

  @override
  String get recoveryCopy => 'Copy';

  @override
  String get recoveryCopied => 'Recovery code copied.';

  @override
  String get recoverySave => 'Save as file';

  @override
  String get recoveryFileHeader =>
      'Wayfinch recovery code. Keep it somewhere safe.';

  @override
  String get recoverySavedCheck => 'I saved my recovery code';

  @override
  String get recoveryDone => 'Done';

  @override
  String get recoveryCodeLabel => 'Recovery code';

  @override
  String get unlockTitle => 'Welcome back';

  @override
  String get unlockHint => 'Enter your password to open your list.';

  @override
  String get unlockRecoveryHint =>
      'Enter the recovery code you saved when you set your password.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockWrongPassword => 'That password didn\'t work.';

  @override
  String get unlockWrongCode => 'That code didn\'t work.';

  @override
  String get unlockUseRecovery =>
      'Forgot your password? Use your recovery code';

  @override
  String get unlockUsePassword => 'Use my password instead';

  @override
  String get newPasswordTitle => 'Choose a new password';

  @override
  String get newPasswordBody =>
      'You opened your list with your recovery code. Pick a new password so next time is easy. Your recovery code keeps working.';

  @override
  String get newPasswordSave => 'Save password';

  @override
  String get newPasswordKeepOld => 'Keep my old password';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get profilePassword => 'Password';

  @override
  String get profilePasswordOn =>
      'On: your list is encrypted on this computer.';

  @override
  String get profilePasswordOff =>
      'Off: anyone with access to this computer could read the file.';

  @override
  String get profileSetPassword => 'Set a password';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileRemovePassword => 'Remove password';

  @override
  String get profileNewRecoveryCode => 'New recovery code';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileRemoveBody =>
      'Your list will no longer be encrypted. You can set a password again anytime.';

  @override
  String get profileNewCodeBody => 'Your old recovery code will stop working.';

  @override
  String get profileTurnOn => 'Turn on password';

  @override
  String get profilePasswordChanged => 'Password changed.';

  @override
  String get tutorialTitle => 'Getting started with Wayfinch';

  @override
  String get tutorialFinished => 'You finished \"Getting started\". Nice work!';

  @override
  String get tutorialNotes =>
      'These steps teach the basics by doing them. Mark this task done anytime to skip the rest.';

  @override
  String get tutorialCheckOff => 'Check this off';

  @override
  String get tutorialCheckOffNotes =>
      'Click the box next to this step. Done items hide themselves; you\'ll find them in Done.';

  @override
  String get tutorialAddSubtask => 'Add a subtask';

  @override
  String get tutorialAddSubtaskNotes =>
      'Open this step (or \"Getting started\") and use \"+ Add subtask\", or hover it in the list and click the +.';

  @override
  String get tutorialTag => 'Give this a tag';

  @override
  String get tutorialTagNotes =>
      'Open this step (or \"Getting started\") and click \"+ Tag\" in its details. Pick a tag or type a new one.';

  @override
  String get tutorialExport => 'Get the message for your AI';

  @override
  String get tutorialExportNotes =>
      'Click Import in the sidebar, then \"Message for your AI\" and Copy. Paste it into your AI with a request, and bring the reply back with Import.';

  @override
  String get helpAiTitle => 'Using Wayfinch with your AI';

  @override
  String get helpAiBody =>
      'Wayfinch doesn\'t talk to any AI by itself, so you stay in control of what\'s shared. In Import, click \"Message for your AI\": it copies the format rules below and your list. Paste it into any AI with your own request (\"plan my final project\"), then paste the AI\'s reply into Import. You\'ll see what\'s new, changed and removed before anything happens. Add only adds new items; Replace makes your list match the AI\'s version (done items are never removed). Your list is backed up first, and you can undo.';

  @override
  String get helpAiRulesTitle => 'The format rules';

  @override
  String get helpAiRulesBody =>
      'This is what your AI is told about the format. Wayfinch adds it to the message for you.';

  @override
  String get importCalendar => 'Import a calendar (.ics)...';

  @override
  String get calendarExportBody =>
      'Save your events as an .ics file, then import it in your calendar app.';

  @override
  String get calendarExportTasks => 'Also export tasks';

  @override
  String get calendarExportTasksBody =>
      'Open tasks become short events at their due time (calendars like Google ignore to-dos).';

  @override
  String get calendarNotIcs =>
      'That doesn\'t look like a calendar (.ics) file.';

  @override
  String get calendarNoEvents => 'There are no events in that file.';

  @override
  String get calendarUntitled => 'Untitled event';

  @override
  String get calendarReviewTitle => 'Review the calendar import';

  @override
  String calendarReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events in the file',
      one: '1 event in the file',
    );
    return '$_temp0';
  }

  @override
  String calendarUpdatedCount(int count) {
    return '$count updated';
  }

  @override
  String calendarUnchanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already up to date',
      one: '1 already up to date',
    );
    return '$_temp0';
  }

  @override
  String get calendarIncludePast => 'Include past events';

  @override
  String calendarPastLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events that already ended are left out.',
      one: '1 event that already ended is left out.',
    );
    return '$_temp0';
  }

  @override
  String calendarSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cancelled or one-off changed events were skipped.',
      one: '1 cancelled or one-off changed event was skipped.',
    );
    return '$_temp0';
  }

  @override
  String get calendarNothing =>
      'Everything in this file is already in your list.';

  @override
  String calendarImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count events',
      one: 'Imported 1 event',
    );
    return '$_temp0';
  }

  @override
  String backupBeforeCalendar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Before a calendar import ($count changes)',
      one: 'Before a calendar import (1 change)',
    );
    return '$_temp0';
  }

  @override
  String get settingsBackups => 'Backups';

  @override
  String settingsBackupsHelp(int count) {
    return 'Wayfinch backs up your whole list once a day and keeps the last $count. With a password, backups are encrypted too.';
  }

  @override
  String get backupsFolder => 'Backup folder';

  @override
  String get backupsChangeFolder => 'Change';

  @override
  String get backupsUseDefault => 'Use default';

  @override
  String get backupsNow => 'Back up now';

  @override
  String get backupsDone => 'Backed up.';

  @override
  String get backupsFailed =>
      'Couldn\'t back up to that folder. Try another one.';

  @override
  String get backupsEmpty =>
      'No daily backups yet. The first one happens today.';

  @override
  String backupsSize(int kb) {
    return '$kb KB';
  }

  @override
  String get backupsUnreadable => 'That backup couldn\'t be opened.';

  @override
  String get backupsOldPasswordTitle => 'Password for this backup';

  @override
  String get backupsOldPasswordBody =>
      'This backup was made with a different password. Enter the password (or recovery code) you had back then.';
}
