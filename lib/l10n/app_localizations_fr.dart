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
}
