import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The app name.
  ///
  /// In en, this message translates to:
  /// **'Wayfinch'**
  String get appTitle;

  /// Sidebar greeting under the logo, by time of day. The first name is added in a later milestone.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get navUpcoming;

  /// No description provided for @navAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get navAll;

  /// No description provided for @navDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get navDone;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Sidebar count next to Done.
  ///
  /// In en, this message translates to:
  /// **'{count} this week'**
  String doneThisWeekShort(int count);

  /// Under the Today title, e.g. 'Sunday, November 15 · 5 tasks, 2 events'.
  ///
  /// In en, this message translates to:
  /// **'{date} · {tasks}, {events}'**
  String todaySubtitle(String date, String tasks, String events);

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @eventCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String eventCount(int count);

  /// No description provided for @upcomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The next 7 days'**
  String get upcomingSubtitle;

  /// No description provided for @allSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing open} =1{1 open item} other{{count} open items}}'**
  String allSubtitle(int count);

  /// Done view progress stat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing done this week yet} =1{1 done this week} other{{count} done this week}}'**
  String doneSubtitle(int count);

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// Title given to an item created with the New item button.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newItemTitle;

  /// No description provided for @quickAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddLabel;

  /// Placeholder of the quick-add field. Keep the example in a form the parser understands.
  ///
  /// In en, this message translates to:
  /// **'Add a task... try \"Lab report Friday 5pm #school !high\"'**
  String get quickAddHint;

  /// No description provided for @sectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get sectionOverdue;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today. Enjoy the calm.'**
  String get emptyToday;

  /// No description provided for @emptyUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for the next 7 days.'**
  String get emptyUpcoming;

  /// No description provided for @emptyAll.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Add one above!'**
  String get emptyAll;

  /// No description provided for @emptyDone.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet. You\'ve got this.'**
  String get emptyDone;

  /// No description provided for @hiddenDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed subtask hidden} other{{count} completed subtasks hidden}}'**
  String hiddenDone(int count);

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @labelToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get labelToday;

  /// No description provided for @labelTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get labelTomorrow;

  /// No description provided for @labelYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get labelYesterday;

  /// A day and a time, e.g. 'Tomorrow, 9:00 AM'.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String dateWithTime(String date, String time);

  /// A day and a time range, e.g. 'Fri, Nov 20 · 2:00 PM – 3:30 PM'.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String dateDotTime(String date, String time);

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String timeRange(String from, String to);

  /// No description provided for @overdueLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {when}'**
  String overdueLabel(String when);

  /// Compact subtask progress in a list row.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String subtaskProgress(int done, int total);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @markNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark not done'**
  String get markNotDone;

  /// No description provided for @priorityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get priorityNone;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Screen-reader label of the priority flag.
  ///
  /// In en, this message translates to:
  /// **'{priority} priority'**
  String priorityFlag(String priority);

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get repeatBiweekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// No description provided for @repeatCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get repeatCustom;

  /// No description provided for @typeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get typeTask;

  /// No description provided for @typeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get typeEvent;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get titleHint;

  /// No description provided for @closeDetails.
  ///
  /// In en, this message translates to:
  /// **'Close details'**
  String get closeDetails;

  /// No description provided for @fieldDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get fieldDue;

  /// No description provided for @fieldStart.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get fieldStart;

  /// No description provided for @fieldEnd.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get fieldEnd;

  /// No description provided for @fieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get fieldPriority;

  /// No description provided for @fieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get fieldTags;

  /// No description provided for @fieldRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get fieldRepeat;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'+ Tag'**
  String get addTag;

  /// No description provided for @tagHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagHint;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeTag(String name);

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @subtasksProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String subtasksProgress(int done, int total);

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'+ Add subtask'**
  String get addSubtask;

  /// No description provided for @subtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Subtask, then Enter'**
  String get subtaskHint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering'**
  String get notesHint;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @markAsNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get markAsNotDone;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItem;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteTitle;

  /// No description provided for @deleteWithSubtasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This also deletes its subtask.} other{This also deletes its {count} subtasks.}}'**
  String deleteWithSubtasks(int count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @promptPushParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Push the parent\'s date?'**
  String get promptPushParentTitle;

  /// No description provided for @promptPushParentBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will also push the parent\'s due date.} other{This will also push the due dates of {count} parent items.}}'**
  String promptPushParentBody(int count);

  /// No description provided for @promptCloseSubtasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the subtasks too?'**
  String get promptCloseSubtasksTitle;

  /// No description provided for @promptCloseSubtasksBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will also close its open subtask.} other{This will also close its {count} open subtasks.}}'**
  String promptCloseSubtasksBody(int count);

  /// No description provided for @promptCompleteParentTitle.
  ///
  /// In en, this message translates to:
  /// **'That was the last one!'**
  String get promptCompleteParentTitle;

  /// No description provided for @promptCompleteParentBody.
  ///
  /// In en, this message translates to:
  /// **'Mark the parent done too?'**
  String get promptCompleteParentBody;

  /// No description provided for @promptConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get promptConfirm;

  /// No description provided for @promptCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get promptCancel;

  /// No description provided for @promptAlways.
  ///
  /// In en, this message translates to:
  /// **'Always do this'**
  String get promptAlways;

  /// No description provided for @settingsPrompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get settingsPrompts;

  /// No description provided for @settingsPromptsHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn a prompt off to always do it without asking.'**
  String get settingsPromptsHelp;

  /// No description provided for @settingAskPushParent.
  ///
  /// In en, this message translates to:
  /// **'Ask before pushing a parent\'s due date'**
  String get settingAskPushParent;

  /// No description provided for @settingAskCloseSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Ask before closing open subtasks'**
  String get settingAskCloseSubtasks;

  /// No description provided for @settingAskCompleteParent.
  ///
  /// In en, this message translates to:
  /// **'Ask before marking a parent done'**
  String get settingAskCompleteParent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
