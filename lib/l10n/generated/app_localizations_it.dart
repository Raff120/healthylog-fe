// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class L10nIt extends L10n {
  L10nIt([String locale = 'it']) : super(locale);

  @override
  String get activityMeasurements => 'Misure';

  @override
  String get activityWorkouts => 'Allenamenti';

  @override
  String get adherenceBySlotType => 'Per tipo di pasto';

  @override
  String get adherenceByWeekday => 'Per giorno della settimana';

  @override
  String get adherenceOverall => 'Complessivo';

  @override
  String adherencePeriodRange(String start, String end) {
    return 'Periodo dal $start a $end';
  }

  @override
  String get adherenceWeeklyTrend => 'Andamento settimanale';

  @override
  String get bodyMeasurementsTitle => 'Misurazioni';

  @override
  String get bodyStatsNoMeasurements => 'Nessuna misurazione nel periodo';

  @override
  String get bodyStatsNutritionistLegend =>
      'I cerchi vuoti sono le misurazioni rilevate dal nutrizionista.';

  @override
  String get bodyStatsSingleValue =>
      'Un solo valore: nessuna variazione da presentare';

  @override
  String get careLinkActiveHeader => 'COLLEGAMENTO IN CORSO';

  @override
  String get careLinkRevoked =>
      'Collegamento revocato. Hai di nuovo piena facoltà sul tuo piano.';

  @override
  String careLinkedNow(String name) {
    return 'Ora sei collegato a $name.';
  }

  @override
  String careLinkedSince(String date) {
    return 'Dal $date';
  }

  @override
  String get careManagePlanYourself => 'Puoi gestire il piano in autonomia';

  @override
  String get careNoNutritionist => 'Nessun nutrizionista collegato';

  @override
  String get careNutritionistNotice =>
      'Il nutrizionista redige il tuo piano e ne segue l\'andamento. Puoi sempre invertire e spuntare i pasti, ma non modificarne il contenuto.';

  @override
  String get careRequestAccepting => 'Accettando, il nutrizionista:';

  @override
  String get careRequestExpired => 'Decaduta';

  @override
  String get careRequestKeepAfterRevoke =>
      'Potrai revocare il collegamento in qualsiasi momento. Dopo la revoca conserverà solo gli schemi dei piani che ha redatto e le misurazioni che ha registrato personalmente.';

  @override
  String careRequestReceivedOn(String date) {
    return 'Ricevuta il $date';
  }

  @override
  String get careRequestTitle => 'Richiesta di collegamento';

  @override
  String get careRequestWillRead =>
      'accederà in lettura ai tuoi dati nei periodi coperti dai suoi piani';

  @override
  String get careRequestWillRecordMeasurements =>
      'potrà registrare misurazioni per tuo conto';

  @override
  String get careRequestWillWritePlan => 'redigerà il tuo piano alimentare';

  @override
  String get careRequestYouCannotEdit =>
      'e tu non potrai più modificare il contenuto del piano che ti assegna';

  @override
  String get careRequestsReceivedHeader => 'RICHIESTE RICEVUTE';

  @override
  String get careRevokeKeepsList =>
      '• gli schemi dei piani che ha redatto, con il periodo di validità;\n• le misurazioni che ha registrato personalmente;\n• i dati anagrafici essenziali.';

  @override
  String get careRevokeLink => 'Revoca il collegamento';

  @override
  String get careRevokeLosesList =>
      '• spunte, inversioni e statistiche di aderenza;\n• allenamenti e misurazioni registrate dalla persona.';

  @override
  String get careRevokeNutritionistBody =>
      'Il nutrizionista perderà immediatamente ogni accesso ai tuoi dati e ogni facoltà sul tuo piano, che resterà a tua disposizione.';

  @override
  String get careRevokeNutritionistKeeps => 'Il nutrizionista conserverà:';

  @override
  String get careRevokeNutritionistLoses => 'Non conserverà:';

  @override
  String get careRevokeNutritionistSideBody =>
      'Perderai immediatamente ogni accesso ai dati della persona e ogni facoltà sui suoi piani.';

  @override
  String get careRevokeTitle => 'Revocare il collegamento?';

  @override
  String get careRevokeYouKeep => 'Conserverai:';

  @override
  String get careRevokeYouLose => 'Non conserverai:';

  @override
  String get commonAccept => 'Accetta';

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String get commonAll => 'Tutti';

  @override
  String get commonApply => 'Applica';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String get commonContinue => 'Continua';

  @override
  String get commonCopy => 'Copia';

  @override
  String get commonCreate => 'Crea';

  @override
  String get commonDecline => 'Rifiuta';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonDescription => 'Descrizione';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonGenerate => 'Genera';

  @override
  String get commonListAnd => ' e ';

  @override
  String get commonName => 'Denominazione';

  @override
  String get commonNotSet => 'Non impostato';

  @override
  String get commonNote => 'Nota';

  @override
  String get commonRecord => 'Registra';

  @override
  String get commonRegenerate => 'Rigenera';

  @override
  String get commonRemove => 'Rimuovi';

  @override
  String get commonRevoke => 'Revoca';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get commonShare => 'Condividi';

  @override
  String get commonToday => 'Oggi';

  @override
  String get commonUnderstood => 'Ho capito';

  @override
  String get dayPreviewNoSlots => 'Nessuno slot';

  @override
  String get deleteAccountConfirm => 'Richiedi l\'eliminazione';

  @override
  String get deleteAccountConfirmTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountGracePeriod =>
      'La richiesta apre un periodo di ripensamento di sette giorni: durante il periodo l\'account è disattivato e nessun terzo vi accede, ma i dati restano. Accedendo di nuovo la richiesta si annulla.';

  @override
  String get deleteAccountGroupDissolution =>
      'Sei l\'unico membro del tuo gruppo: il gruppo sarà sciolto.';

  @override
  String get deleteAccountGroupSuccession =>
      'Sei Proprietario di un gruppo: la proprietà passerà automaticamente a un altro membro.';

  @override
  String get deleteAccountIntro =>
      'Con l\'eliminazione andranno perduti in modo definitivo:';

  @override
  String get deleteAccountLossActivity => '•  gli allenamenti e le misurazioni';

  @override
  String get deleteAccountLossMemberships =>
      '•  i template, le notifiche e le appartenenze';

  @override
  String get deleteAccountLossPlans =>
      '•  i piani alimentari, le giornate e le spunte';

  @override
  String get deleteAccountLossStatistics =>
      '•  lo storico delle inversioni e le statistiche';

  @override
  String get deleteAccountNutritionistKeeps =>
      'Il tuo nutrizionista conserverà gli schemi dei piani che ha redatto e le misurazioni che ha registrato personalmente, privi dei tuoi dati identificativi.';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String deletionPendingBody(String date) {
    return 'Il tuo account sarà eliminato definitivamente il $date. Fino ad allora puoi annullare la richiesta.';
  }

  @override
  String get deletionPendingCancel => 'Annulla eliminazione';

  @override
  String get deletionPendingTitle => 'Eliminazione richiesta';

  @override
  String get devicesCurrent => '(questo dispositivo)';

  @override
  String devicesLastUsed(String when) {
    return 'Ultimo utilizzo: $when';
  }

  @override
  String get devicesRevoke => 'Revoca';

  @override
  String get devicesRevokeAllOthers =>
      'Disconnetti tutti gli altri dispositivi';

  @override
  String get devicesRevokeAllOthersBody =>
      'Le altre sessioni attive verranno chiuse.';

  @override
  String devicesRevokeConfirm(String device) {
    return 'Disconnettere «$device»?';
  }

  @override
  String get devicesSignOut => 'Disconnetti';

  @override
  String get devicesTitle => 'Dispositivi collegati';

  @override
  String get editAddSnack => 'Aggiungi spuntino';

  @override
  String get editDayConsumedNotEditable => 'Già consumato: non modificabile';

  @override
  String get editDayEditScheduleInstead =>
      'Modifica invece lo schema, per tutte le giornate';

  @override
  String get editDayNotEditable => 'Giornata non modificabile';

  @override
  String get editDayNotEditableReason =>
      'Solo le giornate coperte da un piano attivo possono essere modificate';

  @override
  String get editDayOnlyThisDayNotice =>
      'Le modifiche riguardano solo questa giornata: lo schema settimanale resta invariato.';

  @override
  String get editDaySave => 'Salva giornata';

  @override
  String get editDaySaved => 'Giornata salvata.';

  @override
  String editDayTitle(String date) {
    return 'Giornata del $date';
  }

  @override
  String get editDiscardBody => 'Uscendo perderai le modifiche non salvate.';

  @override
  String get editDiscardConfirm => 'Esci senza salvare';

  @override
  String get editDiscardTitle => 'Modifiche non salvate';

  @override
  String get editRecipeFieldsInvalid =>
      'Controlla i campi della ricetta segnalati.';

  @override
  String get editRecipeNameRequired =>
      'Serve una denominazione se è presente il testo della ricetta';

  @override
  String get editRemoveSlotBody => 'Il contenuto compilato andrà perso.';

  @override
  String get editRemoveSlotTitle => 'Rimuovere lo slot?';

  @override
  String get errorAccountNotVerified =>
      'Conferma prima il tuo indirizzo e-mail.';

  @override
  String get errorAlreadyInGroup =>
      'Fai già parte di un gruppo: esci prima di crearne uno nuovo.';

  @override
  String get errorAlreadyLinked =>
      'La persona è già collegata a un nutrizionista: serve prima la revoca di quel collegamento.';

  @override
  String get errorAuthenticationRequired => 'Devi accedere per continuare.';

  @override
  String get errorCareLinkNotActive => 'Il collegamento è già stato revocato.';

  @override
  String get errorCareLinkRequestAlreadyPending =>
      'Hai già una richiesta in attesa verso questa persona.';

  @override
  String get errorCareLinkRequestNotPending =>
      'Questa richiesta non è più in attesa.';

  @override
  String get errorEmailAlreadyUsed =>
      'Questo indirizzo e-mail è già registrato.';

  @override
  String get errorEmailAlreadyVerified =>
      'Questo indirizzo è già stato verificato.';

  @override
  String get errorGeneric => 'Qualcosa non ha funzionato. Riprova.';

  @override
  String get errorInvalidCredentials => 'Indirizzo o password non corretti.';

  @override
  String get errorInviteCodeInvalid => 'Il codice inserito non è valido.';

  @override
  String get errorNetwork => 'Connessione assente. Riprova.';

  @override
  String get errorNutritionistCannotJoinGroup =>
      'Un Nutrizionista non può appartenere a un gruppo.';

  @override
  String get errorOwnerCookPrivilegeInseparable =>
      'Il Proprietario non può rinunciare al privilegio di Cuoco: trasferisci prima la proprietà.';

  @override
  String get errorPasswordResetTokenInvalid =>
      'Il collegamento non è più valido. Richiedine uno nuovo.';

  @override
  String get errorPasswordTooLong => 'La password è troppo lunga.';

  @override
  String get errorPastDayNotEditable =>
      'Le giornate trascorse non si possono modificare.';

  @override
  String get errorPatientPlanLocked =>
      'Il piano è a cura del tuo nutrizionista: puoi spuntare e invertire, non modificarne il contenuto.';

  @override
  String get errorPlanActiveCannotDelete =>
      'Un piano Attivo non può essere eliminato: sospendilo o concludilo prima.';

  @override
  String get errorPlanIncomplete =>
      'Lo schema settimanale non è ancora completo.';

  @override
  String get errorPlanNotActive =>
      'Questa giornata non è coperta da un piano attivo.';

  @override
  String get errorPlanPeriodOverlap =>
      'Il periodo si sovrappone a un piano esistente.';

  @override
  String get errorPlanScheduleNotEditable =>
      'Lo schema di questo piano non è più modificabile.';

  @override
  String get errorPlanTransitionNotAllowed =>
      'Questa operazione non è più possibile per il piano.';

  @override
  String get errorRefreshTokenInvalid =>
      'La sessione non è più valida. Accedi di nuovo.';

  @override
  String get errorSlotAlreadyConsumed => 'Questo pasto è già stato consumato.';

  @override
  String get errorSwapDifferentDays => 'Devono appartenere allo stesso giorno.';

  @override
  String get errorSwapDifferentWeeks => 'Appartengono a settimane diverse.';

  @override
  String get errorSwapPastDay => 'Questo giorno è già trascorso.';

  @override
  String get errorSwapTypeNotAllowed =>
      'Questi pasti non sono invertibili tra loro.';

  @override
  String get errorTimezoneInvalid => 'Fuso orario non riconosciuto.';

  @override
  String get errorUsernameAlreadyUsed => 'Questo nome utente è già in uso.';

  @override
  String get errorValidationFailed => 'Controlla i dati inseriti.';

  @override
  String get errorVerificationResendRateLimited =>
      'Hai richiesto troppi reinvii. Riprova tra qualche minuto.';

  @override
  String get errorVerificationTokenInvalid =>
      'Il collegamento non è più valido. Richiedine uno nuovo.';

  @override
  String get errorWorkoutFutureDate =>
      'Un allenamento si registra quando è stato svolto: per il futuro c’è la pianificazione.';

  @override
  String get fieldBirthDate => 'Data di nascita';

  @override
  String get fieldBirthPlace => 'Luogo di nascita';

  @override
  String get fieldConfirmPassword => 'Conferma password';

  @override
  String get fieldEmail => 'Indirizzo e-mail';

  @override
  String get fieldFirstName => 'Nome';

  @override
  String get fieldHeight => 'Altezza';

  @override
  String get fieldHeightCm => 'Altezza (cm)';

  @override
  String get fieldLastName => 'Cognome';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldUsername => 'Nome utente';

  @override
  String get groupCreate => 'Crea un gruppo';

  @override
  String get groupDissolve => 'Sciogli il gruppo';

  @override
  String get groupDissolveBody =>
      'Tutti i membri usciranno dal gruppo. Ciascuno conserverà il proprio piano e il proprio storico: nessun dato personale è coinvolto.';

  @override
  String get groupDissolveTitle => 'Sciogliere il gruppo?';

  @override
  String get groupJoinConfirm => 'Conferma adesione';

  @override
  String get groupJoinNoticeStart =>
      'I tuoi pasti diventeranno visibili agli altri membri, e i Cuochi potranno operare inversioni e spunte sul tuo piano.';

  @override
  String get groupJoinWithCode => 'Entra con un codice';

  @override
  String get groupLeave => 'Esci dal gruppo';

  @override
  String get groupLeaveKeepsData =>
      'Conserverai il tuo piano e il tuo storico.';

  @override
  String get groupLeaveTitle => 'Uscire dal gruppo?';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get groupNone => 'Non fai parte di un gruppo';

  @override
  String get groupNoneDescription =>
      'Un gruppo serve a organizzare i pasti di più persone che cucinano insieme';

  @override
  String get groupOnlyMember => 'Sei l\'unico membro';

  @override
  String get groupPromoteCook => 'Nomina Cuoco';

  @override
  String get groupRemoveMember => 'Rimuovi dal gruppo';

  @override
  String groupRemoveMemberBody(String name) {
    return '$name conserverà il proprio piano e il proprio storico.';
  }

  @override
  String get groupRemoveMemberTitle => 'Rimuovere dal gruppo?';

  @override
  String get groupRename => 'Modifica denominazione';

  @override
  String get groupRevokeCook => 'Revoca privilegio di Cuoco';

  @override
  String get groupRoleCook => 'Cuoco';

  @override
  String get groupRoleOwner => 'Proprietario';

  @override
  String get groupTransferFirstBody =>
      'Per uscire dal gruppo devi prima trasferirne la proprietà a un altro membro, dal menu accanto al suo nome.';

  @override
  String get groupTransferFirstTitle => 'Trasferisci prima la proprietà';

  @override
  String get groupTransferOwnership => 'Trasferisci proprietà';

  @override
  String groupTransferOwnershipBody(String name) {
    return '$name diventerà Proprietario del gruppo. Il trasferimento non è annullabile: solo il nuovo Proprietario potrà restituirla.';
  }

  @override
  String get groupTransferOwnershipTitle => 'Trasferire la proprietà?';

  @override
  String get inviteCodeCopied => 'Codice copiato';

  @override
  String get inviteCodeField => 'Codice di invito';

  @override
  String inviteExpiresInDays(int days) {
    return 'Tra $days giorni';
  }

  @override
  String inviteExpiresOn(String date) {
    return 'Scade il $date';
  }

  @override
  String get inviteExpiry => 'Scadenza';

  @override
  String get inviteGenerate => 'Genera codice';

  @override
  String get inviteMaxUses => 'Numero massimo di utilizzi (facoltativo)';

  @override
  String get inviteNoActiveCode => 'Nessun codice attivo';

  @override
  String get inviteNoExpiry => 'Nessuna scadenza';

  @override
  String inviteRemainingUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilizzi rimasti',
      one: '1 utilizzo rimasto',
    );
    return '$_temp0';
  }

  @override
  String inviteShareMessage(String group, String code) {
    return 'Unisciti al mio gruppo «$group» su HealthyLog con il codice $code';
  }

  @override
  String get inviteePatientCheckUsername => 'Verifica il nome utente e riprova';

  @override
  String get inviteePatientMessage => 'Messaggio di presentazione';

  @override
  String get inviteePatientMessageHint => 'Aiuta la persona a riconoscerti';

  @override
  String get inviteePatientNotFound => 'Nessun utente con questo nome';

  @override
  String get inviteePatientSend => 'Invia richiesta';

  @override
  String get inviteePatientTitle => 'Invita un paziente';

  @override
  String get inviteePatientUsernameHint =>
      'Inserisci il nome utente esatto della persona';

  @override
  String get loginForgotPassword => 'Password dimenticata?';

  @override
  String get loginSubmit => 'Accedi';

  @override
  String get loginToRegister => 'Non hai un account? Registrati';

  @override
  String get mealChange => 'Cambia';

  @override
  String get mealChangeStatusTitle => 'Cambiare stato?';

  @override
  String get mealFutureDayBody => 'Questo giorno non è ancora arrivato.';

  @override
  String get mealFutureDayTitle => 'Registrare un pasto futuro?';

  @override
  String get mealMove => 'Sposta';

  @override
  String get mealOfflineUnavailable => 'Non disponibile offline.';

  @override
  String get mealReplacementNote => 'Nota di sostituzione';

  @override
  String get mealReplacementNoteLost =>
      'La nota di sostituzione andrà perduta in modo definitivo.';

  @override
  String get mealSeeRecipe => 'Vedi ricetta';

  @override
  String mealStatusByCook(String verb, String name) {
    return '$verb da $name';
  }

  @override
  String get mealStatusVerbConsumed => 'Consumato';

  @override
  String get mealStatusVerbRestored => 'Ripristinato';

  @override
  String get mealStatusVerbSkipped => 'Saltato';

  @override
  String mealSwappedNotification(String when) {
    return 'Due pasti del tuo piano sono stati invertiti$when.';
  }

  @override
  String get mealTick => 'Spunta';

  @override
  String get measureArm => 'Braccio';

  @override
  String get measureChest => 'Torace';

  @override
  String get measureHips => 'Fianchi';

  @override
  String measureNamedValueWithUnit(String measure, String value, String unit) {
    return '$measure: $value $unit';
  }

  @override
  String get measureThigh => 'Coscia';

  @override
  String measureValueWithUnit(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get measureWaist => 'Vita';

  @override
  String get measureWeight => 'Peso';

  @override
  String measureWithUnit(String measure, String unit) {
    return '$measure ($unit)';
  }

  @override
  String get measurementAtLeastOneValue => 'Inserisci almeno un valore';

  @override
  String get measurementByNutritionist => 'Rilevata dal tuo nutrizionista.';

  @override
  String get measurementDeleteConfirm => 'Eliminare questa misurazione?';

  @override
  String get measurementEditTitle => 'Modifica misurazione';

  @override
  String get measurementForPatientNotice =>
      'La registri tu: la persona potrà consultarla ma non modificarla.';

  @override
  String get measurementNoneRecorded => 'Nessuna misurazione registrata';

  @override
  String get measurementRecord => 'Registra misurazione';

  @override
  String get measurementRecordTitle => 'Registra una misurazione';

  @override
  String get memberSelectorSideBySide => 'Vista affiancata';

  @override
  String get memberSelectorSingle => 'Vista singola';

  @override
  String memberViewingPlanOf(String name) {
    return 'Stai vedendo il piano di $name';
  }

  @override
  String get navActivity => 'Attività';

  @override
  String navNotAvailableYet(String destination) {
    return '$destination: non ancora disponibile.';
  }

  @override
  String get navPatients => 'Pazienti';

  @override
  String get navPlan => 'Piano';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navStatistics => 'Statistiche';

  @override
  String get navTemplates => 'Template';

  @override
  String get notificationCareLinkRevoked =>
      'Il collegamento professionale è stato revocato.';

  @override
  String get notificationCareRequestAccepted =>
      'La tua richiesta di collegamento è stata accettata.';

  @override
  String get notificationCareRequestReceived =>
      'Hai ricevuto una richiesta di collegamento professionale.';

  @override
  String get notificationCareRequestRejected =>
      'La tua richiesta di collegamento è stata rifiutata.';

  @override
  String notificationGroupCookGranted(String group) {
    return 'Sei stato nominato Cuoco del gruppo$group.';
  }

  @override
  String notificationGroupCookRevoked(String group) {
    return 'Non sei più Cuoco del gruppo$group.';
  }

  @override
  String notificationGroupDisbanded(String group) {
    return 'Il gruppo$group è stato sciolto.';
  }

  @override
  String notificationGroupMemberRemoved(String group) {
    return 'Sei stato rimosso dal gruppo$group.';
  }

  @override
  String notificationGroupOwnershipTransferred(String group) {
    return 'Sei diventato Proprietario del gruppo$group.';
  }

  @override
  String notificationInForceFrom(String date) {
    return ', in vigore dal $date';
  }

  @override
  String notificationMeasurementRecorded(String date) {
    return 'È stata registrata una misurazione del $date.';
  }

  @override
  String notificationOnDay(String date) {
    return ' nella giornata del $date';
  }

  @override
  String notificationPlanActivatedAutomatically(String plan) {
    return 'Il piano$plan è entrato in vigore.';
  }

  @override
  String notificationPlanAssigned(String plan, String from) {
    return 'Ti è stato assegnato il piano$plan$from.';
  }

  @override
  String notificationPlanCompleted(String plan) {
    return 'Il piano$plan è stato concluso.';
  }

  @override
  String notificationPlanCompletedAutomatically(String plan) {
    return 'Il piano$plan si è concluso alla data prevista.';
  }

  @override
  String notificationPlanDayModified(String date, String plan) {
    return 'La giornata del $date del piano$plan è stata modificata.';
  }

  @override
  String notificationPlanModified(String plan) {
    return 'Il piano$plan è stato modificato.';
  }

  @override
  String notificationPlanNameQuoted(String name) {
    return ' «$name»';
  }

  @override
  String notificationPlanResumed(String plan) {
    return 'Il piano$plan è stato ripreso.';
  }

  @override
  String notificationPlanSuspended(String plan) {
    return 'Il piano$plan è stato sospeso.';
  }

  @override
  String notificationPlanWithdrawn(String plan) {
    return 'Il piano$plan è stato ritirato ed è tornato in revisione.';
  }

  @override
  String notificationSlotMarked(String slot, String date, String status) {
    return '$slot del $date è stato registrato lo stato $status.';
  }

  @override
  String get notificationSlotOnBreakfast => 'Sulla colazione';

  @override
  String get notificationSlotOnDinner => 'Sulla cena';

  @override
  String get notificationSlotOnGeneric => 'Su un pasto';

  @override
  String get notificationSlotOnLunch => 'Sul pranzo';

  @override
  String get notificationSlotOnSnack => 'Sullo spuntino';

  @override
  String get notificationStatusConsumed => '«Consumato»';

  @override
  String get notificationStatusSkipped => '«Saltato»';

  @override
  String get notificationStatusToConsume => '«Da consumare»';

  @override
  String get notificationUnknown =>
      'Si è verificato un evento che riguarda il tuo account.';

  @override
  String get notificationsEmpty => 'Nessuna notifica';

  @override
  String get notificationsMarkAllRead => 'Segna tutte come lette';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get offlineBar =>
      'Sei offline. Puoi consultare il piano già scaricato.';

  @override
  String get passwordRequirementHint => 'Almeno 8 caratteri';

  @override
  String get passwordResetConfirmTitle => 'Imposta una nuova password';

  @override
  String get passwordResetDone =>
      'Tutte le sessioni sono state chiuse. Accedi con la nuova password.';

  @override
  String get passwordResetLinkExpiredBody =>
      'Richiedine uno nuovo dalla schermata di accesso.';

  @override
  String get passwordResetLinkExpiredTitle =>
      'Il collegamento non è più valido';

  @override
  String get passwordResetNewPassword => 'Nuova password';

  @override
  String get passwordResetRequestNewLink => 'Richiedi un nuovo collegamento';

  @override
  String get passwordResetRequestSent =>
      'Se esiste un account con questo indirizzo, riceverai un collegamento tra pochi istanti.';

  @override
  String get passwordResetRequestSubmit => 'Invia collegamento';

  @override
  String get passwordResetRequestSubtitle =>
      'Ti invieremo un collegamento per impostare una nuova password';

  @override
  String get passwordResetRequestTitle => 'Recupera l\'accesso';

  @override
  String get passwordResetSubmit => 'Reimposta password';

  @override
  String patientAdherenceWithPeriod(String period) {
    return 'Aderenza · $period';
  }

  @override
  String get patientCreatePlan => 'Crea un nuovo piano';

  @override
  String get patientCurrentPlanHeader => 'PIANO IN CORSO';

  @override
  String get patientEditDay => 'Modifica una giornata';

  @override
  String patientLinkedSince(String date) {
    return 'Collegato dal $date';
  }

  @override
  String patientMeasureChange(String measure, String change, String unit) {
    return '$measure: $change $unit';
  }

  @override
  String patientMeasureSingleValue(String measure) {
    return '$measure: un solo valore nel periodo';
  }

  @override
  String get patientMeasurementsHeader => 'MISURAZIONI';

  @override
  String get patientMonthStatisticsHeader => 'STATISTICHE DEL MESE';

  @override
  String get patientNoCurrentPlan => 'Nessun piano in corso redatto da te.';

  @override
  String get patientNoMeasurements => 'Nessuna misurazione';

  @override
  String get patientNoWorkouts => 'Nessun allenamento';

  @override
  String get patientOtherPlansHeader => 'ALTRI PIANI REDATTI';

  @override
  String get patientPickDay => 'Giornata da modificare';

  @override
  String patientPlanWithStatus(String plan, String status) {
    return '$plan · $status';
  }

  @override
  String get patientSortAdherence => 'Aderenza';

  @override
  String get patientSortName => 'Alfabetico';

  @override
  String get patientSortRecentActivity => 'Attività recente';

  @override
  String get patientWithdrawBody => 'Il paziente non lo vedrà più.';

  @override
  String get patientWorkoutsHeader => 'ALLENAMENTI';

  @override
  String get patientsEmpty => 'Nessun paziente collegato';

  @override
  String get patientsInvite => 'Invita paziente';

  @override
  String get patientsInviteHint => 'Invita un paziente con il suo nome utente';

  @override
  String get patientsPendingRequests => 'RICHIESTE PENDENTI';

  @override
  String get patientsRequestSent => 'Richiesta inviata.';

  @override
  String patientsRequestSentOn(String date) {
    return 'Inviata il $date · In attesa';
  }

  @override
  String get patientsSelect => 'Seleziona un paziente';

  @override
  String get patientsSortBy => 'Ordina';

  @override
  String get periodMonth => 'Mese';

  @override
  String get periodPlan => 'Piano';

  @override
  String get periodWeek => 'Settimana';

  @override
  String get personalDataRoleNotChangeable => 'Il ruolo non è modificabile';

  @override
  String get personalDataSaved => 'Dati aggiornati.';

  @override
  String get personalDataTargetWeight => 'Peso obiettivo';

  @override
  String get personalDataTargetWeightKg => 'Peso obiettivo (kg)';

  @override
  String get personalDataTitle => 'Dati personali';

  @override
  String get planActionComplete => 'Concludi';

  @override
  String get planActionDelete => 'Elimina';

  @override
  String get planActionEdit => 'Modifica';

  @override
  String get planActionExport => 'Esporta';

  @override
  String get planActionReactivate => 'Riattiva';

  @override
  String get planActionResume => 'Riprendi';

  @override
  String get planActionSuspend => 'Sospendi';

  @override
  String get planActionWithdraw => 'Ritira';

  @override
  String planCompletedOn(String date) {
    return 'Piano concluso il $date';
  }

  @override
  String get planCreateFirst => 'Crea il tuo primo piano alimentare';

  @override
  String get planCreateFromScratch => 'Da zero';

  @override
  String get planCreateFromScratchDescription =>
      'Componi lo schema settimanale partendo da una struttura vuota';

  @override
  String get planCreateFromTemplate => 'Da un template';

  @override
  String get planCreateFromTemplateDescription =>
      'Parti da uno schema già pronto e modificalo';

  @override
  String get planCreateSubmit => 'Crea piano';

  @override
  String get planCreateTitle => 'Nuovo piano';

  @override
  String get planDayView => 'Giorno';

  @override
  String get planDeleteIrreversible =>
      'L\'operazione non può essere annullata.';

  @override
  String get planDeleteLossAllPeriods =>
      'Andranno perdute in modo definitivo, per tutti i periodi del piano:';

  @override
  String get planDeleteLossDays => '•  le giornate e le spunte di consumo';

  @override
  String get planDeleteLossStatistics => '•  le statistiche di aderenza';

  @override
  String get planDeleteLossSwaps => '•  lo storico delle inversioni';

  @override
  String get planDeleteLossThisPeriod =>
      'Andranno perdute in modo definitivo, per questo periodo:';

  @override
  String get planDeleteTitle => 'Eliminare il piano?';

  @override
  String get planDeleteWorkoutsKept =>
      'Allenamenti e misurazioni dello stesso periodo restano.';

  @override
  String get planEditThisDay => 'Modifica questa giornata';

  @override
  String get planEndDate => 'Data di fine';

  @override
  String get planExportInProgress => 'Preparazione del documento…';

  @override
  String get planMoreActions => 'Altre azioni';

  @override
  String get planNoMealsPlanned => 'Nessun pasto previsto';

  @override
  String get planNoneForThisDay => 'Nessun piano per questo giorno';

  @override
  String get planNoneYet => 'Nessun piano ancora';

  @override
  String get planOpenEnded => 'A tempo indeterminato';

  @override
  String planOverlapNotice(String start, String end) {
    return 'Il periodo è già occupato da un altro piano ($start – $end).';
  }

  @override
  String planOverlapNoticeOpen(String start) {
    return 'Il periodo è già occupato da un altro piano (dal $start).';
  }

  @override
  String planOverlapWithName(String name) {
    return 'Si sovrappone a «$name».';
  }

  @override
  String get planPatientNoPlanYet =>
      'Il tuo nutrizionista non ha ancora redatto un piano';

  @override
  String get planRecipient => 'Destinatario';

  @override
  String get planRecordWorkout => 'Registra allenamento';

  @override
  String get planStartDate => 'Data di inizio';

  @override
  String planStartsOn(String date) {
    return 'Il piano inizia il $date';
  }

  @override
  String get planStatusActive => 'Attivo';

  @override
  String get planStatusCompleted => 'Concluso';

  @override
  String get planStatusDraft => 'Bozza';

  @override
  String get planStatusLowerActive => 'in corso';

  @override
  String get planStatusLowerCompleted => 'concluso';

  @override
  String get planStatusLowerDraft => 'bozza';

  @override
  String get planStatusLowerScheduled => 'programmato';

  @override
  String get planStatusLowerSuspended => 'sospeso';

  @override
  String get planStatusScheduled => 'Programmato';

  @override
  String get planStatusSuspended => 'Sospeso';

  @override
  String get planSuspended => 'Piano sospeso';

  @override
  String get planSuspendedHint => 'Riprenderà quando lo deciderai';

  @override
  String get planViewNoSwaps => 'Nessuna inversione su questo piano.';

  @override
  String get planViewOngoing => 'in corso';

  @override
  String get planViewOngoingUpper => 'IN CORSO';

  @override
  String get planViewOpenStatistics => 'Apri le statistiche complete';

  @override
  String get planViewOverallAdherence => 'Aderenza complessiva del piano';

  @override
  String planViewPeriodRange(String start, String end) {
    return 'Dal $start a $end';
  }

  @override
  String get planViewPeriodStatistics => 'Statistiche del periodo';

  @override
  String get planViewPeriods => 'Periodi di svolgimento';

  @override
  String get planViewSwapHistory => 'Storico delle inversioni';

  @override
  String get planViewWeeklySchedule => 'Schema settimanale';

  @override
  String get planWeekView => 'Settimana';

  @override
  String get plansActivateNow => 'Attiva ora';

  @override
  String plansAdherencePercent(String value) {
    return '$value%';
  }

  @override
  String plansAuthoredBy(String author) {
    return 'Redatto da $author';
  }

  @override
  String get plansCompleteConfirmBody =>
      'Potrai sempre riattivarlo in seguito.';

  @override
  String get plansCompleteConfirmTitle => 'Concludere il piano?';

  @override
  String get plansCurrent => 'In corso';

  @override
  String plansDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get plansEmptyOwn => 'Non hai ancora un piano alimentare.';

  @override
  String get plansEmptyPatient =>
      'Il tuo nutrizionista non ha ancora redatto un piano.';

  @override
  String plansFrom(String date) {
    return 'Dal $date';
  }

  @override
  String get plansPatientNotice =>
      'Il contenuto del piano è a cura del tuo nutrizionista: puoi spuntare e invertire i pasti.';

  @override
  String plansPeriodCount(int count) {
    return '$count periodi';
  }

  @override
  String get plansStartHere => 'Inizia da qui';

  @override
  String get plansWithdrawConfirmBody =>
      'Tornerà in Bozza: potrai riprenderlo dalla redazione.';

  @override
  String get plansWithdrawConfirmTitle => 'Ritirare il piano?';

  @override
  String get privacyPolicyAccept =>
      'Accetto l\'informativa sul trattamento dei dati';

  @override
  String get privacyPolicyAcceptRequired =>
      'Devi accettare l\'informativa per proseguire';

  @override
  String get privacyPolicyRead => 'Leggi l\'informativa';

  @override
  String get privacyPolicyTitle => 'Informativa sul trattamento dei dati';

  @override
  String get privacyPolicyUpdatedBody =>
      'L\'abbiamo aggiornata: leggila e accettala per proseguire.';

  @override
  String get privacyPolicyUpdatedTitle => 'L\'informativa è cambiata';

  @override
  String get profileGroup => 'Gruppo';

  @override
  String get profileLogout => 'Disconnetti';

  @override
  String get profileLogoutConfirm =>
      'Vuoi disconnetterti da questo dispositivo?';

  @override
  String get profileNutritionist => 'Nutrizionista';

  @override
  String get profilePersonalData => 'Dati personali';

  @override
  String get profilePlans => 'Piani';

  @override
  String get profileSettings => 'Impostazioni';

  @override
  String get registerSubmit => 'Crea account';

  @override
  String get roleNutritionist => 'Nutrizionista';

  @override
  String get roleNutritionistDescription =>
      'Redigi e segui i piani dei tuoi pazienti';

  @override
  String get roleNutritionistTitle => 'Sono un nutrizionista';

  @override
  String get roleSelectionNotChangeable =>
      'La scelta non è modificabile in seguito';

  @override
  String get roleSelectionTitle => 'Come userai HealthyLog?';

  @override
  String get roleUser => 'Utente';

  @override
  String get roleUserDescription =>
      'Consulti la tua dieta, segni i pasti e registri gli allenamenti';

  @override
  String get roleUserTitle => 'Seguo un piano';

  @override
  String get scheduleConfirmPlan => 'Conferma piano';

  @override
  String get scheduleIncompleteTitle => 'Schema incompleto';

  @override
  String get scheduleRetroactivityNotice =>
      'Le modifiche decorrono da oggi e valgono per tutte le settimane: le giornate già trascorse restano invariate. Per cambiare una sola giornata, usa «Modifica questa giornata» dalla vista del giorno.';

  @override
  String get scheduleSave => 'Salva modifiche';

  @override
  String get scheduleSaveAsTemplate => 'Salva come template';

  @override
  String get scheduleSaved => 'Piano salvato.';

  @override
  String scheduleSlotsWithoutContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasti senza contenuto',
      one: '1 pasto senza contenuto',
    );
    return '$_temp0';
  }

  @override
  String get scheduleTemplateCreated => 'Template creato.';

  @override
  String get scheduleTitle => 'Redazione dello schema';

  @override
  String get settingsDeleteAccount => 'Elimina account';

  @override
  String get settingsDevices => 'Dispositivi collegati';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsPrivacyPolicy => 'Informativa';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsSectionDateTime => 'Data e ora';

  @override
  String get settingsSectionLanguageAndFormats => 'Lingua e formati';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionSecurity => 'Sicurezza';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsTimezone => 'Fuso orario';

  @override
  String get settingsTimezoneSearch => 'Cerca fuso orario';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsUnitImperial => 'Imperiale';

  @override
  String get settingsUnitMetric => 'Metrico';

  @override
  String get settingsUnitRetroactiveNotice =>
      'Il cambio si applica a tutti i dati, compresi grafici e storico.';

  @override
  String get settingsUnitSystem => 'Unità di misura';

  @override
  String get sexFemale => 'Femmina';

  @override
  String get sexMale => 'Maschio';

  @override
  String signedNegative(String value) {
    return '−$value';
  }

  @override
  String signedPositive(String value) {
    return '+$value';
  }

  @override
  String get slotAccessoryNote => 'Nota accessoria';

  @override
  String slotAddOfType(String type) {
    return 'Aggiungi $type';
  }

  @override
  String slotAdherenceWeight(String value) {
    return 'Peso di aderenza: $value';
  }

  @override
  String get slotAdherenceWeightHelp =>
      'Quanto questo pasto incide sull\'aderenza. A zero non viene conteggiato.';

  @override
  String get slotContent => 'Contenuto';

  @override
  String get slotDescriptiveLabel => 'Etichetta descrittiva';

  @override
  String get slotNotSpecified => 'Non specificato';

  @override
  String get slotRecipeName => 'Denominazione della ricetta';

  @override
  String get slotRecipeText => 'Testo della ricetta';

  @override
  String get slotToBeDefined => 'Da definire';

  @override
  String get slotTypeBreakfast => 'Colazione';

  @override
  String get slotTypeDinner => 'Cena';

  @override
  String get slotTypeLunch => 'Pranzo';

  @override
  String get slotTypeSnack => 'Spuntino';

  @override
  String get statisticsAdherence => 'Aderenza';

  @override
  String get statisticsAppearWithPlan =>
      'Le statistiche del piano compaiono quando ne esiste uno.';

  @override
  String get statisticsBody => 'Corpo';

  @override
  String get statisticsChangePeriod => 'Cambia periodo';

  @override
  String statisticsExclusionDaysSuspended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni di sospensione',
      one: '1 giorno di sospensione',
    );
    return '$_temp0';
  }

  @override
  String statisticsExclusionDaysUncovered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni senza piano',
      one: '1 giorno senza piano',
    );
    return '$_temp0';
  }

  @override
  String statisticsExclusionNotice(String what) {
    return 'Il calcolo esclude $what.';
  }

  @override
  String statisticsMonthOf(String month) {
    return 'Mese di $month';
  }

  @override
  String get statisticsNoDataForPeriod =>
      'Dati non disponibili per questo periodo';

  @override
  String get statisticsNoDataYet => 'Non ci sono ancora dati';

  @override
  String get statisticsNoPlanForPeriod =>
      'Nessun piano su cui riferire il periodo';

  @override
  String statisticsPercent(String value) {
    return '$value%';
  }

  @override
  String statisticsPeriodOrdinal(int index) {
    return '$index° periodo';
  }

  @override
  String statisticsPlanRange(String plan, String start, String end) {
    return '$plan · $start – $end';
  }

  @override
  String get statisticsUnavailable => 'Statistiche non disponibili';

  @override
  String statisticsWeekRange(String start, String end) {
    return 'Settimana dal $start al $end';
  }

  @override
  String get statisticsWholePlan => 'Intero piano';

  @override
  String get statisticsWorkouts => 'Allenamenti';

  @override
  String get swapChooseDestination => 'Scegli dove spostarlo';

  @override
  String templateDeleteConfirmBody(String name) {
    return 'I piani già creati da «$name» non ne risentono.';
  }

  @override
  String get templateDeleteConfirmTitle => 'Eliminare il template?';

  @override
  String templateLastEdited(String when) {
    return 'Ultima modifica: $when';
  }

  @override
  String get templateNew => 'Nuovo template';

  @override
  String get templatePreviewTitle => 'Anteprima template';

  @override
  String get templateRename => 'Rinomina template';

  @override
  String get templateRenameShort => 'Rinomina';

  @override
  String get templateSaved => 'Template salvato.';

  @override
  String get templateScheduleTitle => 'Redazione del template';

  @override
  String get templateUse => 'Usa questo template';

  @override
  String get templatesEmpty =>
      'Nessun template. Crealo con il pulsante in basso.';

  @override
  String get timezoneAfricaCairo => 'Il Cairo';

  @override
  String get timezoneAfricaJohannesburg => 'Johannesburg';

  @override
  String get timezoneAmericaArgentinaBuenosAires => 'Buenos Aires';

  @override
  String get timezoneAmericaChicago => 'Chicago';

  @override
  String get timezoneAmericaDenver => 'Denver';

  @override
  String get timezoneAmericaLosAngeles => 'Los Angeles';

  @override
  String get timezoneAmericaNewYork => 'New York';

  @override
  String get timezoneAmericaSaoPaulo => 'San Paolo';

  @override
  String get timezoneAsiaBangkok => 'Bangkok';

  @override
  String get timezoneAsiaDubai => 'Dubai';

  @override
  String get timezoneAsiaHongKong => 'Hong Kong';

  @override
  String get timezoneAsiaKolkata => 'Nuova Delhi';

  @override
  String get timezoneAsiaSeoul => 'Seul';

  @override
  String get timezoneAsiaShanghai => 'Shanghai';

  @override
  String get timezoneAsiaTokyo => 'Tokyo';

  @override
  String get timezoneAustraliaPerth => 'Perth';

  @override
  String get timezoneAustraliaSydney => 'Sydney';

  @override
  String get timezoneEuropeAmsterdam => 'Amsterdam';

  @override
  String get timezoneEuropeAthens => 'Atene';

  @override
  String get timezoneEuropeBerlin => 'Berlino';

  @override
  String get timezoneEuropeDublin => 'Dublino';

  @override
  String get timezoneEuropeHelsinki => 'Helsinki';

  @override
  String get timezoneEuropeLisbon => 'Lisbona';

  @override
  String get timezoneEuropeLondon => 'Londra';

  @override
  String get timezoneEuropeMadrid => 'Madrid';

  @override
  String get timezoneEuropeMoscow => 'Mosca';

  @override
  String get timezoneEuropeParis => 'Parigi';

  @override
  String get timezoneEuropeRome => 'Roma';

  @override
  String get timezoneEuropeVienna => 'Vienna';

  @override
  String get timezoneEuropeZurich => 'Zurigo';

  @override
  String get timezonePacificAuckland => 'Auckland';

  @override
  String get timezoneUtc => 'UTC';

  @override
  String get unitCentimetres => 'cm';

  @override
  String get unitInches => 'in';

  @override
  String get unitKilocalories => 'kcal';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitPounds => 'lb';

  @override
  String get usernameHint => 'Servirà al tuo nutrizionista per trovarti';

  @override
  String get validationEmailAlreadyRegistered =>
      'Questo indirizzo è già registrato';

  @override
  String get validationInvalidFormat => 'Formato non valido';

  @override
  String get validationInvalidValue => 'Valore non valido';

  @override
  String get validationPasswordsDoNotMatch => 'Le password non coincidono';

  @override
  String get validationRequired => 'Campo obbligatorio';

  @override
  String get validationTooLong => 'Troppo lungo';

  @override
  String get validationUsernameAlreadyTaken =>
      'Questo nome utente è già in uso';

  @override
  String get verifyEmailBackToLogin => 'Torna all\'accesso';

  @override
  String get verifyEmailLinkExpiredBody =>
      'Torna all\'accesso per richiederne uno nuovo.';

  @override
  String get verifyEmailLinkExpiredTitle => 'Il collegamento non è più valido';

  @override
  String get verifyEmailResend => 'Invia di nuovo';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Invia di nuovo (${seconds}s)';
  }

  @override
  String verifyEmailSentTo(String email) {
    return 'Abbiamo inviato un collegamento di conferma a $email';
  }

  @override
  String get verifyEmailTitle => 'Controlla la tua posta';

  @override
  String get verifyEmailUseAnotherAddress => 'Usa un altro indirizzo';

  @override
  String get weekNext => 'Settimana successiva';

  @override
  String get weekNoPlan => 'Nessun piano';

  @override
  String get weekPlanCompleted => 'Piano concluso';

  @override
  String get weekPlanNotStarted => 'Piano non ancora iniziato';

  @override
  String get weekPrevious => 'Settimana precedente';

  @override
  String weekRangeAcrossMonths(String start, String end) {
    return '$start – $end';
  }

  @override
  String weekRangeSameMonth(String startDay, String endDay, String monthYear) {
    return '$startDay – $endDay $monthYear';
  }

  @override
  String get weekThisWeek => 'Questa settimana';

  @override
  String get weekdayFriday => 'Venerdì';

  @override
  String get weekdayInitialFriday => 'V';

  @override
  String get weekdayInitialMonday => 'L';

  @override
  String get weekdayInitialSaturday => 'S';

  @override
  String get weekdayInitialSunday => 'D';

  @override
  String get weekdayInitialThursday => 'G';

  @override
  String get weekdayInitialTuesday => 'M';

  @override
  String get weekdayInitialWednesday => 'M';

  @override
  String get weekdayMonday => 'Lunedì';

  @override
  String get weekdaySaturday => 'Sabato';

  @override
  String get weekdaySunday => 'Domenica';

  @override
  String get weekdayThursday => 'Giovedì';

  @override
  String get weekdayTuesday => 'Martedì';

  @override
  String get weekdayWednesday => 'Mercoledì';

  @override
  String get workoutActivityType => 'Tipo di attività';

  @override
  String get workoutActivityTypeRequired => 'Indica il tipo di attività';

  @override
  String get workoutAddOneOff => 'Aggiungi allenamento occasionale';

  @override
  String get workoutAddRecurring => 'Aggiungi allenamento ricorrente';

  @override
  String workoutBulletType(String type) {
    return '• $type';
  }

  @override
  String workoutBulletTypeWithCalories(String type, int calories) {
    return '• $type — $calories kcal';
  }

  @override
  String get workoutCaloriesBurned => 'Calorie bruciate';

  @override
  String get workoutCaloriesOptional => 'Se lo sai. Non è obbligatorio.';

  @override
  String workoutCaloriesWithUnit(int value) {
    return '$value kcal';
  }

  @override
  String get workoutCease => 'Cessa';

  @override
  String get workoutClearFilters => 'Rimuovi i filtri';

  @override
  String get workoutDeleteConfirm => 'Eliminare questo allenamento?';

  @override
  String get workoutDeleteKeepsPlanning =>
      'La pianificazione resta: l\'allenamento tornerà previsto e non svolto.';

  @override
  String workoutDuplicateMany(int count) {
    return 'Hai già registrato $count allenamenti in questo giorno';
  }

  @override
  String get workoutDuplicateSingle =>
      'Hai già registrato un allenamento in questo giorno';

  @override
  String get workoutEditTitle => 'Modifica allenamento';

  @override
  String get workoutFilters => 'Filtri';

  @override
  String get workoutMarkAsDone => 'Segna come svolto';

  @override
  String get workoutNoTypesYet => 'Nessun tipo ancora registrato.';

  @override
  String get workoutNoWeeklyGoal => 'Nessun obiettivo settimanale';

  @override
  String get workoutNonePlanned => 'Nessun allenamento pianificato';

  @override
  String get workoutNonePlannedDot => 'Nessun allenamento pianificato.';

  @override
  String get workoutNoneRecorded => 'Nessun allenamento registrato';

  @override
  String get workoutNoneWithFilters => 'Nessun allenamento con questi filtri';

  @override
  String get workoutOneOff => 'Allenamento occasionale';

  @override
  String get workoutPerWeek => 'Allenamenti a settimana';

  @override
  String workoutPerWeekSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count allenamenti a settimana',
      one: '1 allenamento a settimana',
    );
    return '$_temp0';
  }

  @override
  String get workoutPeriod => 'Periodo';

  @override
  String get workoutPickAtLeastOneDay => 'Scegli almeno un giorno';

  @override
  String get workoutPickPeriod => 'Scegli un periodo';

  @override
  String get workoutPlanning => 'Pianificazione';

  @override
  String get workoutPlanningNotice =>
      'Le modifiche valgono da oggi in avanti: i giorni trascorsi restano come erano.';

  @override
  String get workoutRecord => 'Registra allenamento';

  @override
  String get workoutRecordAnyway => 'Registra comunque';

  @override
  String get workoutRecordTitle => 'Registra un allenamento';

  @override
  String get workoutRecurring => 'Allenamento ricorrente';

  @override
  String get workoutRemoveGoal => 'Rimuovi obiettivo';

  @override
  String get workoutSetGoal => 'Imposta';

  @override
  String get workoutSheetFooter =>
      'Se vuoi, aggiungi calorie e nota. Puoi anche chiudere: l\'allenamento è registrato lo stesso.';

  @override
  String get workoutStatsDistribution => 'Distribuzione per tipo';

  @override
  String get workoutStatsGoalComparison => 'Confronto con l’obiettivo';

  @override
  String workoutStatsGoalProgress(int done, int goal) {
    return '$done su $goal previsti';
  }

  @override
  String workoutStatsGoalProgressWeekly(int done, int goal) {
    return '$done su $goal previsti dall’obiettivo settimanale';
  }

  @override
  String workoutStatsGoalWeeks(int weeks) {
    return 'Su $weeks settimane intere, ciascuna con l’obiettivo allora vigente.';
  }

  @override
  String workoutStatsGoalWeeksNotice(int weeks) {
    return 'Su $weeks settimane intere, ciascuna con l’obiettivo allora vigente.';
  }

  @override
  String get workoutStatsNonePlannedInPeriod =>
      'Nessun allenamento pianificato nel periodo.';

  @override
  String get workoutStatsNoneRecordedInPeriod =>
      'Nessun allenamento registrato nel periodo.';

  @override
  String get workoutStatsPlanComparison => 'Confronto con la pianificazione';

  @override
  String workoutStatsPlanProgress(int planned, int done) {
    return '$planned pianificati, $done svolti';
  }

  @override
  String workoutStatsSuspendedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comprende $count giorni di sospensione, che l’aderenza esclude.',
      one: 'Comprende 1 giorno di sospensione, che l’aderenza esclude.',
    );
    return '$_temp0';
  }

  @override
  String workoutStatsTotalDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count allenamenti svolti',
      one: '1 allenamento svolto',
    );
    return '$_temp0';
  }

  @override
  String get workoutStatsWeeklyTrend => 'Andamento settimanale';

  @override
  String get workoutWeeklyGoal => 'Obiettivo settimanale';

  @override
  String get workoutWeeklyGoalHelp =>
      'Quante volte ti proponi di allenarti in una settimana. È indipendente dai giorni che hai pianificato.';

  @override
  String get workoutWhenDone => 'Quando lo hai svolto';
}
