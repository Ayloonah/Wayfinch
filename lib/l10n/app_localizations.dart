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
  /// **'Find or create a tag'**
  String get tagHint;

  /// Tag picker option that creates a new tag.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String createTag(String name);

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

  /// Checkbox in the 'Mark the parent done too?' prompt: remembers Confirm or Cancel.
  ///
  /// In en, this message translates to:
  /// **'Remember my answer'**
  String get promptRememberAnswer;

  /// Checkbox in the push-parent and close-subtasks prompts: only takes effect with Confirm.
  ///
  /// In en, this message translates to:
  /// **'Always do this without asking'**
  String get promptAlwaysDoThis;

  /// No description provided for @settingsPrompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get settingsPrompts;

  /// No description provided for @settingsPromptsHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose whether Wayfinch asks you first, or just does what you picked last time.'**
  String get settingsPromptsHelp;

  /// No description provided for @settingPushParent.
  ///
  /// In en, this message translates to:
  /// **'A subtask\'s due date moves past its parent\'s'**
  String get settingPushParent;

  /// No description provided for @settingCloseSubtasks.
  ///
  /// In en, this message translates to:
  /// **'A parent is marked done with open subtasks'**
  String get settingCloseSubtasks;

  /// No description provided for @settingCompleteParent.
  ///
  /// In en, this message translates to:
  /// **'The last open subtask is marked done'**
  String get settingCompleteParent;

  /// No description provided for @choiceAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask me'**
  String get choiceAsk;

  /// No description provided for @choiceAlwaysPushParent.
  ///
  /// In en, this message translates to:
  /// **'Push the parent\'s date'**
  String get choiceAlwaysPushParent;

  /// No description provided for @choiceAlwaysCloseSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Close the subtasks'**
  String get choiceAlwaysCloseSubtasks;

  /// No description provided for @choiceAlwaysCompleteParent.
  ///
  /// In en, this message translates to:
  /// **'Mark the parent done'**
  String get choiceAlwaysCompleteParent;

  /// No description provided for @choiceNeverCompleteParent.
  ///
  /// In en, this message translates to:
  /// **'Leave the parent open'**
  String get choiceNeverCompleteParent;

  /// Message shown after deleting, with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\"'**
  String deletedItem(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @addSubtaskTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a subtask'**
  String get addSubtaskTooltip;

  /// Link at the top of a subtask's details that opens its parent.
  ///
  /// In en, this message translates to:
  /// **'Subtask of {title}'**
  String subtaskOf(String title);

  /// No description provided for @removeTime.
  ///
  /// In en, this message translates to:
  /// **'Remove time'**
  String get removeTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Overdue banner at the top of every view.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue item needs a new plan} other{{count} overdue items need a new plan}}'**
  String overdueBanner(int count);

  /// No description provided for @overdueReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get overdueReview;

  /// No description provided for @overdueSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze until tomorrow'**
  String get overdueSnooze;

  /// Name of the automatic tag for overdue items (lowercase like user tags).
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get overdueTag;

  /// Small badge marking the overdue tag as automatic.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get autoTag;

  /// No description provided for @sidebarTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get sidebarTags;

  /// No description provided for @emptyTag.
  ///
  /// In en, this message translates to:
  /// **'Nothing open with this tag.'**
  String get emptyTag;

  /// No description provided for @emptyOverdue.
  ///
  /// In en, this message translates to:
  /// **'Nothing overdue. Nicely done!'**
  String get emptyOverdue;

  /// No description provided for @changeTagColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get changeTagColor;

  /// No description provided for @changeTagColorMenu.
  ///
  /// In en, this message translates to:
  /// **'Change color...'**
  String get changeTagColorMenu;

  /// Title of the tag color dialog.
  ///
  /// In en, this message translates to:
  /// **'Color for \"{name}\"'**
  String tagColorTitle(String name);

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color...'**
  String get customColor;

  /// No description provided for @useDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get useDefaultColor;

  /// No description provided for @colorArea.
  ///
  /// In en, this message translates to:
  /// **'Saturation and brightness'**
  String get colorArea;

  /// No description provided for @colorHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get colorHue;

  /// No description provided for @colorHex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get colorHex;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSetByCustom.
  ///
  /// In en, this message translates to:
  /// **'Your custom theme decides light or dark.'**
  String get themeSetByCustom;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get settingsAccent;

  /// No description provided for @accentSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get accentSky;

  /// No description provided for @accentHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get accentHoney;

  /// No description provided for @accentMeadow.
  ///
  /// In en, this message translates to:
  /// **'Meadow'**
  String get accentMeadow;

  /// No description provided for @accentLilac.
  ///
  /// In en, this message translates to:
  /// **'Lilac'**
  String get accentLilac;

  /// No description provided for @accentMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get accentMono;

  /// No description provided for @accentCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get accentCustom;

  /// No description provided for @customThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom theme'**
  String get customThemeTitle;

  /// No description provided for @customStartLight.
  ///
  /// In en, this message translates to:
  /// **'Start from light'**
  String get customStartLight;

  /// No description provided for @customStartDark.
  ///
  /// In en, this message translates to:
  /// **'Start from dark'**
  String get customStartDark;

  /// No description provided for @customAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get customAccent;

  /// No description provided for @customBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get customBackground;

  /// No description provided for @customPanel.
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get customPanel;

  /// No description provided for @customSidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get customSidebar;

  /// No description provided for @customText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get customText;

  /// No description provided for @contrastAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything should be easy to read.'**
  String get contrastAllGood;

  /// No description provided for @contrastWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Text may be hard to read here:'**
  String get contrastWarningTitle;

  /// No description provided for @contrastTextOnBackground.
  ///
  /// In en, this message translates to:
  /// **'Text on the background'**
  String get contrastTextOnBackground;

  /// No description provided for @contrastTextOnPanel.
  ///
  /// In en, this message translates to:
  /// **'Text on panels'**
  String get contrastTextOnPanel;

  /// No description provided for @contrastTextOnSidebar.
  ///
  /// In en, this message translates to:
  /// **'Text on the sidebar'**
  String get contrastTextOnSidebar;

  /// No description provided for @contrastMutedOnPanel.
  ///
  /// In en, this message translates to:
  /// **'Secondary text on panels'**
  String get contrastMutedOnPanel;

  /// No description provided for @contrastTextOnAccent.
  ///
  /// In en, this message translates to:
  /// **'Text on accent buttons'**
  String get contrastTextOnAccent;

  /// No description provided for @contrastAccentTextOnPanel.
  ///
  /// In en, this message translates to:
  /// **'Accent-colored text on panels'**
  String get contrastAccentTextOnPanel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export for AI'**
  String get exportTitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste this into your AI with your request, then bring its reply back with Import.'**
  String get exportSubtitle;

  /// No description provided for @exportWhatToInclude.
  ///
  /// In en, this message translates to:
  /// **'What to include'**
  String get exportWhatToInclude;

  /// No description provided for @exportOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get exportOpenTasks;

  /// No description provided for @exportEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get exportEvents;

  /// No description provided for @exportNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get exportNotes;

  /// No description provided for @exportDoneItems.
  ///
  /// In en, this message translates to:
  /// **'Done items'**
  String get exportDoneItems;

  /// No description provided for @exportInstructionsHeading.
  ///
  /// In en, this message translates to:
  /// **'My instructions'**
  String get exportInstructionsHeading;

  /// No description provided for @exportInstructionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for every export'**
  String get exportInstructionsSaved;

  /// No description provided for @exportInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Anything your AI should always know. For example:\nBreak big tasks into steps under 2 hours.\nI\'m usually free after 4 PM on weekdays.\nTag school stuff with \"school\".'**
  String get exportInstructionsHint;

  /// No description provided for @exportPreview.
  ///
  /// In en, this message translates to:
  /// **'What gets copied'**
  String get exportPreview;

  /// No description provided for @exportRulesLabel.
  ///
  /// In en, this message translates to:
  /// **'Format rules · set by Wayfinch'**
  String get exportRulesLabel;

  /// No description provided for @exportRulesHeading.
  ///
  /// In en, this message translates to:
  /// **'Format rules'**
  String get exportRulesHeading;

  /// No description provided for @exportListHeading.
  ///
  /// In en, this message translates to:
  /// **'My list'**
  String get exportListHeading;

  /// The locked format rules sent to the AI. Keep the JSON keys and values in English exactly as written. {skeleton} is the top-level JSON shape.
  ///
  /// In en, this message translates to:
  /// **'You\'re helping me manage my Wayfinch to-do list. Today is {today}.\nReply with ONLY valid JSON in the Wayfinch format, with no other text:\n{skeleton}\nEach item has \"type\" (\"task\" or \"event\") and \"title\". It can also have \"notes\", \"priority\" (\"none\", \"low\", \"medium\" or \"high\"), \"tags\" (a list of names), \"recurrence\" (an iCal RRULE like \"FREQ=WEEKLY\", or null) and \"children\" (subtasks, same shape).\nTasks: \"due\" as \"YYYY-MM-DD\" or \"YYYY-MM-DDTHH:mm\" (or null), and \"done\": true when finished.\nEvents: \"start\" and \"end\" as \"YYYY-MM-DDTHH:mm\".\nKeep every existing \"id\" exactly as it is. New items: leave \"id\" out.\nDon\'t remove items unless I ask you to. Don\'t add any other fields.'**
  String exportRules(String today, String skeleton);

  /// No description provided for @exportSummary.
  ///
  /// In en, this message translates to:
  /// **'{items, plural, =1{1 item} other{{items} items}} · about {words} words'**
  String exportSummary(int items, int words);

  /// No description provided for @exportSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Save as file'**
  String get exportSaveFile;

  /// No description provided for @exportCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get exportCopy;

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied! Paste it into your AI.'**
  String get exportCopied;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get exportSaved;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste your AI\'s whole reply. Extra text around the list is fine.'**
  String get importSubtitle;

  /// No description provided for @importPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get importPaste;

  /// No description provided for @importOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open file...'**
  String get importOpenFile;

  /// No description provided for @importReview.
  ///
  /// In en, this message translates to:
  /// **'Review changes'**
  String get importReview;

  /// No description provided for @importUndoLast.
  ///
  /// In en, this message translates to:
  /// **'Undo last import ({when})'**
  String importUndoLast(String when);

  /// No description provided for @importUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo the last import?'**
  String get importUndoTitle;

  /// No description provided for @importUndoBody.
  ///
  /// In en, this message translates to:
  /// **'Your list goes back to exactly how it was before that import. Anything you changed since will be lost.'**
  String get importUndoBody;

  /// No description provided for @importUndoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo import'**
  String get importUndoConfirm;

  /// No description provided for @importErrorsTitle.
  ///
  /// In en, this message translates to:
  /// **'This reply can\'t be imported yet:'**
  String get importErrorsTitle;

  /// No description provided for @importErrorsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: ask your AI to fix these and reply with only the JSON.'**
  String get importErrorsTip;

  /// No description provided for @importWhereList.
  ///
  /// In en, this message translates to:
  /// **'The list'**
  String get importWhereList;

  /// No description provided for @importWhereItem.
  ///
  /// In en, this message translates to:
  /// **'Item {n}'**
  String importWhereItem(int n);

  /// No description provided for @importWhereSubtask.
  ///
  /// In en, this message translates to:
  /// **'subtask {n}'**
  String importWhereSubtask(int n);

  /// No description provided for @importErrorNoJson.
  ///
  /// In en, this message translates to:
  /// **'No Wayfinch list found in this text. Paste the AI\'s whole reply.'**
  String get importErrorNoJson;

  /// No description provided for @importErrorInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'The JSON is broken: {detail}'**
  String importErrorInvalidJson(String detail);

  /// No description provided for @importErrorNotObject.
  ///
  /// In en, this message translates to:
  /// **'The reply should be one JSON object (the Wayfinch list), not a list or plain text.'**
  String get importErrorNotObject;

  /// No description provided for @importErrorWrongFormat.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a Wayfinch list (\"format\" should be \"wayfinch\").'**
  String get importErrorWrongFormat;

  /// No description provided for @importErrorVersion.
  ///
  /// In en, this message translates to:
  /// **'This list was made for a different version of Wayfinch.'**
  String get importErrorVersion;

  /// No description provided for @importErrorMissing.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"{field}\" is missing.'**
  String importErrorMissing(String where, String field);

  /// No description provided for @importErrorWrongType.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"{field}\" has the wrong kind of value.'**
  String importErrorWrongType(String where, String field);

  /// No description provided for @importErrorUnknownField.
  ///
  /// In en, this message translates to:
  /// **'{where}: unknown field \"{field}\".'**
  String importErrorUnknownField(String where, String field);

  /// No description provided for @importErrorType.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"type\" must be \"task\" or \"event\".'**
  String importErrorType(String where);

  /// No description provided for @importErrorEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'{where}: the title is empty.'**
  String importErrorEmptyTitle(String where);

  /// No description provided for @importErrorDate.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"{field}\" should look like 2026-12-05 or 2026-12-05T17:30.'**
  String importErrorDate(String where, String field);

  /// No description provided for @importErrorPriority.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"priority\" must be none, low, medium or high.'**
  String importErrorPriority(String where);

  /// No description provided for @importErrorRecurrence.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"recurrence\" isn\'t a valid repeat rule.'**
  String importErrorRecurrence(String where);

  /// No description provided for @importErrorFieldForType.
  ///
  /// In en, this message translates to:
  /// **'{where}: \"{field}\" doesn\'t belong on this kind of item.'**
  String importErrorFieldForType(String where, String field);

  /// No description provided for @importErrorEventTimes.
  ///
  /// In en, this message translates to:
  /// **'{where}: events need a \"{field}\".'**
  String importErrorEventTimes(String where, String field);

  /// No description provided for @importErrorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'{where}: the event ends before it starts.'**
  String importErrorEndBeforeStart(String where);

  /// No description provided for @importErrorDuplicateId.
  ///
  /// In en, this message translates to:
  /// **'{where}: the id \"{id}\" is used twice.'**
  String importErrorDuplicateId(String where, String id);

  /// No description provided for @importReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your import'**
  String get importReviewTitle;

  /// No description provided for @importValid.
  ///
  /// In en, this message translates to:
  /// **'Wayfinch format · looks good'**
  String get importValid;

  /// No description provided for @importHow.
  ///
  /// In en, this message translates to:
  /// **'How should this be imported?'**
  String get importHow;

  /// No description provided for @importAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to my list'**
  String get importAdd;

  /// No description provided for @importAddBody.
  ///
  /// In en, this message translates to:
  /// **'New items get added. Nothing is changed or removed.'**
  String get importAddBody;

  /// No description provided for @importReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace my list'**
  String get importReplace;

  /// No description provided for @importReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Your list becomes your AI\'s version. History is kept for matching items, and done items stay.'**
  String get importReplaceBody;

  /// No description provided for @importNewCount.
  ///
  /// In en, this message translates to:
  /// **'+ {count} new'**
  String importNewCount(int count);

  /// No description provided for @importChangedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} changed'**
  String importChangedCount(int count);

  /// No description provided for @importRemovedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} removed'**
  String importRemovedCount(int count);

  /// No description provided for @importDoneUntouched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 done item unaffected} other{{count} done items unaffected}}'**
  String importDoneUntouched(int count);

  /// No description provided for @importRemovedWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your AI removed 1 item. Make sure that\'s on purpose.} other{Your AI removed {count} items. Make sure that\'s on purpose.}}'**
  String importRemovedWarning(int count);

  /// No description provided for @importNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to change. Your list already matches.'**
  String get importNothing;

  /// No description provided for @importBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get importBadgeNew;

  /// No description provided for @importBadgeChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get importBadgeChanged;

  /// No description provided for @importBadgeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get importBadgeRemoved;

  /// No description provided for @importBadgeKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get importBadgeKept;

  /// No description provided for @importKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep this item'**
  String get importKeep;

  /// No description provided for @importRemoveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Remove it'**
  String get importRemoveAnyway;

  /// No description provided for @importBackupNote.
  ///
  /// In en, this message translates to:
  /// **'Your current list is backed up first. You can undo this.'**
  String get importBackupNote;

  /// No description provided for @importBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get importBack;

  /// No description provided for @importApply.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to import} =1{Import 1 change} other{Import {count} changes}}'**
  String importApply(int count);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 change} other{Imported {count} changes}}'**
  String importDone(int count);

  /// No description provided for @importNoDate.
  ///
  /// In en, this message translates to:
  /// **'no date'**
  String get importNoDate;

  /// No description provided for @importWasDue.
  ///
  /// In en, this message translates to:
  /// **'Was due {when}'**
  String importWasDue(String when);

  /// No description provided for @importRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed from \"{from}\"'**
  String importRenamed(String from);

  /// No description provided for @importDue.
  ///
  /// In en, this message translates to:
  /// **'Due {from} → {to}'**
  String importDue(String from, String to);

  /// No description provided for @importStart.
  ///
  /// In en, this message translates to:
  /// **'Starts {from} → {to}'**
  String importStart(String from, String to);

  /// No description provided for @importEnd.
  ///
  /// In en, this message translates to:
  /// **'Ends {from} → {to}'**
  String importEnd(String from, String to);

  /// No description provided for @importPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority {from} → {to}'**
  String importPriority(String from, String to);

  /// No description provided for @importTagsAdded.
  ///
  /// In en, this message translates to:
  /// **'Tags added: {names}'**
  String importTagsAdded(String names);

  /// No description provided for @importTagsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Tags removed: {names}'**
  String importTagsRemoved(String names);

  /// No description provided for @importNotesChanged.
  ///
  /// In en, this message translates to:
  /// **'Notes changed'**
  String get importNotesChanged;

  /// No description provided for @importRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat: {from} → {to}'**
  String importRepeat(String from, String to);

  /// No description provided for @importMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get importMarkedDone;

  /// No description provided for @importReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get importReopened;

  /// No description provided for @importNowEvent.
  ///
  /// In en, this message translates to:
  /// **'Now an event'**
  String get importNowEvent;

  /// No description provided for @importNowTask.
  ///
  /// In en, this message translates to:
  /// **'Now a task'**
  String get importNowTask;

  /// No description provided for @importMovedTop.
  ///
  /// In en, this message translates to:
  /// **'Moved to the top level'**
  String get importMovedTop;

  /// No description provided for @importMovedUnder.
  ///
  /// In en, this message translates to:
  /// **'Moved under \"{parent}\"'**
  String importMovedUnder(String parent);

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingStartView.
  ///
  /// In en, this message translates to:
  /// **'Open Wayfinch in'**
  String get settingStartView;

  /// No description provided for @settingsImportHistory.
  ///
  /// In en, this message translates to:
  /// **'Import history'**
  String get settingsImportHistory;

  /// No description provided for @settingsImportHistoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Your list is backed up before every import. Restore any of the last {count} backups; your current list is backed up first, so you can change your mind.'**
  String settingsImportHistoryHelp(int count);

  /// No description provided for @importHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backups yet. One is made before each import.'**
  String get importHistoryEmpty;

  /// No description provided for @backupBeforeImport.
  ///
  /// In en, this message translates to:
  /// **'Before an import'**
  String get backupBeforeImport;

  /// No description provided for @backupBeforeImportMode.
  ///
  /// In en, this message translates to:
  /// **'Before an import ({mode})'**
  String backupBeforeImportMode(String mode);

  /// No description provided for @backupBeforeImportDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Before an import ({mode}, 1 change)} other{Before an import ({mode}, {count} changes)}}'**
  String backupBeforeImportDetail(String mode, int count);

  /// No description provided for @backupBeforeRestore.
  ///
  /// In en, this message translates to:
  /// **'Before a restore'**
  String get backupBeforeRestore;

  /// No description provided for @backupItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String backupItemCount(int count);

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Your list goes back to exactly how it was at that point. Your current list is backed up first, so you can undo this from Import history.'**
  String get backupRestoreBody;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @greetingMorningName.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorningName(String name);

  /// No description provided for @greetingAfternoonName.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoonName(String name);

  /// No description provided for @greetingEveningName.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEveningName(String name);

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get onboardingStart;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkip;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get onboardingFinish;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Wayfinch!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A calm to-do list that works with your AI. Ask your AI to plan something, bring the plan here, and I\'ll help you keep track of it. Setup takes about a minute.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameBody.
  ///
  /// In en, this message translates to:
  /// **'Just your first name. It\'s used for greetings and stays on this computer.'**
  String get onboardingNameBody;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a password?'**
  String get onboardingPasswordTitle;

  /// No description provided for @onboardingPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s optional. With a password, your list is encrypted on disk, so nobody can read the file without it. You can add or remove one later in Settings.'**
  String get onboardingPasswordBody;

  /// No description provided for @onboardingVibeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your vibe'**
  String get onboardingVibeTitle;

  /// No description provided for @onboardingVibeBody.
  ///
  /// In en, this message translates to:
  /// **'Light or dark, and a color you like. You can make your own theme later in Settings.'**
  String get onboardingVibeBody;

  /// No description provided for @onboardingPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview of the app in these colors'**
  String get onboardingPreviewLabel;

  /// No description provided for @onboardingPreviewItem1.
  ///
  /// In en, this message translates to:
  /// **'Finish the report'**
  String get onboardingPreviewItem1;

  /// No description provided for @onboardingPreviewItem2.
  ///
  /// In en, this message translates to:
  /// **'Plan the trip'**
  String get onboardingPreviewItem2;

  /// No description provided for @onboardingPreviewItem3.
  ///
  /// In en, this message translates to:
  /// **'Water the plants'**
  String get onboardingPreviewItem3;

  /// No description provided for @onboardingNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get onboardingNotifTitle;

  /// No description provided for @onboardingNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Gentle nudges before things are due. You can change all of this later, and per item.'**
  String get onboardingNotifBody;

  /// No description provided for @onboardingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use it with your AI'**
  String get onboardingAiTitle;

  /// No description provided for @onboardingAiBody.
  ///
  /// In en, this message translates to:
  /// **'Wayfinch doesn\'t talk to any AI by itself: you stay in control of what\'s shared.'**
  String get onboardingAiBody;

  /// No description provided for @aiLoopStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Export for AI'**
  String get aiLoopStep1Title;

  /// No description provided for @aiLoopStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Copy your list with the format rules and your instructions.'**
  String get aiLoopStep1Body;

  /// No description provided for @aiLoopStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Ask your AI'**
  String get aiLoopStep2Title;

  /// No description provided for @aiLoopStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Paste it into any chatbot with your request.'**
  String get aiLoopStep2Body;

  /// No description provided for @aiLoopStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Import'**
  String get aiLoopStep3Title;

  /// No description provided for @aiLoopStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Paste the reply back, review every change, then apply.'**
  String get aiLoopStep3Body;

  /// No description provided for @notifTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me before tasks are due'**
  String get notifTaskReminder;

  /// No description provided for @notifEventReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me before events start'**
  String get notifEventReminder;

  /// No description provided for @notifDigest.
  ///
  /// In en, this message translates to:
  /// **'Morning digest'**
  String get notifDigest;

  /// No description provided for @notifDigestBody.
  ///
  /// In en, this message translates to:
  /// **'A short summary of your day.'**
  String get notifDigestBody;

  /// No description provided for @notifDigestTime.
  ///
  /// In en, this message translates to:
  /// **'Digest time'**
  String get notifDigestTime;

  /// No description provided for @notifLaunchAtStartup.
  ///
  /// In en, this message translates to:
  /// **'Start Wayfinch with Windows'**
  String get notifLaunchAtStartup;

  /// No description provided for @notifLaunchAtStartupBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders only arrive while Wayfinch is running.'**
  String get notifLaunchAtStartupBody;

  /// No description provided for @notifTrayNote.
  ///
  /// In en, this message translates to:
  /// **'Closing the window will keep Wayfinch running quietly in the system tray, so reminders still arrive.'**
  String get notifTrayNote;

  /// No description provided for @reminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get reminderNone;

  /// No description provided for @reminderMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute before} other{{count} minutes before}}'**
  String reminderMinutes(int count);

  /// No description provided for @reminderHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour before} other{{count} hours before}}'**
  String reminderHours(int count);

  /// No description provided for @reminderDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String reminderDays(int count);

  /// No description provided for @reminderAtTime.
  ///
  /// In en, this message translates to:
  /// **'At the time'**
  String get reminderAtTime;

  /// No description provided for @reminderDefault.
  ///
  /// In en, this message translates to:
  /// **'{label} (default)'**
  String reminderDefault(String label);

  /// No description provided for @reminderRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get reminderRemove;

  /// No description provided for @reminderAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder'**
  String get reminderAdd;

  /// No description provided for @reminderAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ Reminder'**
  String get reminderAddButton;

  /// No description provided for @reminderUseDefault.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get reminderUseDefault;

  /// No description provided for @remindersDateOnly.
  ///
  /// In en, this message translates to:
  /// **'Add a time to get a reminder. Date-only tasks show up in the morning digest.'**
  String get remindersDateOnly;

  /// No description provided for @remindersNeedDate.
  ///
  /// In en, this message translates to:
  /// **'Add a date first.'**
  String get remindersNeedDate;

  /// No description provided for @fieldReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get fieldReminders;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notifQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notifQuietHours;

  /// No description provided for @notifQuietHoursBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders wait until quiet hours end.'**
  String get notifQuietHoursBody;

  /// No description provided for @notifQuietFromTo.
  ///
  /// In en, this message translates to:
  /// **'From / to'**
  String get notifQuietFromTo;

  /// No description provided for @notifSnooze10.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get notifSnooze10;

  /// No description provided for @notifSnooze60.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get notifSnooze60;

  /// No description provided for @notifSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get notifSnoozeTomorrow;

  /// No description provided for @notifDueAt.
  ///
  /// In en, this message translates to:
  /// **'Due at {time}'**
  String notifDueAt(String time);

  /// No description provided for @notifDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {day} at {time}'**
  String notifDueOn(String day, String time);

  /// No description provided for @notifStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String notifStartsAt(String time);

  /// No description provided for @notifStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts {day} at {time}'**
  String notifStartsOn(String day, String time);

  /// No description provided for @digestTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing on today} other{{count} things on today}}'**
  String digestTitle(int count);

  /// No description provided for @digestTitleName.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Morning, {name}! 1 thing on today} other{Morning, {name}! {count} things on today}}'**
  String digestTitleName(String name, int count);

  /// No description provided for @digestMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+ 1 more} other{+ {count} more}}'**
  String digestMore(int count);

  /// No description provided for @digestNothing.
  ///
  /// In en, this message translates to:
  /// **'A free day'**
  String get digestNothing;

  /// No description provided for @digestNothingBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today. Enjoy it!'**
  String get digestNothingBody;

  /// No description provided for @trayOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Wayfinch'**
  String get trayOpen;

  /// No description provided for @trayQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get trayQuit;

  /// No description provided for @trayHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Wayfinch is still here'**
  String get trayHintTitle;

  /// No description provided for @trayHintBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s in the system tray so reminders keep coming. Right-click the icon to quit.'**
  String get trayHintBody;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'These don\'t match yet.'**
  String get passwordMismatch;

  /// No description provided for @passwordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// No description provided for @passwordWarning.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password and lose your recovery code, your list can\'t be recovered. Not by you, not by anyone.'**
  String get passwordWarning;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your recovery code'**
  String get recoveryTitle;

  /// No description provided for @recoveryExplain.
  ///
  /// In en, this message translates to:
  /// **'If you ever forget your password, this code unlocks your list instead. It\'s shown only once: save it somewhere safe (a password manager, or printed and put away).'**
  String get recoveryExplain;

  /// No description provided for @recoveryCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get recoveryCopy;

  /// No description provided for @recoveryCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied.'**
  String get recoveryCopied;

  /// No description provided for @recoverySave.
  ///
  /// In en, this message translates to:
  /// **'Save as file'**
  String get recoverySave;

  /// No description provided for @recoveryFileHeader.
  ///
  /// In en, this message translates to:
  /// **'Wayfinch recovery code. Keep it somewhere safe.'**
  String get recoveryFileHeader;

  /// No description provided for @recoverySavedCheck.
  ///
  /// In en, this message translates to:
  /// **'I saved my recovery code'**
  String get recoverySavedCheck;

  /// No description provided for @recoveryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recoveryDone;

  /// No description provided for @recoveryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCodeLabel;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get unlockTitle;

  /// No description provided for @unlockHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to open your list.'**
  String get unlockHint;

  /// No description provided for @unlockRecoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery code you saved when you set your password.'**
  String get unlockRecoveryHint;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password didn\'t work.'**
  String get unlockWrongPassword;

  /// No description provided for @unlockWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work.'**
  String get unlockWrongCode;

  /// No description provided for @unlockUseRecovery.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password? Use your recovery code'**
  String get unlockUseRecovery;

  /// No description provided for @unlockUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use my password instead'**
  String get unlockUsePassword;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'You opened your list with your recovery code. Pick a new password so next time is easy. Your recovery code keeps working.'**
  String get newPasswordBody;

  /// No description provided for @newPasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get newPasswordSave;

  /// No description provided for @newPasswordKeepOld.
  ///
  /// In en, this message translates to:
  /// **'Keep my old password'**
  String get newPasswordKeepOld;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @profilePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profilePassword;

  /// No description provided for @profilePasswordOn.
  ///
  /// In en, this message translates to:
  /// **'On: your list is encrypted on this computer.'**
  String get profilePasswordOn;

  /// No description provided for @profilePasswordOff.
  ///
  /// In en, this message translates to:
  /// **'Off: anyone with access to this computer could read the file.'**
  String get profilePasswordOff;

  /// No description provided for @profileSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get profileSetPassword;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileRemovePassword.
  ///
  /// In en, this message translates to:
  /// **'Remove password'**
  String get profileRemovePassword;

  /// No description provided for @profileNewRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'New recovery code'**
  String get profileNewRecoveryCode;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Your list will no longer be encrypted. You can set a password again anytime.'**
  String get profileRemoveBody;

  /// No description provided for @profileNewCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Your old recovery code will stop working.'**
  String get profileNewCodeBody;

  /// No description provided for @profileTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on password'**
  String get profileTurnOn;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get profilePasswordChanged;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting started with Wayfinch'**
  String get tutorialTitle;

  /// No description provided for @tutorialFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished \"Getting started\". Nice work!'**
  String get tutorialFinished;

  /// No description provided for @tutorialNotes.
  ///
  /// In en, this message translates to:
  /// **'These steps teach the basics by doing them. Mark this task done anytime to skip the rest.'**
  String get tutorialNotes;

  /// No description provided for @tutorialCheckOff.
  ///
  /// In en, this message translates to:
  /// **'Check this off'**
  String get tutorialCheckOff;

  /// No description provided for @tutorialCheckOffNotes.
  ///
  /// In en, this message translates to:
  /// **'Click the box next to this step. Done items hide themselves; you\'ll find them in Done.'**
  String get tutorialCheckOffNotes;

  /// No description provided for @tutorialAddSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add a subtask'**
  String get tutorialAddSubtask;

  /// No description provided for @tutorialAddSubtaskNotes.
  ///
  /// In en, this message translates to:
  /// **'Open this step (or \"Getting started\") and use \"+ Add subtask\", or hover it in the list and click the +.'**
  String get tutorialAddSubtaskNotes;

  /// No description provided for @tutorialTag.
  ///
  /// In en, this message translates to:
  /// **'Give this a tag'**
  String get tutorialTag;

  /// No description provided for @tutorialTagNotes.
  ///
  /// In en, this message translates to:
  /// **'Open this step (or \"Getting started\") and click \"+ Tag\" in its details. Pick a tag or type a new one.'**
  String get tutorialTagNotes;

  /// No description provided for @tutorialExport.
  ///
  /// In en, this message translates to:
  /// **'Export your list for AI'**
  String get tutorialExport;

  /// No description provided for @tutorialExportNotes.
  ///
  /// In en, this message translates to:
  /// **'Click \"Export for AI\" in the sidebar, then Copy. Paste it into your AI with a request, and bring the reply back with Import.'**
  String get tutorialExportNotes;

  /// No description provided for @helpSearch.
  ///
  /// In en, this message translates to:
  /// **'Search help'**
  String get helpSearch;

  /// No description provided for @helpNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Try another word.'**
  String get helpNoResults;

  /// No description provided for @helpBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting around'**
  String get helpBasicsTitle;

  /// No description provided for @helpBasicsBody.
  ///
  /// In en, this message translates to:
  /// **'Today shows overdue items first, then what\'s due or happening today. Upcoming shows the next 7 days, All shows everything as a tree, and Done keeps what you finished, with your weekly count. Drag views and tags in the sidebar to reorder them, and pick the view Wayfinch opens in under Settings › General.\n\nQuick add understands dates, times, tags and priority, in English and French: try \"Lab report Friday 5pm #school !high\" or \"Rapport vendredi 17h #école !haute\".'**
  String get helpBasicsBody;

  /// No description provided for @helpItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks and events'**
  String get helpItemsTitle;

  /// No description provided for @helpItemsBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks are due by a date (with an optional time); events run from a start to an end. Click an item to edit it in the panel on the right; changes save as you go. Date and time are set together in one dialog. Deleting shows an Undo for 10 seconds.'**
  String get helpItemsBody;

  /// No description provided for @helpNestingTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get helpNestingTitle;

  /// No description provided for @helpNestingBody.
  ///
  /// In en, this message translates to:
  /// **'Break things down as far as you like: use \"+ Add subtask\" in the details, or the + on a list row. A few situations ask first: pushing a parent\'s date when a subtask goes past it, closing open subtasks when a parent is done, and marking a parent done when its last subtask is. Tick \"don\'t ask again\" to remember your answer; change it anytime in Settings › Prompts.'**
  String get helpNestingBody;

  /// No description provided for @helpRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeating items'**
  String get helpRecurringTitle;

  /// No description provided for @helpRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'Use Repeat in the details: daily, weekdays, weekly, every 2 weeks, monthly or yearly. Completing a repeating task creates the next one, with fresh copies of its subtasks. Repeating events roll forward on their own once they end.'**
  String get helpRecurringBody;

  /// No description provided for @helpTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags and overdue'**
  String get helpTagsTitle;

  /// No description provided for @helpTagsBody.
  ///
  /// In en, this message translates to:
  /// **'Add tags from an item\'s details. Click a tag in the sidebar to see everything with it. Change a tag\'s color from its dot in the sidebar, by right-clicking it, or from a tag chip\'s menu. Overdue items get the automatic \"overdue\" tag, and a banner offers to review them or snooze it until tomorrow.'**
  String get helpTagsBody;

  /// No description provided for @helpAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Using Wayfinch with your AI'**
  String get helpAiTitle;

  /// No description provided for @helpAiBody.
  ///
  /// In en, this message translates to:
  /// **'Export for AI copies your list with the format rules below and your own instructions. Paste it into any AI with a request (\"plan my final project\"), then paste the reply into Import. You\'ll see what\'s new, changed and removed before anything happens. Add only adds new items; Replace makes your list match the AI\'s version (done items are never removed). Your list is backed up first, and you can undo.'**
  String get helpAiBody;

  /// No description provided for @helpNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders and notifications'**
  String get helpNotificationsTitle;

  /// No description provided for @helpNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks with a time remind you 1 hour before and events 15 minutes before; change the defaults in Settings › Notifications, or set an item\'s own reminders from its details. Date-only tasks show up in the morning digest instead. Snooze a reminder from its notification. During quiet hours, reminders wait until the end. Closing the window keeps Wayfinch in the system tray so reminders still arrive; right-click the tray icon to quit.'**
  String get helpNotificationsBody;

  /// No description provided for @helpThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get helpThemesTitle;

  /// No description provided for @helpThemesBody.
  ///
  /// In en, this message translates to:
  /// **'Settings › Appearance has light, dark or system, five accent colors, and a custom theme builder that warns you when text may be hard to read.'**
  String get helpThemesBody;

  /// No description provided for @helpPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password and recovery code'**
  String get helpPasswordTitle;

  /// No description provided for @helpPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'A password encrypts your list on this computer. When you set one, you get a recovery code: it can unlock your list if you forget the password. If you lose both, your list can\'t be recovered. Manage both in Settings › Profile.'**
  String get helpPasswordBody;

  /// No description provided for @helpBackupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Backups and undo'**
  String get helpBackupsTitle;

  /// No description provided for @helpBackupsBody.
  ///
  /// In en, this message translates to:
  /// **'Your list is backed up before every import. Undo the last import from the Import dialog, or restore any of the last 10 backups from Settings › Import history. Restoring backs up your current list first, so you can change your mind.'**
  String get helpBackupsBody;
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
