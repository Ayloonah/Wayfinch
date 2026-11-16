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
  String get tagHint => 'Tag name';

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
  String get changeTagColor => 'Tag color';

  @override
  String get customColor => 'Custom color...';

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
  String get contrastWarningTitle => 'Some text may be hard to read:';

  @override
  String contrastIssue(String what, String ratio) {
    return '$what: $ratio:1 (aim for 4.5:1)';
  }

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
}
