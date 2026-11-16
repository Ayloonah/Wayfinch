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
  String get useDefaultColor => 'Couleur par défaut';

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

  @override
  String get close => 'Fermer';

  @override
  String get exportTitle => 'Exporter pour l’IA';

  @override
  String get exportSubtitle =>
      'Colle ceci dans ton IA avec ta demande, puis ramène sa réponse avec Importer.';

  @override
  String get exportWhatToInclude => 'Quoi inclure';

  @override
  String get exportOpenTasks => 'Tâches ouvertes';

  @override
  String get exportEvents => 'Événements';

  @override
  String get exportNotes => 'Notes';

  @override
  String get exportDoneItems => 'Éléments faits';

  @override
  String get exportInstructionsHeading => 'Mes instructions';

  @override
  String get exportInstructionsSaved => 'Gardées pour chaque export';

  @override
  String get exportInstructionsHint =>
      'Ce que ton IA devrait toujours savoir. Par exemple :\nDécoupe les grosses tâches en étapes de moins de 2 heures.\nJe suis souvent libre après 16 h en semaine.\nMets l’étiquette « école » sur les trucs d’école.';

  @override
  String get exportPreview => 'Ce qui est copié';

  @override
  String get exportRulesLabel => 'Règles du format · fixées par Wayfinch';

  @override
  String get exportRulesHeading => 'Règles du format';

  @override
  String get exportListHeading => 'Ma liste';

  @override
  String exportRules(String today, String skeleton) {
    return 'Tu m’aides à gérer ma liste de tâches Wayfinch. Nous sommes le $today.\nRéponds UNIQUEMENT avec du JSON valide au format Wayfinch, sans aucun autre texte :\n$skeleton\nChaque élément a \"type\" (\"task\" ou \"event\") et \"title\". Il peut aussi avoir \"notes\", \"priority\" (\"none\", \"low\", \"medium\" ou \"high\"), \"tags\" (une liste de noms), \"recurrence\" (une RRULE iCal comme \"FREQ=WEEKLY\", ou null) et \"children\" (sous-tâches, même forme).\nTâches : \"due\" au format \"YYYY-MM-DD\" ou \"YYYY-MM-DDTHH:mm\" (ou null), et \"done\": true quand c’est fini.\nÉvénements : \"start\" et \"end\" au format \"YYYY-MM-DDTHH:mm\".\nGarde chaque \"id\" existant exactement tel quel. Nouveaux éléments : pas de \"id\".\nNe supprime pas d’éléments sauf si je te le demande. N’ajoute aucun autre champ.';
  }

  @override
  String exportSummary(int items, int words) {
    final intl.NumberFormat wordsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String wordsString = wordsNumberFormat.format(words);

    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items éléments',
      one: '1 élément',
    );
    return '$_temp0 · environ $wordsString mots';
  }

  @override
  String get exportSaveFile => 'Enregistrer dans un fichier';

  @override
  String get exportCopy => 'Copier';

  @override
  String get exportCopied => 'Copié ! Colle-le dans ton IA.';

  @override
  String get exportSaved => 'Enregistré.';

  @override
  String get importTitle => 'Importer';

  @override
  String get importSubtitle =>
      'Colle toute la réponse de ton IA. Le texte autour de la liste ne dérange pas.';

  @override
  String get importPaste => 'Coller';

  @override
  String get importOpenFile => 'Ouvrir un fichier...';

  @override
  String get importReview => 'Voir les changements';

  @override
  String importUndoLast(String when) {
    return 'Annuler le dernier import ($when)';
  }

  @override
  String get importUndoTitle => 'Annuler le dernier import ?';

  @override
  String get importUndoBody =>
      'Ta liste redevient exactement comme avant cet import. Tout ce que tu as changé depuis sera perdu.';

  @override
  String get importUndoConfirm => 'Annuler l’import';

  @override
  String get importErrorsTitle =>
      'Cette réponse ne peut pas encore être importée :';

  @override
  String get importErrorsTip =>
      'Astuce : demande à ton IA de corriger ça et de répondre seulement avec le JSON.';

  @override
  String get importWhereList => 'La liste';

  @override
  String importWhereItem(int n) {
    return 'Élément $n';
  }

  @override
  String importWhereSubtask(int n) {
    return 'sous-tâche $n';
  }

  @override
  String get importErrorNoJson =>
      'Aucune liste Wayfinch trouvée dans ce texte. Colle toute la réponse de l’IA.';

  @override
  String importErrorInvalidJson(String detail) {
    return 'Le JSON est cassé : $detail';
  }

  @override
  String get importErrorNotObject =>
      'La réponse doit être un seul objet JSON (la liste Wayfinch), pas une liste ni du texte.';

  @override
  String get importErrorWrongFormat =>
      'Ce n’est pas une liste Wayfinch (\"format\" doit être \"wayfinch\").';

  @override
  String get importErrorVersion =>
      'Cette liste a été faite pour une autre version de Wayfinch.';

  @override
  String importErrorMissing(String where, String field) {
    return '$where : \"$field\" manque.';
  }

  @override
  String importErrorWrongType(String where, String field) {
    return '$where : \"$field\" n’a pas le bon type de valeur.';
  }

  @override
  String importErrorUnknownField(String where, String field) {
    return '$where : champ inconnu \"$field\".';
  }

  @override
  String importErrorType(String where) {
    return '$where : \"type\" doit être \"task\" ou \"event\".';
  }

  @override
  String importErrorEmptyTitle(String where) {
    return '$where : le titre est vide.';
  }

  @override
  String importErrorDate(String where, String field) {
    return '$where : \"$field\" doit ressembler à 2026-12-05 ou 2026-12-05T17:30.';
  }

  @override
  String importErrorPriority(String where) {
    return '$where : \"priority\" doit être none, low, medium ou high.';
  }

  @override
  String importErrorRecurrence(String where) {
    return '$where : \"recurrence\" n’est pas une règle de répétition valide.';
  }

  @override
  String importErrorFieldForType(String where, String field) {
    return '$where : \"$field\" ne va pas avec ce type d’élément.';
  }

  @override
  String importErrorEventTimes(String where, String field) {
    return '$where : les événements ont besoin de \"$field\".';
  }

  @override
  String importErrorEndBeforeStart(String where) {
    return '$where : l’événement finit avant de commencer.';
  }

  @override
  String importErrorDuplicateId(String where, String id) {
    return '$where : l’id \"$id\" est utilisé deux fois.';
  }

  @override
  String get importReviewTitle => 'Vérifie ton import';

  @override
  String get importValid => 'Format Wayfinch · tout est bon';

  @override
  String get importHow => 'Comment importer ?';

  @override
  String get importAdd => 'Ajouter à ma liste';

  @override
  String get importAddBody =>
      'Les nouveaux éléments sont ajoutés. Rien n’est changé ni supprimé.';

  @override
  String get importReplace => 'Remplacer ma liste';

  @override
  String get importReplaceBody =>
      'Ta liste devient la version de ton IA. L’historique est gardé pour les éléments qui correspondent, et les éléments faits restent.';

  @override
  String importNewCount(int count) {
    return '+ $count nouveaux';
  }

  @override
  String importChangedCount(int count) {
    return '$count modifiés';
  }

  @override
  String importRemovedCount(int count) {
    return '$count supprimés';
  }

  @override
  String importDoneUntouched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments faits non touchés',
      one: '1 élément fait non touché',
    );
    return '$_temp0';
  }

  @override
  String importRemovedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ton IA a supprimé $count éléments. Vérifie que c’est voulu.',
      one: 'Ton IA a supprimé 1 élément. Vérifie que c’est voulu.',
    );
    return '$_temp0';
  }

  @override
  String get importNothing => 'Rien à changer. Ta liste correspond déjà.';

  @override
  String get importBadgeNew => 'Nouveau';

  @override
  String get importBadgeChanged => 'Modifié';

  @override
  String get importBadgeRemoved => 'Supprimé';

  @override
  String get importBadgeKept => 'Gardé';

  @override
  String get importKeep => 'Garder cet élément';

  @override
  String get importRemoveAnyway => 'Le supprimer';

  @override
  String get importBackupNote =>
      'Ta liste actuelle est sauvegardée d’abord. Tu peux annuler.';

  @override
  String get importBack => 'Retour';

  @override
  String importApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count changements',
      one: 'Importer 1 changement',
      zero: 'Rien à importer',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changements importés',
      one: '1 changement importé',
    );
    return '$_temp0';
  }

  @override
  String get importNoDate => 'pas de date';

  @override
  String importWasDue(String when) {
    return 'Échéance : $when';
  }

  @override
  String importRenamed(String from) {
    return 'Renommé (avant : « $from »)';
  }

  @override
  String importDue(String from, String to) {
    return 'Échéance $from → $to';
  }

  @override
  String importStart(String from, String to) {
    return 'Début $from → $to';
  }

  @override
  String importEnd(String from, String to) {
    return 'Fin $from → $to';
  }

  @override
  String importPriority(String from, String to) {
    return 'Priorité $from → $to';
  }

  @override
  String importTagsAdded(String names) {
    return 'Étiquettes ajoutées : $names';
  }

  @override
  String importTagsRemoved(String names) {
    return 'Étiquettes retirées : $names';
  }

  @override
  String get importNotesChanged => 'Notes modifiées';

  @override
  String importRepeat(String from, String to) {
    return 'Répétition : $from → $to';
  }

  @override
  String get importMarkedDone => 'Marqué comme fait';

  @override
  String get importReopened => 'Rouvert';

  @override
  String get importNowEvent => 'Devient un événement';

  @override
  String get importNowTask => 'Devient une tâche';

  @override
  String get importMovedTop => 'Déplacé au premier niveau';

  @override
  String importMovedUnder(String parent) {
    return 'Déplacé sous « $parent »';
  }

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingStartView => 'Ouvrir Wayfinch sur';

  @override
  String get settingsImportHistory => 'Historique des imports';

  @override
  String settingsImportHistoryHelp(int count) {
    return 'Ta liste est sauvegardée avant chaque import. Restaure l’une des $count dernières sauvegardes ; ta liste actuelle est sauvegardée d’abord, donc tu peux changer d’avis.';
  }

  @override
  String get importHistoryEmpty =>
      'Pas encore de sauvegarde. Une est faite avant chaque import.';

  @override
  String get backupBeforeImport => 'Avant un import';

  @override
  String backupBeforeImportMode(String mode) {
    return 'Avant un import ($mode)';
  }

  @override
  String backupBeforeImportDetail(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Avant un import ($mode, $count changements)',
      one: 'Avant un import ($mode, 1 changement)',
    );
    return '$_temp0';
  }

  @override
  String get backupBeforeRestore => 'Avant une restauration';

  @override
  String backupItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get backupRestore => 'Restaurer';

  @override
  String get backupRestoreTitle => 'Restaurer cette sauvegarde ?';

  @override
  String get backupRestoreBody =>
      'Ta liste redevient exactement comme à ce moment-là. Ta liste actuelle est sauvegardée d’abord, donc tu peux annuler depuis l’historique des imports.';

  @override
  String get backupRestored => 'Sauvegarde restaurée.';

  @override
  String greetingMorningName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String greetingAfternoonName(String name) {
    return 'Bon après-midi, $name';
  }

  @override
  String greetingEveningName(String name) {
    return 'Bonsoir, $name';
  }

  @override
  String get navHelp => 'Aide';

  @override
  String get onboardingStart => 'C’est parti';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingSkip => 'Plus tard';

  @override
  String get onboardingFinish => 'Allons-y !';

  @override
  String get onboardingWelcomeTitle => 'Salut, moi c’est Wayfinch !';

  @override
  String get onboardingWelcomeBody =>
      'Une liste de tâches tranquille qui marche avec ton IA. Demande à ton IA de planifier quelque chose, ramène le plan ici, et je t’aide à suivre tout ça. La configuration prend environ une minute.';

  @override
  String get onboardingNameTitle => 'Comment je t’appelle ?';

  @override
  String get onboardingNameBody =>
      'Juste ton prénom. Il sert aux salutations et reste sur cet ordinateur.';

  @override
  String get onboardingNameLabel => 'Prénom';

  @override
  String get onboardingPasswordTitle => 'Un mot de passe ?';

  @override
  String get onboardingPasswordBody =>
      'C’est facultatif. Avec un mot de passe, ta liste est chiffrée sur le disque : personne ne peut lire le fichier sans lui. Tu peux en ajouter ou en retirer un plus tard dans les Paramètres.';

  @override
  String get onboardingVibeTitle => 'Choisis ton style';

  @override
  String get onboardingVibeBody =>
      'Clair ou sombre, et une couleur que tu aimes. Tu pourras créer ton propre thème plus tard dans les Paramètres.';

  @override
  String get onboardingPreviewLabel => 'Aperçu de l’app dans ces couleurs';

  @override
  String get onboardingPreviewItem1 => 'Finir le rapport';

  @override
  String get onboardingPreviewItem2 => 'Planifier le voyage';

  @override
  String get onboardingPreviewItem3 => 'Arroser les plantes';

  @override
  String get onboardingNotifTitle => 'Rappels';

  @override
  String get onboardingNotifBody =>
      'De petits rappels avant les échéances. Tu peux tout changer plus tard, et élément par élément.';

  @override
  String get onboardingAiTitle => 'Comment l’utiliser avec ton IA';

  @override
  String get onboardingAiBody =>
      'Wayfinch ne parle à aucune IA tout seul : c’est toi qui décides de ce qui est partagé.';

  @override
  String get aiLoopStep1Title => '1. Exporter pour l’IA';

  @override
  String get aiLoopStep1Body =>
      'Copie ta liste avec les règles du format et tes instructions.';

  @override
  String get aiLoopStep2Title => '2. Demande à ton IA';

  @override
  String get aiLoopStep2Body =>
      'Colle-la dans n’importe quel chatbot avec ta demande.';

  @override
  String get aiLoopStep3Title => '3. Importer';

  @override
  String get aiLoopStep3Body =>
      'Colle la réponse, vérifie chaque changement, puis applique.';

  @override
  String get notifTaskReminder => 'Me rappeler avant l’échéance des tâches';

  @override
  String get notifEventReminder => 'Me rappeler avant le début des événements';

  @override
  String get notifDigest => 'Résumé du matin';

  @override
  String get notifDigestBody => 'Un petit résumé de ta journée.';

  @override
  String get notifDigestTime => 'Heure du résumé';

  @override
  String get notifLaunchAtStartup => 'Lancer Wayfinch avec Windows';

  @override
  String get notifLaunchAtStartupBody =>
      'Les rappels n’arrivent que si Wayfinch est ouvert.';

  @override
  String get notifTrayNote =>
      'Fermer la fenêtre laissera Wayfinch tourner discrètement dans la zone de notification, pour que les rappels arrivent quand même.';

  @override
  String get reminderNone => 'Pas de rappel';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes avant',
      one: '1 minute avant',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures avant',
      one: '1 heure avant',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours avant',
      one: '1 jour avant',
    );
    return '$_temp0';
  }

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordConfirmLabel => 'Retape-le';

  @override
  String get passwordMismatch => 'Ils ne correspondent pas encore.';

  @override
  String get passwordShow => 'Afficher le mot de passe';

  @override
  String get passwordHide => 'Masquer le mot de passe';

  @override
  String get passwordWarning =>
      'Si tu oublies ton mot de passe et perds ton code de récupération, ta liste est perdue pour de bon. Ni toi ni personne ne pourra la récupérer.';

  @override
  String get recoveryTitle => 'Ton code de récupération';

  @override
  String get recoveryExplain =>
      'Si tu oublies ton mot de passe, ce code ouvre ta liste à sa place. Il n’est affiché qu’une fois : garde-le en lieu sûr (un gestionnaire de mots de passe, ou imprimé et rangé).';

  @override
  String get recoveryCopy => 'Copier';

  @override
  String get recoveryCopied => 'Code de récupération copié.';

  @override
  String get recoverySave => 'Enregistrer dans un fichier';

  @override
  String get recoveryFileHeader =>
      'Code de récupération Wayfinch. Garde-le en lieu sûr.';

  @override
  String get recoverySavedCheck => 'J’ai gardé mon code de récupération';

  @override
  String get recoveryDone => 'Terminé';

  @override
  String get recoveryCodeLabel => 'Code de récupération';

  @override
  String get unlockTitle => 'Content de te revoir';

  @override
  String get unlockHint => 'Entre ton mot de passe pour ouvrir ta liste.';

  @override
  String get unlockRecoveryHint =>
      'Entre le code de récupération gardé quand tu as choisi ton mot de passe.';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get unlockWrongPassword => 'Ce mot de passe n’a pas marché.';

  @override
  String get unlockWrongCode => 'Ce code n’a pas marché.';

  @override
  String get unlockUseRecovery =>
      'Mot de passe oublié ? Utilise ton code de récupération';

  @override
  String get unlockUsePassword => 'Utiliser mon mot de passe';

  @override
  String get newPasswordTitle => 'Choisis un nouveau mot de passe';

  @override
  String get newPasswordBody =>
      'Tu as ouvert ta liste avec ton code de récupération. Choisis un nouveau mot de passe pour la prochaine fois. Ton code de récupération reste valide.';

  @override
  String get newPasswordSave => 'Enregistrer le mot de passe';

  @override
  String get newPasswordKeepOld => 'Garder mon ancien mot de passe';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get profilePassword => 'Mot de passe';

  @override
  String get profilePasswordOn =>
      'Activé : ta liste est chiffrée sur cet ordinateur.';

  @override
  String get profilePasswordOff =>
      'Désactivé : toute personne ayant accès à cet ordinateur pourrait lire le fichier.';

  @override
  String get profileSetPassword => 'Choisir un mot de passe';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileRemovePassword => 'Retirer le mot de passe';

  @override
  String get profileNewRecoveryCode => 'Nouveau code de récupération';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileRemoveBody =>
      'Ta liste ne sera plus chiffrée. Tu pourras remettre un mot de passe quand tu veux.';

  @override
  String get profileNewCodeBody =>
      'Ton ancien code de récupération ne marchera plus.';

  @override
  String get profileTurnOn => 'Activer le mot de passe';

  @override
  String get profilePasswordChanged => 'Mot de passe changé.';

  @override
  String get tutorialTitle => 'Premiers pas avec Wayfinch';

  @override
  String get tutorialFinished => 'Tu as terminé « Premiers pas ». Bravo !';

  @override
  String get tutorialNotes =>
      'Ces étapes t’apprennent les bases en les faisant. Marque cette tâche comme faite quand tu veux pour passer le reste.';

  @override
  String get tutorialCheckOff => 'Coche cette étape';

  @override
  String get tutorialCheckOffNotes =>
      'Clique sur la case à côté de cette étape. Les éléments faits se cachent ; tu les retrouves dans Fait.';

  @override
  String get tutorialAddSubtask => 'Ajoute une sous-tâche';

  @override
  String get tutorialAddSubtaskNotes =>
      'Ouvre cette étape (ou « Premiers pas ») et utilise « + Ajouter une sous-tâche », ou survole-la dans la liste et clique sur le +.';

  @override
  String get tutorialTag => 'Donne-lui une étiquette';

  @override
  String get tutorialTagNotes =>
      'Ouvre cette étape (ou « Premiers pas ») et clique sur « + Étiquette » dans ses détails. Choisis une étiquette ou tapes-en une nouvelle.';

  @override
  String get tutorialExport => 'Exporte ta liste pour l’IA';

  @override
  String get tutorialExportNotes =>
      'Clique sur « Exporter pour l’IA » dans la barre latérale, puis Copier. Colle-la dans ton IA avec une demande, et ramène la réponse avec Importer.';

  @override
  String get helpSearch => 'Chercher dans l’aide';

  @override
  String get helpNoResults => 'Rien trouvé. Essaie un autre mot.';

  @override
  String get helpBasicsTitle => 'Se repérer';

  @override
  String get helpBasicsBody =>
      'Aujourd’hui montre d’abord les éléments en retard, puis ce qui est dû ou prévu aujourd’hui. À venir montre les 7 prochains jours, Tout montre l’ensemble en arbre, et Fait garde ce que tu as terminé, avec ton total de la semaine. Fais glisser les vues et les étiquettes dans la barre latérale pour les réordonner, et choisis la vue d’ouverture dans Paramètres › Général.\n\nL’ajout rapide comprend les dates, heures, étiquettes et priorités, en français et en anglais : essaie « Rapport vendredi 17h #école !haute » ou « Lab report Friday 5pm #school !high ».';

  @override
  String get helpItemsTitle => 'Tâches et événements';

  @override
  String get helpItemsBody =>
      'Les tâches ont une échéance (avec une heure facultative) ; les événements vont d’un début à une fin. Clique sur un élément pour le modifier dans le panneau de droite ; tout s’enregistre au fur et à mesure. La date et l’heure se choisissent ensemble. Supprimer affiche Annuler pendant 10 secondes.';

  @override
  String get helpNestingTitle => 'Sous-tâches';

  @override
  String get helpNestingBody =>
      'Découpe autant que tu veux : « + Ajouter une sous-tâche » dans les détails, ou le + sur une ligne. Certaines situations demandent d’abord : repousser la date d’un parent quand une sous-tâche la dépasse, fermer les sous-tâches ouvertes quand un parent est fait, et marquer un parent comme fait quand sa dernière sous-tâche l’est. Coche « ne plus demander » pour retenir ta réponse ; change-la quand tu veux dans Paramètres › Confirmations.';

  @override
  String get helpRecurringTitle => 'Éléments répétés';

  @override
  String get helpRecurringBody =>
      'Utilise Répéter dans les détails : tous les jours, en semaine, chaque semaine, toutes les 2 semaines, chaque mois ou chaque année. Terminer une tâche répétée crée la suivante, avec de nouvelles copies de ses sous-tâches. Les événements répétés avancent tout seuls une fois finis.';

  @override
  String get helpTagsTitle => 'Étiquettes et retards';

  @override
  String get helpTagsBody =>
      'Ajoute des étiquettes depuis les détails d’un élément. Clique sur une étiquette dans la barre latérale pour voir tout ce qui la porte. Change sa couleur avec son point dans la barre latérale, par clic droit, ou depuis le menu d’une pastille. Les éléments en retard reçoivent l’étiquette automatique « en retard », et une bannière propose de les revoir ou de la masquer jusqu’à demain.';

  @override
  String get helpAiTitle => 'Utiliser Wayfinch avec ton IA';

  @override
  String get helpAiBody =>
      'Exporter pour l’IA copie ta liste avec les règles du format ci-dessous et tes propres instructions. Colle-la dans n’importe quelle IA avec une demande (« planifie mon projet final »), puis colle la réponse dans Importer. Tu vois ce qui est nouveau, modifié et supprimé avant que quoi que ce soit change. Ajouter ajoute seulement les nouveaux éléments ; Remplacer aligne ta liste sur la version de l’IA (les éléments faits ne sont jamais supprimés). Ta liste est sauvegardée d’abord, et tu peux annuler.';

  @override
  String get helpThemesTitle => 'Thèmes';

  @override
  String get helpThemesBody =>
      'Paramètres › Apparence propose clair, sombre ou système, cinq couleurs d’accent et un créateur de thème qui te prévient quand le texte risque d’être difficile à lire.';

  @override
  String get helpPasswordTitle => 'Mot de passe et code de récupération';

  @override
  String get helpPasswordBody =>
      'Un mot de passe chiffre ta liste sur cet ordinateur. Quand tu en choisis un, tu reçois un code de récupération : il ouvre ta liste si tu oublies le mot de passe. Si tu perds les deux, ta liste est perdue. Gère les deux dans Paramètres › Profil.';

  @override
  String get helpBackupsTitle => 'Sauvegardes et annulation';

  @override
  String get helpBackupsBody =>
      'Ta liste est sauvegardée avant chaque import. Annule le dernier import depuis la fenêtre Importer, ou restaure l’une des 10 dernières sauvegardes depuis Paramètres › Historique des imports. Restaurer sauvegarde d’abord ta liste actuelle, donc tu peux changer d’avis.';
}
