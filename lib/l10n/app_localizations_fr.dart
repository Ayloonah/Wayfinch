// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Wayfinch';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get navToday => 'Aujourd’hui';

  @override
  String get navUpcoming => 'À venir';

  @override
  String get navAll => 'Tout';

  @override
  String get navDone => 'Fait';

  @override
  String get navSettings => 'Paramètres';

  @override
  String doneThisWeekShort(int count) {
    return '$count cette semaine';
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
      other: '$count tâches',
      one: '1 tâche',
      zero: '0 tâche',
    );
    return '$_temp0';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements',
      one: '1 événement',
      zero: '0 événement',
    );
    return '$_temp0';
  }

  @override
  String get upcomingSubtitle => 'Les 7 prochains jours';

  @override
  String allSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments ouverts',
      one: '1 élément ouvert',
      zero: 'Rien d’ouvert',
    );
    return '$_temp0';
  }

  @override
  String doneSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faits cette semaine',
      one: '1 fait cette semaine',
      zero: 'Rien de fait cette semaine pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Nouvel élément';

  @override
  String get newItemTitle => 'Nouvelle tâche';

  @override
  String get quickAddLabel => 'Ajout rapide';

  @override
  String get quickAddHint =>
      'Ajoute une tâche... essaie « Rapport de labo vendredi 17h #école !haute »';

  @override
  String get sectionOverdue => 'En retard';

  @override
  String get sectionToday => 'Aujourd’hui';

  @override
  String get emptyToday => 'Rien pour aujourd’hui. Profite du calme.';

  @override
  String get emptyUpcoming => 'Rien de prévu pour les 7 prochains jours.';

  @override
  String get emptyAll =>
      'Aucun élément pour l’instant. Ajoutes-en un plus haut !';

  @override
  String get emptyDone => 'Rien de fait pour l’instant. Tu vas y arriver.';

  @override
  String hiddenDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sous-tâches terminées masquées',
      one: '1 sous-tâche terminée masquée',
    );
    return '$_temp0';
  }

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get labelToday => 'Aujourd’hui';

  @override
  String get labelTomorrow => 'Demain';

  @override
  String get labelYesterday => 'Hier';

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
    return 'En retard · $when';
  }

  @override
  String subtaskProgress(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get markDone => 'Marquer comme fait';

  @override
  String get markNotDone => 'Marquer comme pas fait';

  @override
  String get priorityNone => 'Aucune';

  @override
  String get priorityLow => 'Basse';

  @override
  String get priorityMedium => 'Moyenne';

  @override
  String get priorityHigh => 'Haute';

  @override
  String priorityFlag(String priority) {
    return 'Priorité $priority';
  }

  @override
  String get repeatNone => 'Ne se répète pas';

  @override
  String get repeatDaily => 'Tous les jours';

  @override
  String get repeatWeekdays => 'En semaine';

  @override
  String get repeatWeekly => 'Chaque semaine';

  @override
  String get repeatBiweekly => 'Toutes les 2 semaines';

  @override
  String get repeatMonthly => 'Chaque mois';

  @override
  String get repeatYearly => 'Chaque année';

  @override
  String get repeatCustom => 'Personnalisé';

  @override
  String get typeTask => 'Tâche';

  @override
  String get typeEvent => 'Événement';

  @override
  String get titleHint => 'Qu’est-ce qu’il faut faire ?';

  @override
  String get closeDetails => 'Fermer les détails';

  @override
  String get fieldDue => 'Échéance';

  @override
  String get fieldStart => 'Début';

  @override
  String get fieldEnd => 'Fin';

  @override
  String get fieldPriority => 'Priorité';

  @override
  String get fieldTags => 'Étiquettes';

  @override
  String get fieldRepeat => 'Répéter';

  @override
  String get noDueDate => 'Pas d’échéance';

  @override
  String get addTime => 'Ajouter une heure';

  @override
  String get clearDate => 'Effacer la date';

  @override
  String get addTag => '+ Étiquette';

  @override
  String get tagHint => 'Nom de l’étiquette';

  @override
  String removeTag(String name) {
    return 'Retirer $name';
  }

  @override
  String get subtasks => 'Sous-tâches';

  @override
  String subtasksProgress(int done, int total) {
    return '$done sur $total faites';
  }

  @override
  String get addSubtask => '+ Ajouter une sous-tâche';

  @override
  String get subtaskHint => 'Sous-tâche, puis Entrée';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Tout ce qui vaut la peine d’être noté';

  @override
  String get markAsDone => 'Marquer comme fait';

  @override
  String get markAsNotDone => 'Marquer comme pas fait';

  @override
  String get deleteItem => 'Supprimer l’élément';

  @override
  String get deleteTitle => 'Supprimer cet élément ?';

  @override
  String deleteWithSubtasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ça supprime aussi ses $count sous-tâches.',
      one: 'Ça supprime aussi sa sous-tâche.',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get promptPushParentTitle => 'Repousser la date du parent ?';

  @override
  String promptPushParentBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ça va aussi repousser l’échéance de $count éléments parents.',
      one: 'Ça va aussi repousser l’échéance du parent.',
    );
    return '$_temp0';
  }

  @override
  String get promptCloseSubtasksTitle => 'Fermer les sous-tâches aussi ?';

  @override
  String promptCloseSubtasksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ça va aussi fermer ses $count sous-tâches ouvertes.',
      one: 'Ça va aussi fermer sa sous-tâche ouverte.',
    );
    return '$_temp0';
  }

  @override
  String get promptCompleteParentTitle => 'C’était la dernière !';

  @override
  String get promptCompleteParentBody => 'Marquer le parent comme fait aussi ?';

  @override
  String get promptConfirm => 'Confirmer';

  @override
  String get promptCancel => 'Annuler';

  @override
  String get promptAlways => 'Toujours faire ça';

  @override
  String get settingsPrompts => 'Confirmations';

  @override
  String get settingsPromptsHelp =>
      'Désactive une confirmation pour toujours le faire sans demander.';

  @override
  String get settingAskPushParent =>
      'Demander avant de repousser l’échéance d’un parent';

  @override
  String get settingAskCloseSubtasks =>
      'Demander avant de fermer les sous-tâches ouvertes';

  @override
  String get settingAskCompleteParent =>
      'Demander avant de marquer un parent comme fait';
}
