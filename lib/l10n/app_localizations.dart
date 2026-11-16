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
