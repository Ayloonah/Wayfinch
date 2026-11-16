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
  String get tagHint => 'Trouver ou créer une étiquette';

  @override
  String createTag(String name) {
    return 'Créer « $name »';
  }

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
  String get promptRememberAnswer => 'Retenir ma réponse';

  @override
  String get promptAlwaysDoThis => 'Toujours faire ça sans demander';

  @override
  String get settingsPrompts => 'Confirmations';

  @override
  String get settingsPromptsHelp =>
      'Choisis si Wayfinch te demande d’abord, ou fait simplement ce que tu as choisi la dernière fois.';

  @override
  String get settingPushParent =>
      'L’échéance d’une sous-tâche dépasse celle de son parent';

  @override
  String get settingCloseSubtasks =>
      'Un parent est marqué comme fait avec des sous-tâches ouvertes';

  @override
  String get settingCompleteParent =>
      'La dernière sous-tâche ouverte est marquée comme faite';

  @override
  String get choiceAsk => 'Me demander';

  @override
  String get choiceAlwaysPushParent => 'Repousser la date du parent';

  @override
  String get choiceAlwaysCloseSubtasks => 'Fermer les sous-tâches';

  @override
  String get choiceAlwaysCompleteParent => 'Marquer le parent comme fait';

  @override
  String get choiceNeverCompleteParent => 'Laisser le parent ouvert';

  @override
  String deletedItem(String title) {
    return '« $title » supprimé';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get addSubtaskTooltip => 'Ajouter une sous-tâche';

  @override
  String subtaskOf(String title) {
    return 'Sous-tâche de $title';
  }

  @override
  String get removeTime => 'Retirer l’heure';

  @override
  String get save => 'Enregistrer';

  @override
  String overdueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments en retard ont besoin d’un nouveau plan',
      one: '1 élément en retard a besoin d’un nouveau plan',
    );
    return '$_temp0';
  }

  @override
  String get overdueReview => 'Voir';

  @override
  String get overdueSnooze => 'Masquer jusqu’à demain';

  @override
  String get overdueTag => 'en retard';

  @override
  String get autoTag => 'auto';

  @override
  String get sidebarTags => 'Étiquettes';

  @override
  String get emptyTag => 'Rien d’ouvert avec cette étiquette.';

  @override
  String get emptyOverdue => 'Rien en retard. Bien joué !';

  @override
  String get changeTagColor => 'Changer la couleur';

  @override
  String get changeTagColorMenu => 'Changer la couleur...';

  @override
  String tagColorTitle(String name) {
    return 'Couleur de « $name »';
  }

  @override
  String get customColor => 'Couleur personnalisée...';

  @override
  String get colorArea => 'Saturation et luminosité';

  @override
  String get colorHue => 'Teinte';

  @override
  String get colorHex => 'Hex';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSetByCustom =>
      'Ton thème personnalisé décide si c’est clair ou sombre.';

  @override
  String get settingsAccent => 'Couleur d’accent';

  @override
  String get accentSky => 'Ciel';

  @override
  String get accentHoney => 'Miel';

  @override
  String get accentMeadow => 'Prairie';

  @override
  String get accentLilac => 'Lilas';

  @override
  String get accentMono => 'Mono';

  @override
  String get accentCustom => 'Personnalisé';

  @override
  String get customThemeTitle => 'Thème personnalisé';

  @override
  String get customStartLight => 'Partir du clair';

  @override
  String get customStartDark => 'Partir du sombre';

  @override
  String get customAccent => 'Accent';

  @override
  String get customBackground => 'Arrière-plan';

  @override
  String get customPanel => 'Panneaux';

  @override
  String get customSidebar => 'Barre latérale';

  @override
  String get customText => 'Texte';

  @override
  String get contrastAllGood => 'Tout devrait être facile à lire.';

  @override
  String get contrastWarningTitle =>
      'Le texte pourrait être difficile à lire ici :';

  @override
  String get contrastTextOnBackground => 'Texte sur l’arrière-plan';

  @override
  String get contrastTextOnPanel => 'Texte sur les panneaux';

  @override
  String get contrastTextOnSidebar => 'Texte sur la barre latérale';

  @override
  String get contrastMutedOnPanel => 'Texte secondaire sur les panneaux';

  @override
  String get contrastTextOnAccent => 'Texte sur les boutons d’accent';

  @override
  String get contrastAccentTextOnPanel =>
      'Texte couleur d’accent sur les panneaux';
}
