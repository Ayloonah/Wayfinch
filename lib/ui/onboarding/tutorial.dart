import 'dart:convert';

import '../../l10n/app_localizations.dart';

/// The tutorial's steps that check themselves off.
enum TutorialStep {
  /// "Check this off": the user checks it.
  checkOff,

  /// "Add a subtask": done when a subtask is added to the tutorial.
  addSubtask,

  /// "Give this a tag": done when the tutorial gets a tag.
  tag,

  /// "Get the message for your AI": done when the message for your AI (or
  /// an export) is copied or saved. Stored as "export" in older databases.
  export,
}

/// Ids of the tutorial's items, saved in settings.
class TutorialSteps {
  /// Creates the ids.
  const TutorialSteps({
    required this.parent,
    required this.checkOff,
    required this.addSubtask,
    required this.tag,
    required this.export,
  });

  /// The "Getting started" task.
  final String parent;

  /// "Check this off".
  final String checkOff;

  /// "Add a subtask".
  final String addSubtask;

  /// "Give this a tag".
  final String tag;

  /// "Export your list for AI".
  final String export;

  /// The item id for [step].
  String idOf(TutorialStep step) => switch (step) {
    TutorialStep.checkOff => checkOff,
    TutorialStep.addSubtask => addSubtask,
    TutorialStep.tag => tag,
    TutorialStep.export => export,
  };

  /// Serializes for settings.
  String encode() => jsonEncode({
    'parent': parent,
    'checkOff': checkOff,
    'addSubtask': addSubtask,
    'tag': tag,
    'export': export,
  });

  /// Reads [encode]'s output, or null.
  static TutorialSteps? decode(String? source) {
    if (source == null) return null;
    try {
      final m = jsonDecode(source) as Map<String, dynamic>;
      return TutorialSteps(
        parent: m['parent'] as String,
        checkOff: m['checkOff'] as String,
        addSubtask: m['addSubtask'] as String,
        tag: m['tag'] as String,
        export: m['export'] as String,
      );
    } on Object {
      return null;
    }
  }
}

/// The tutorial's text, in the app language at the time it's created.
class TutorialTexts {
  /// Creates the texts.
  const TutorialTexts({
    required this.title,
    required this.notes,
    required this.checkOff,
    required this.checkOffNotes,
    required this.addSubtask,
    required this.addSubtaskNotes,
    required this.tag,
    required this.tagNotes,
    required this.export,
    required this.exportNotes,
  });

  /// From the localized strings.
  factory TutorialTexts.of(AppLocalizations l10n) => TutorialTexts(
    title: l10n.tutorialTitle,
    notes: l10n.tutorialNotes,
    checkOff: l10n.tutorialCheckOff,
    checkOffNotes: l10n.tutorialCheckOffNotes,
    addSubtask: l10n.tutorialAddSubtask,
    addSubtaskNotes: l10n.tutorialAddSubtaskNotes,
    tag: l10n.tutorialTag,
    tagNotes: l10n.tutorialTagNotes,
    export: l10n.tutorialExport,
    exportNotes: l10n.tutorialExportNotes,
  );

  /// "Getting started".
  final String title;

  /// Its notes.
  final String notes;

  /// "Check this off".
  final String checkOff;

  /// How.
  final String checkOffNotes;

  /// "Add a subtask".
  final String addSubtask;

  /// How.
  final String addSubtaskNotes;

  /// "Give this a tag".
  final String tag;

  /// How.
  final String tagNotes;

  /// "Export your list for AI".
  final String export;

  /// How.
  final String exportNotes;
}
