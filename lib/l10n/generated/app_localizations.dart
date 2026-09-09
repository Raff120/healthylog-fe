import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
    Locale('it'),
  ];

  /// No description provided for @activityMeasurements.
  ///
  /// In it, this message translates to:
  /// **'Misure'**
  String get activityMeasurements;

  /// No description provided for @activityWorkouts.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti'**
  String get activityWorkouts;

  /// No description provided for @adherenceBySlotType.
  ///
  /// In it, this message translates to:
  /// **'Per tipo di pasto'**
  String get adherenceBySlotType;

  /// No description provided for @adherenceByWeekday.
  ///
  /// In it, this message translates to:
  /// **'Per giorno della settimana'**
  String get adherenceByWeekday;

  /// No description provided for @adherenceOverall.
  ///
  /// In it, this message translates to:
  /// **'Complessivo'**
  String get adherenceOverall;

  /// No description provided for @adherencePeriodRange.
  ///
  /// In it, this message translates to:
  /// **'Periodo dal {start} a {end}'**
  String adherencePeriodRange(String start, String end);

  /// No description provided for @adherenceWeeklyTrend.
  ///
  /// In it, this message translates to:
  /// **'Andamento settimanale'**
  String get adherenceWeeklyTrend;

  /// No description provided for @bodyMeasurementsTitle.
  ///
  /// In it, this message translates to:
  /// **'Misurazioni'**
  String get bodyMeasurementsTitle;

  /// No description provided for @bodyStatsNoMeasurements.
  ///
  /// In it, this message translates to:
  /// **'Nessuna misurazione nel periodo'**
  String get bodyStatsNoMeasurements;

  /// No description provided for @bodyStatsNutritionistLegend.
  ///
  /// In it, this message translates to:
  /// **'I cerchi vuoti sono le misurazioni rilevate dal nutrizionista.'**
  String get bodyStatsNutritionistLegend;

  /// No description provided for @bodyStatsSingleValue.
  ///
  /// In it, this message translates to:
  /// **'Un solo valore: nessuna variazione da presentare'**
  String get bodyStatsSingleValue;

  /// No description provided for @careLinkActiveHeader.
  ///
  /// In it, this message translates to:
  /// **'COLLEGAMENTO IN CORSO'**
  String get careLinkActiveHeader;

  /// No description provided for @careLinkRevoked.
  ///
  /// In it, this message translates to:
  /// **'Collegamento revocato. Hai di nuovo piena facoltà sul tuo piano.'**
  String get careLinkRevoked;

  /// No description provided for @careLinkedNow.
  ///
  /// In it, this message translates to:
  /// **'Ora sei collegato a {name}.'**
  String careLinkedNow(String name);

  /// No description provided for @careLinkedSince.
  ///
  /// In it, this message translates to:
  /// **'Dal {date}'**
  String careLinkedSince(String date);

  /// No description provided for @careManagePlanYourself.
  ///
  /// In it, this message translates to:
  /// **'Puoi gestire il piano in autonomia'**
  String get careManagePlanYourself;

  /// No description provided for @careNoNutritionist.
  ///
  /// In it, this message translates to:
  /// **'Nessun nutrizionista collegato'**
  String get careNoNutritionist;

  /// No description provided for @careNutritionistNotice.
  ///
  /// In it, this message translates to:
  /// **'Il nutrizionista redige il tuo piano e ne segue l\'andamento. Puoi sempre invertire e spuntare i pasti, ma non modificarne il contenuto.'**
  String get careNutritionistNotice;

  /// No description provided for @careRequestAccepting.
  ///
  /// In it, this message translates to:
  /// **'Accettando, il nutrizionista:'**
  String get careRequestAccepting;

  /// No description provided for @careRequestExpired.
  ///
  /// In it, this message translates to:
  /// **'Decaduta'**
  String get careRequestExpired;

  /// No description provided for @careRequestKeepAfterRevoke.
  ///
  /// In it, this message translates to:
  /// **'Potrai revocare il collegamento in qualsiasi momento. Dopo la revoca conserverà solo gli schemi dei piani che ha redatto e le misurazioni che ha registrato personalmente.'**
  String get careRequestKeepAfterRevoke;

  /// No description provided for @careRequestReceivedOn.
  ///
  /// In it, this message translates to:
  /// **'Ricevuta il {date}'**
  String careRequestReceivedOn(String date);

  /// No description provided for @careRequestTitle.
  ///
  /// In it, this message translates to:
  /// **'Richiesta di collegamento'**
  String get careRequestTitle;

  /// No description provided for @careRequestWillRead.
  ///
  /// In it, this message translates to:
  /// **'accederà in lettura ai tuoi dati nei periodi coperti dai suoi piani'**
  String get careRequestWillRead;

  /// No description provided for @careRequestWillRecordMeasurements.
  ///
  /// In it, this message translates to:
  /// **'potrà registrare misurazioni per tuo conto'**
  String get careRequestWillRecordMeasurements;

  /// No description provided for @careRequestWillWritePlan.
  ///
  /// In it, this message translates to:
  /// **'redigerà il tuo piano alimentare'**
  String get careRequestWillWritePlan;

  /// No description provided for @careRequestYouCannotEdit.
  ///
  /// In it, this message translates to:
  /// **'e tu non potrai più modificare il contenuto del piano che ti assegna'**
  String get careRequestYouCannotEdit;

  /// No description provided for @careRequestsReceivedHeader.
  ///
  /// In it, this message translates to:
  /// **'RICHIESTE RICEVUTE'**
  String get careRequestsReceivedHeader;

  /// CP-16, PV-21: la documentazione che il Nutrizionista conserva dopo la revoca.
  ///
  /// In it, this message translates to:
  /// **'• gli schemi dei piani che ha redatto, con il periodo di validità;\n• le misurazioni che ha registrato personalmente;\n• i dati anagrafici essenziali.'**
  String get careRevokeKeepsList;

  /// No description provided for @careRevokeLink.
  ///
  /// In it, this message translates to:
  /// **'Revoca il collegamento'**
  String get careRevokeLink;

  /// CP-17: quanto non è conservato dopo la revoca.
  ///
  /// In it, this message translates to:
  /// **'• spunte, inversioni e statistiche di aderenza;\n• allenamenti e misurazioni registrate dalla persona.'**
  String get careRevokeLosesList;

  /// No description provided for @careRevokeNutritionistBody.
  ///
  /// In it, this message translates to:
  /// **'Il nutrizionista perderà immediatamente ogni accesso ai tuoi dati e ogni facoltà sul tuo piano, che resterà a tua disposizione.'**
  String get careRevokeNutritionistBody;

  /// No description provided for @careRevokeNutritionistKeeps.
  ///
  /// In it, this message translates to:
  /// **'Il nutrizionista conserverà:'**
  String get careRevokeNutritionistKeeps;

  /// No description provided for @careRevokeNutritionistLoses.
  ///
  /// In it, this message translates to:
  /// **'Non conserverà:'**
  String get careRevokeNutritionistLoses;

  /// No description provided for @careRevokeNutritionistSideBody.
  ///
  /// In it, this message translates to:
  /// **'Perderai immediatamente ogni accesso ai dati della persona e ogni facoltà sui suoi piani.'**
  String get careRevokeNutritionistSideBody;

  /// No description provided for @careRevokeTitle.
  ///
  /// In it, this message translates to:
  /// **'Revocare il collegamento?'**
  String get careRevokeTitle;

  /// No description provided for @careRevokeYouKeep.
  ///
  /// In it, this message translates to:
  /// **'Conserverai:'**
  String get careRevokeYouKeep;

  /// No description provided for @careRevokeYouLose.
  ///
  /// In it, this message translates to:
  /// **'Non conserverai:'**
  String get careRevokeYouLose;

  /// No description provided for @commonAccept.
  ///
  /// In it, this message translates to:
  /// **'Accetta'**
  String get commonAccept;

  /// No description provided for @commonAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get commonAdd;

  /// No description provided for @commonAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get commonAll;

  /// No description provided for @commonApply.
  ///
  /// In it, this message translates to:
  /// **'Applica'**
  String get commonApply;

  /// No description provided for @commonBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get commonConfirm;

  /// No description provided for @commonContinue.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get commonContinue;

  /// No description provided for @commonCopy.
  ///
  /// In it, this message translates to:
  /// **'Copia'**
  String get commonCopy;

  /// No description provided for @commonCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get commonCreate;

  /// No description provided for @commonDecline.
  ///
  /// In it, this message translates to:
  /// **'Rifiuta'**
  String get commonDecline;

  /// No description provided for @commonDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get commonDelete;

  /// No description provided for @commonDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get commonDescription;

  /// No description provided for @commonEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get commonEdit;

  /// No description provided for @commonGenerate.
  ///
  /// In it, this message translates to:
  /// **'Genera'**
  String get commonGenerate;

  /// Congiunzione fra le due sole voci che l’elenco può avere.
  ///
  /// In it, this message translates to:
  /// **' e '**
  String get commonListAnd;

  /// No description provided for @commonName.
  ///
  /// In it, this message translates to:
  /// **'Denominazione'**
  String get commonName;

  /// No description provided for @commonNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get commonNotSet;

  /// No description provided for @commonNote.
  ///
  /// In it, this message translates to:
  /// **'Nota'**
  String get commonNote;

  /// Azione del pulsante primario, distinta da "Registra allenamento" della voce di menu.
  ///
  /// In it, this message translates to:
  /// **'Registra'**
  String get commonRecord;

  /// No description provided for @commonRegenerate.
  ///
  /// In it, this message translates to:
  /// **'Rigenera'**
  String get commonRegenerate;

  /// No description provided for @commonRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get commonRemove;

  /// No description provided for @commonRevoke.
  ///
  /// In it, this message translates to:
  /// **'Revoca'**
  String get commonRevoke;

  /// No description provided for @commonSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get commonSearch;

  /// No description provided for @commonShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get commonShare;

  /// No description provided for @commonToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get commonToday;

  /// No description provided for @commonUnderstood.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get commonUnderstood;

  /// No description provided for @dayPreviewNoSlots.
  ///
  /// In it, this message translates to:
  /// **'Nessuno slot'**
  String get dayPreviewNoSlots;

  /// No description provided for @devicesCurrent.
  ///
  /// In it, this message translates to:
  /// **'(questo dispositivo)'**
  String get devicesCurrent;

  /// No description provided for @devicesLastUsed.
  ///
  /// In it, this message translates to:
  /// **'Ultimo utilizzo: {when}'**
  String devicesLastUsed(String when);

  /// No description provided for @devicesRevoke.
  ///
  /// In it, this message translates to:
  /// **'Revoca'**
  String get devicesRevoke;

  /// No description provided for @devicesRevokeAllOthers.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti tutti gli altri dispositivi'**
  String get devicesRevokeAllOthers;

  /// No description provided for @devicesRevokeAllOthersBody.
  ///
  /// In it, this message translates to:
  /// **'Le altre sessioni attive verranno chiuse.'**
  String get devicesRevokeAllOthersBody;

  /// No description provided for @devicesRevokeConfirm.
  ///
  /// In it, this message translates to:
  /// **'Disconnettere «{device}»?'**
  String devicesRevokeConfirm(String device);

  /// No description provided for @devicesSignOut.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get devicesSignOut;

  /// No description provided for @devicesTitle.
  ///
  /// In it, this message translates to:
  /// **'Dispositivi collegati'**
  String get devicesTitle;

  /// No description provided for @editAddSnack.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi spuntino'**
  String get editAddSnack;

  /// No description provided for @editDayConsumedNotEditable.
  ///
  /// In it, this message translates to:
  /// **'Già consumato: non modificabile'**
  String get editDayConsumedNotEditable;

  /// No description provided for @editDayEditScheduleInstead.
  ///
  /// In it, this message translates to:
  /// **'Modifica invece lo schema, per tutte le giornate'**
  String get editDayEditScheduleInstead;

  /// No description provided for @editDayNotEditable.
  ///
  /// In it, this message translates to:
  /// **'Giornata non modificabile'**
  String get editDayNotEditable;

  /// No description provided for @editDayNotEditableReason.
  ///
  /// In it, this message translates to:
  /// **'Solo le giornate coperte da un piano attivo possono essere modificate'**
  String get editDayNotEditableReason;

  /// No description provided for @editDayOnlyThisDayNotice.
  ///
  /// In it, this message translates to:
  /// **'Le modifiche riguardano solo questa giornata: lo schema settimanale resta invariato.'**
  String get editDayOnlyThisDayNotice;

  /// No description provided for @editDaySave.
  ///
  /// In it, this message translates to:
  /// **'Salva giornata'**
  String get editDaySave;

  /// No description provided for @editDaySaved.
  ///
  /// In it, this message translates to:
  /// **'Giornata salvata.'**
  String get editDaySaved;

  /// No description provided for @editDayTitle.
  ///
  /// In it, this message translates to:
  /// **'Giornata del {date}'**
  String editDayTitle(String date);

  /// No description provided for @editDiscardBody.
  ///
  /// In it, this message translates to:
  /// **'Uscendo perderai le modifiche non salvate.'**
  String get editDiscardBody;

  /// No description provided for @editDiscardConfirm.
  ///
  /// In it, this message translates to:
  /// **'Esci senza salvare'**
  String get editDiscardConfirm;

  /// No description provided for @editDiscardTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifiche non salvate'**
  String get editDiscardTitle;

  /// No description provided for @editRecipeFieldsInvalid.
  ///
  /// In it, this message translates to:
  /// **'Controlla i campi della ricetta segnalati.'**
  String get editRecipeFieldsInvalid;

  /// No description provided for @editRecipeNameRequired.
  ///
  /// In it, this message translates to:
  /// **'Serve una denominazione se è presente il testo della ricetta'**
  String get editRecipeNameRequired;

  /// No description provided for @editRemoveSlotBody.
  ///
  /// In it, this message translates to:
  /// **'Il contenuto compilato andrà perso.'**
  String get editRemoveSlotBody;

  /// No description provided for @editRemoveSlotTitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuovere lo slot?'**
  String get editRemoveSlotTitle;

  /// No description provided for @errorAccountNotVerified.
  ///
  /// In it, this message translates to:
  /// **'Conferma prima il tuo indirizzo e-mail.'**
  String get errorAccountNotVerified;

  /// No description provided for @errorAlreadyInGroup.
  ///
  /// In it, this message translates to:
  /// **'Fai già parte di un gruppo: esci prima di crearne uno nuovo.'**
  String get errorAlreadyInGroup;

  /// No description provided for @errorAlreadyLinked.
  ///
  /// In it, this message translates to:
  /// **'La persona è già collegata a un nutrizionista: serve prima la revoca di quel collegamento.'**
  String get errorAlreadyLinked;

  /// No description provided for @errorAuthenticationRequired.
  ///
  /// In it, this message translates to:
  /// **'Devi accedere per continuare.'**
  String get errorAuthenticationRequired;

  /// No description provided for @errorCareLinkNotActive.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento è già stato revocato.'**
  String get errorCareLinkNotActive;

  /// No description provided for @errorCareLinkRequestAlreadyPending.
  ///
  /// In it, this message translates to:
  /// **'Hai già una richiesta in attesa verso questa persona.'**
  String get errorCareLinkRequestAlreadyPending;

  /// No description provided for @errorCareLinkRequestNotPending.
  ///
  /// In it, this message translates to:
  /// **'Questa richiesta non è più in attesa.'**
  String get errorCareLinkRequestNotPending;

  /// No description provided for @errorEmailAlreadyUsed.
  ///
  /// In it, this message translates to:
  /// **'Questo indirizzo e-mail è già registrato.'**
  String get errorEmailAlreadyUsed;

  /// No description provided for @errorEmailAlreadyVerified.
  ///
  /// In it, this message translates to:
  /// **'Questo indirizzo è già stato verificato.'**
  String get errorEmailAlreadyVerified;

  /// ER-2: esito non riconosciuto.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa non ha funzionato. Riprova.'**
  String get errorGeneric;

  /// AU-23: messaggio deliberatamente indistinto.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo o password non corretti.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInviteCodeInvalid.
  ///
  /// In it, this message translates to:
  /// **'Il codice inserito non è valido.'**
  String get errorInviteCodeInvalid;

  /// No description provided for @errorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Connessione assente. Riprova.'**
  String get errorNetwork;

  /// No description provided for @errorNutritionistCannotJoinGroup.
  ///
  /// In it, this message translates to:
  /// **'Un Nutrizionista non può appartenere a un gruppo.'**
  String get errorNutritionistCannotJoinGroup;

  /// No description provided for @errorOwnerCookPrivilegeInseparable.
  ///
  /// In it, this message translates to:
  /// **'Il Proprietario non può rinunciare al privilegio di Cuoco: trasferisci prima la proprietà.'**
  String get errorOwnerCookPrivilegeInseparable;

  /// No description provided for @errorPasswordResetTokenInvalid.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento non è più valido. Richiedine uno nuovo.'**
  String get errorPasswordResetTokenInvalid;

  /// No description provided for @errorPasswordTooLong.
  ///
  /// In it, this message translates to:
  /// **'La password è troppo lunga.'**
  String get errorPasswordTooLong;

  /// No description provided for @errorPastDayNotEditable.
  ///
  /// In it, this message translates to:
  /// **'Le giornate trascorse non si possono modificare.'**
  String get errorPastDayNotEditable;

  /// No description provided for @errorPatientPlanLocked.
  ///
  /// In it, this message translates to:
  /// **'Il piano è a cura del tuo nutrizionista: puoi spuntare e invertire, non modificarne il contenuto.'**
  String get errorPatientPlanLocked;

  /// No description provided for @errorPlanActiveCannotDelete.
  ///
  /// In it, this message translates to:
  /// **'Un piano Attivo non può essere eliminato: sospendilo o concludilo prima.'**
  String get errorPlanActiveCannotDelete;

  /// No description provided for @errorPlanIncomplete.
  ///
  /// In it, this message translates to:
  /// **'Lo schema settimanale non è ancora completo.'**
  String get errorPlanIncomplete;

  /// No description provided for @errorPlanNotActive.
  ///
  /// In it, this message translates to:
  /// **'Questa giornata non è coperta da un piano attivo.'**
  String get errorPlanNotActive;

  /// No description provided for @errorPlanPeriodOverlap.
  ///
  /// In it, this message translates to:
  /// **'Il periodo si sovrappone a un piano esistente.'**
  String get errorPlanPeriodOverlap;

  /// No description provided for @errorPlanScheduleNotEditable.
  ///
  /// In it, this message translates to:
  /// **'Lo schema di questo piano non è più modificabile.'**
  String get errorPlanScheduleNotEditable;

  /// No description provided for @errorPlanTransitionNotAllowed.
  ///
  /// In it, this message translates to:
  /// **'Questa operazione non è più possibile per il piano.'**
  String get errorPlanTransitionNotAllowed;

  /// No description provided for @errorRefreshTokenInvalid.
  ///
  /// In it, this message translates to:
  /// **'La sessione non è più valida. Accedi di nuovo.'**
  String get errorRefreshTokenInvalid;

  /// No description provided for @errorSlotAlreadyConsumed.
  ///
  /// In it, this message translates to:
  /// **'Questo pasto è già stato consumato.'**
  String get errorSlotAlreadyConsumed;

  /// No description provided for @errorSwapDifferentDays.
  ///
  /// In it, this message translates to:
  /// **'Devono appartenere allo stesso giorno.'**
  String get errorSwapDifferentDays;

  /// No description provided for @errorSwapDifferentWeeks.
  ///
  /// In it, this message translates to:
  /// **'Appartengono a settimane diverse.'**
  String get errorSwapDifferentWeeks;

  /// No description provided for @errorSwapPastDay.
  ///
  /// In it, this message translates to:
  /// **'Questo giorno è già trascorso.'**
  String get errorSwapPastDay;

  /// No description provided for @errorSwapTypeNotAllowed.
  ///
  /// In it, this message translates to:
  /// **'Questi pasti non sono invertibili tra loro.'**
  String get errorSwapTypeNotAllowed;

  /// No description provided for @errorTimezoneInvalid.
  ///
  /// In it, this message translates to:
  /// **'Fuso orario non riconosciuto.'**
  String get errorTimezoneInvalid;

  /// No description provided for @errorUsernameAlreadyUsed.
  ///
  /// In it, this message translates to:
  /// **'Questo nome utente è già in uso.'**
  String get errorUsernameAlreadyUsed;

  /// ER-2: codice VALIDATION_FAILED.
  ///
  /// In it, this message translates to:
  /// **'Controlla i dati inseriti.'**
  String get errorValidationFailed;

  /// No description provided for @errorVerificationResendRateLimited.
  ///
  /// In it, this message translates to:
  /// **'Hai richiesto troppi reinvii. Riprova tra qualche minuto.'**
  String get errorVerificationResendRateLimited;

  /// No description provided for @errorVerificationTokenInvalid.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento non è più valido. Richiedine uno nuovo.'**
  String get errorVerificationTokenInvalid;

  /// No description provided for @errorWorkoutFutureDate.
  ///
  /// In it, this message translates to:
  /// **'Un allenamento si registra quando è stato svolto: per il futuro c’è la pianificazione.'**
  String get errorWorkoutFutureDate;

  /// No description provided for @fieldBirthDate.
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get fieldBirthDate;

  /// No description provided for @fieldBirthPlace.
  ///
  /// In it, this message translates to:
  /// **'Luogo di nascita'**
  String get fieldBirthPlace;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldEmail.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo e-mail'**
  String get fieldEmail;

  /// No description provided for @fieldFirstName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get fieldFirstName;

  /// No description provided for @fieldHeight.
  ///
  /// In it, this message translates to:
  /// **'Altezza'**
  String get fieldHeight;

  /// No description provided for @fieldHeightCm.
  ///
  /// In it, this message translates to:
  /// **'Altezza (cm)'**
  String get fieldHeightCm;

  /// No description provided for @fieldLastName.
  ///
  /// In it, this message translates to:
  /// **'Cognome'**
  String get fieldLastName;

  /// No description provided for @fieldPassword.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldUsername.
  ///
  /// In it, this message translates to:
  /// **'Nome utente'**
  String get fieldUsername;

  /// No description provided for @groupCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea un gruppo'**
  String get groupCreate;

  /// No description provided for @groupDissolve.
  ///
  /// In it, this message translates to:
  /// **'Sciogli il gruppo'**
  String get groupDissolve;

  /// No description provided for @groupDissolveBody.
  ///
  /// In it, this message translates to:
  /// **'Tutti i membri usciranno dal gruppo. Ciascuno conserverà il proprio piano e il proprio storico: nessun dato personale è coinvolto.'**
  String get groupDissolveBody;

  /// No description provided for @groupDissolveTitle.
  ///
  /// In it, this message translates to:
  /// **'Sciogliere il gruppo?'**
  String get groupDissolveTitle;

  /// No description provided for @groupJoinConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma adesione'**
  String get groupJoinConfirm;

  /// No description provided for @groupJoinNoticeStart.
  ///
  /// In it, this message translates to:
  /// **'I tuoi pasti diventeranno visibili agli altri membri, e i Cuochi potranno operare inversioni e spunte sul tuo piano.'**
  String get groupJoinNoticeStart;

  /// No description provided for @groupJoinWithCode.
  ///
  /// In it, this message translates to:
  /// **'Entra con un codice'**
  String get groupJoinWithCode;

  /// No description provided for @groupLeave.
  ///
  /// In it, this message translates to:
  /// **'Esci dal gruppo'**
  String get groupLeave;

  /// No description provided for @groupLeaveKeepsData.
  ///
  /// In it, this message translates to:
  /// **'Conserverai il tuo piano e il tuo storico.'**
  String get groupLeaveKeepsData;

  /// No description provided for @groupLeaveTitle.
  ///
  /// In it, this message translates to:
  /// **'Uscire dal gruppo?'**
  String get groupLeaveTitle;

  /// No description provided for @groupMemberCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 membro} other{{count} membri}}'**
  String groupMemberCount(int count);

  /// No description provided for @groupNone.
  ///
  /// In it, this message translates to:
  /// **'Non fai parte di un gruppo'**
  String get groupNone;

  /// No description provided for @groupNoneDescription.
  ///
  /// In it, this message translates to:
  /// **'Un gruppo serve a organizzare i pasti di più persone che cucinano insieme'**
  String get groupNoneDescription;

  /// No description provided for @groupOnlyMember.
  ///
  /// In it, this message translates to:
  /// **'Sei l\'unico membro'**
  String get groupOnlyMember;

  /// No description provided for @groupPromoteCook.
  ///
  /// In it, this message translates to:
  /// **'Nomina Cuoco'**
  String get groupPromoteCook;

  /// No description provided for @groupRemoveMember.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dal gruppo'**
  String get groupRemoveMember;

  /// No description provided for @groupRemoveMemberBody.
  ///
  /// In it, this message translates to:
  /// **'{name} conserverà il proprio piano e il proprio storico.'**
  String groupRemoveMemberBody(String name);

  /// No description provided for @groupRemoveMemberTitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuovere dal gruppo?'**
  String get groupRemoveMemberTitle;

  /// No description provided for @groupRename.
  ///
  /// In it, this message translates to:
  /// **'Modifica denominazione'**
  String get groupRename;

  /// No description provided for @groupRevokeCook.
  ///
  /// In it, this message translates to:
  /// **'Revoca privilegio di Cuoco'**
  String get groupRevokeCook;

  /// No description provided for @groupRoleCook.
  ///
  /// In it, this message translates to:
  /// **'Cuoco'**
  String get groupRoleCook;

  /// No description provided for @groupRoleOwner.
  ///
  /// In it, this message translates to:
  /// **'Proprietario'**
  String get groupRoleOwner;

  /// No description provided for @groupTransferFirstBody.
  ///
  /// In it, this message translates to:
  /// **'Per uscire dal gruppo devi prima trasferirne la proprietà a un altro membro, dal menu accanto al suo nome.'**
  String get groupTransferFirstBody;

  /// No description provided for @groupTransferFirstTitle.
  ///
  /// In it, this message translates to:
  /// **'Trasferisci prima la proprietà'**
  String get groupTransferFirstTitle;

  /// No description provided for @groupTransferOwnership.
  ///
  /// In it, this message translates to:
  /// **'Trasferisci proprietà'**
  String get groupTransferOwnership;

  /// No description provided for @groupTransferOwnershipBody.
  ///
  /// In it, this message translates to:
  /// **'{name} diventerà Proprietario del gruppo. Il trasferimento non è annullabile: solo il nuovo Proprietario potrà restituirla.'**
  String groupTransferOwnershipBody(String name);

  /// No description provided for @groupTransferOwnershipTitle.
  ///
  /// In it, this message translates to:
  /// **'Trasferire la proprietà?'**
  String get groupTransferOwnershipTitle;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In it, this message translates to:
  /// **'Codice copiato'**
  String get inviteCodeCopied;

  /// No description provided for @inviteCodeField.
  ///
  /// In it, this message translates to:
  /// **'Codice di invito'**
  String get inviteCodeField;

  /// No description provided for @inviteExpiresInDays.
  ///
  /// In it, this message translates to:
  /// **'Tra {days} giorni'**
  String inviteExpiresInDays(int days);

  /// No description provided for @inviteExpiresOn.
  ///
  /// In it, this message translates to:
  /// **'Scade il {date}'**
  String inviteExpiresOn(String date);

  /// No description provided for @inviteExpiry.
  ///
  /// In it, this message translates to:
  /// **'Scadenza'**
  String get inviteExpiry;

  /// No description provided for @inviteGenerate.
  ///
  /// In it, this message translates to:
  /// **'Genera codice'**
  String get inviteGenerate;

  /// No description provided for @inviteMaxUses.
  ///
  /// In it, this message translates to:
  /// **'Numero massimo di utilizzi (facoltativo)'**
  String get inviteMaxUses;

  /// No description provided for @inviteNoActiveCode.
  ///
  /// In it, this message translates to:
  /// **'Nessun codice attivo'**
  String get inviteNoActiveCode;

  /// No description provided for @inviteNoExpiry.
  ///
  /// In it, this message translates to:
  /// **'Nessuna scadenza'**
  String get inviteNoExpiry;

  /// No description provided for @inviteRemainingUses.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 utilizzo rimasto} other{{count} utilizzi rimasti}}'**
  String inviteRemainingUses(int count);

  /// No description provided for @inviteShareMessage.
  ///
  /// In it, this message translates to:
  /// **'Unisciti al mio gruppo «{group}» su HealthyLog con il codice {code}'**
  String inviteShareMessage(String group, String code);

  /// No description provided for @inviteePatientCheckUsername.
  ///
  /// In it, this message translates to:
  /// **'Verifica il nome utente e riprova'**
  String get inviteePatientCheckUsername;

  /// No description provided for @inviteePatientMessage.
  ///
  /// In it, this message translates to:
  /// **'Messaggio di presentazione'**
  String get inviteePatientMessage;

  /// No description provided for @inviteePatientMessageHint.
  ///
  /// In it, this message translates to:
  /// **'Aiuta la persona a riconoscerti'**
  String get inviteePatientMessageHint;

  /// No description provided for @inviteePatientNotFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun utente con questo nome'**
  String get inviteePatientNotFound;

  /// No description provided for @inviteePatientSend.
  ///
  /// In it, this message translates to:
  /// **'Invia richiesta'**
  String get inviteePatientSend;

  /// No description provided for @inviteePatientTitle.
  ///
  /// In it, this message translates to:
  /// **'Invita un paziente'**
  String get inviteePatientTitle;

  /// No description provided for @inviteePatientUsernameHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il nome utente esatto della persona'**
  String get inviteePatientUsernameHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginSubmit;

  /// No description provided for @loginToRegister.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Registrati'**
  String get loginToRegister;

  /// No description provided for @mealChange.
  ///
  /// In it, this message translates to:
  /// **'Cambia'**
  String get mealChange;

  /// No description provided for @mealChangeStatusTitle.
  ///
  /// In it, this message translates to:
  /// **'Cambiare stato?'**
  String get mealChangeStatusTitle;

  /// No description provided for @mealFutureDayBody.
  ///
  /// In it, this message translates to:
  /// **'Questo giorno non è ancora arrivato.'**
  String get mealFutureDayBody;

  /// No description provided for @mealFutureDayTitle.
  ///
  /// In it, this message translates to:
  /// **'Registrare un pasto futuro?'**
  String get mealFutureDayTitle;

  /// No description provided for @mealMove.
  ///
  /// In it, this message translates to:
  /// **'Sposta'**
  String get mealMove;

  /// No description provided for @mealOfflineUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Non disponibile offline.'**
  String get mealOfflineUnavailable;

  /// No description provided for @mealReplacementNote.
  ///
  /// In it, this message translates to:
  /// **'Nota di sostituzione'**
  String get mealReplacementNote;

  /// No description provided for @mealReplacementNoteLost.
  ///
  /// In it, this message translates to:
  /// **'La nota di sostituzione andrà perduta in modo definitivo.'**
  String get mealReplacementNoteLost;

  /// No description provided for @mealSeeRecipe.
  ///
  /// In it, this message translates to:
  /// **'Vedi ricetta'**
  String get mealSeeRecipe;

  /// CU-4: l’attribuzione dell’operazione compiuta dal Cuoco.
  ///
  /// In it, this message translates to:
  /// **'{verb} da {name}'**
  String mealStatusByCook(String verb, String name);

  /// No description provided for @mealStatusVerbConsumed.
  ///
  /// In it, this message translates to:
  /// **'Consumato'**
  String get mealStatusVerbConsumed;

  /// No description provided for @mealStatusVerbRestored.
  ///
  /// In it, this message translates to:
  /// **'Ripristinato'**
  String get mealStatusVerbRestored;

  /// No description provided for @mealStatusVerbSkipped.
  ///
  /// In it, this message translates to:
  /// **'Saltato'**
  String get mealStatusVerbSkipped;

  /// No description provided for @mealSwappedNotification.
  ///
  /// In it, this message translates to:
  /// **'Due pasti del tuo piano sono stati invertiti{when}.'**
  String mealSwappedNotification(String when);

  /// No description provided for @mealTick.
  ///
  /// In it, this message translates to:
  /// **'Spunta'**
  String get mealTick;

  /// No description provided for @measureArm.
  ///
  /// In it, this message translates to:
  /// **'Braccio'**
  String get measureArm;

  /// No description provided for @measureChest.
  ///
  /// In it, this message translates to:
  /// **'Torace'**
  String get measureChest;

  /// No description provided for @measureHips.
  ///
  /// In it, this message translates to:
  /// **'Fianchi'**
  String get measureHips;

  /// No description provided for @measureNamedValueWithUnit.
  ///
  /// In it, this message translates to:
  /// **'{measure}: {value} {unit}'**
  String measureNamedValueWithUnit(String measure, String value, String unit);

  /// No description provided for @measureThigh.
  ///
  /// In it, this message translates to:
  /// **'Coscia'**
  String get measureThigh;

  /// No description provided for @measureValueWithUnit.
  ///
  /// In it, this message translates to:
  /// **'{value} {unit}'**
  String measureValueWithUnit(String value, String unit);

  /// No description provided for @measureWaist.
  ///
  /// In it, this message translates to:
  /// **'Vita'**
  String get measureWaist;

  /// No description provided for @measureWeight.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get measureWeight;

  /// No description provided for @measureWithUnit.
  ///
  /// In it, this message translates to:
  /// **'{measure} ({unit})'**
  String measureWithUnit(String measure, String unit);

  /// No description provided for @measurementAtLeastOneValue.
  ///
  /// In it, this message translates to:
  /// **'Inserisci almeno un valore'**
  String get measurementAtLeastOneValue;

  /// No description provided for @measurementByNutritionist.
  ///
  /// In it, this message translates to:
  /// **'Rilevata dal tuo nutrizionista.'**
  String get measurementByNutritionist;

  /// No description provided for @measurementDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questa misurazione?'**
  String get measurementDeleteConfirm;

  /// No description provided for @measurementEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica misurazione'**
  String get measurementEditTitle;

  /// No description provided for @measurementForPatientNotice.
  ///
  /// In it, this message translates to:
  /// **'La registri tu: la persona potrà consultarla ma non modificarla.'**
  String get measurementForPatientNotice;

  /// No description provided for @measurementNoneRecorded.
  ///
  /// In it, this message translates to:
  /// **'Nessuna misurazione registrata'**
  String get measurementNoneRecorded;

  /// No description provided for @measurementRecord.
  ///
  /// In it, this message translates to:
  /// **'Registra misurazione'**
  String get measurementRecord;

  /// No description provided for @measurementRecordTitle.
  ///
  /// In it, this message translates to:
  /// **'Registra una misurazione'**
  String get measurementRecordTitle;

  /// No description provided for @memberSelectorSideBySide.
  ///
  /// In it, this message translates to:
  /// **'Vista affiancata'**
  String get memberSelectorSideBySide;

  /// No description provided for @memberSelectorSingle.
  ///
  /// In it, this message translates to:
  /// **'Vista singola'**
  String get memberSelectorSingle;

  /// No description provided for @memberViewingPlanOf.
  ///
  /// In it, this message translates to:
  /// **'Stai vedendo il piano di {name}'**
  String memberViewingPlanOf(String name);

  /// No description provided for @navActivity.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get navActivity;

  /// No description provided for @navNotAvailableYet.
  ///
  /// In it, this message translates to:
  /// **'{destination}: non ancora disponibile.'**
  String navNotAvailableYet(String destination);

  /// No description provided for @navPatients.
  ///
  /// In it, this message translates to:
  /// **'Pazienti'**
  String get navPatients;

  /// No description provided for @navPlan.
  ///
  /// In it, this message translates to:
  /// **'Piano'**
  String get navPlan;

  /// No description provided for @navProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get navProfile;

  /// No description provided for @navStatistics.
  ///
  /// In it, this message translates to:
  /// **'Statistiche'**
  String get navStatistics;

  /// No description provided for @navTemplates.
  ///
  /// In it, this message translates to:
  /// **'Template'**
  String get navTemplates;

  /// No description provided for @notificationCareLinkRevoked.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento professionale è stato revocato.'**
  String get notificationCareLinkRevoked;

  /// No description provided for @notificationCareRequestAccepted.
  ///
  /// In it, this message translates to:
  /// **'La tua richiesta di collegamento è stata accettata.'**
  String get notificationCareRequestAccepted;

  /// No description provided for @notificationCareRequestReceived.
  ///
  /// In it, this message translates to:
  /// **'Hai ricevuto una richiesta di collegamento professionale.'**
  String get notificationCareRequestReceived;

  /// No description provided for @notificationCareRequestRejected.
  ///
  /// In it, this message translates to:
  /// **'La tua richiesta di collegamento è stata rifiutata.'**
  String get notificationCareRequestRejected;

  /// No description provided for @notificationGroupCookGranted.
  ///
  /// In it, this message translates to:
  /// **'Sei stato nominato Cuoco del gruppo{group}.'**
  String notificationGroupCookGranted(String group);

  /// No description provided for @notificationGroupCookRevoked.
  ///
  /// In it, this message translates to:
  /// **'Non sei più Cuoco del gruppo{group}.'**
  String notificationGroupCookRevoked(String group);

  /// No description provided for @notificationGroupDisbanded.
  ///
  /// In it, this message translates to:
  /// **'Il gruppo{group} è stato sciolto.'**
  String notificationGroupDisbanded(String group);

  /// No description provided for @notificationGroupMemberRemoved.
  ///
  /// In it, this message translates to:
  /// **'Sei stato rimosso dal gruppo{group}.'**
  String notificationGroupMemberRemoved(String group);

  /// No description provided for @notificationGroupOwnershipTransferred.
  ///
  /// In it, this message translates to:
  /// **'Sei diventato Proprietario del gruppo{group}.'**
  String notificationGroupOwnershipTransferred(String group);

  /// No description provided for @notificationInForceFrom.
  ///
  /// In it, this message translates to:
  /// **', in vigore dal {date}'**
  String notificationInForceFrom(String date);

  /// No description provided for @notificationMeasurementRecorded.
  ///
  /// In it, this message translates to:
  /// **'È stata registrata una misurazione del {date}.'**
  String notificationMeasurementRecorded(String date);

  /// No description provided for @notificationOnDay.
  ///
  /// In it, this message translates to:
  /// **' nella giornata del {date}'**
  String notificationOnDay(String date);

  /// NT-6: determinata dal sistema — la formulazione non attribuisce l’atto a nessuno.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è entrato in vigore.'**
  String notificationPlanActivatedAutomatically(String plan);

  /// AS-8: denominazione, autore e data di decorrenza.
  ///
  /// In it, this message translates to:
  /// **'Ti è stato assegnato il piano{plan}{from}.'**
  String notificationPlanAssigned(String plan, String from);

  /// No description provided for @notificationPlanCompleted.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è stato concluso.'**
  String notificationPlanCompleted(String plan);

  /// No description provided for @notificationPlanCompletedAutomatically.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} si è concluso alla data prevista.'**
  String notificationPlanCompletedAutomatically(String plan);

  /// No description provided for @notificationPlanDayModified.
  ///
  /// In it, this message translates to:
  /// **'La giornata del {date} del piano{plan} è stata modificata.'**
  String notificationPlanDayModified(String date, String plan);

  /// No description provided for @notificationPlanModified.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è stato modificato.'**
  String notificationPlanModified(String plan);

  /// GG-11, LO-3: la denominazione è contenuto dell’Utente e non va tradotta.
  ///
  /// In it, this message translates to:
  /// **' «{name}»'**
  String notificationPlanNameQuoted(String name);

  /// No description provided for @notificationPlanResumed.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è stato ripreso.'**
  String notificationPlanResumed(String plan);

  /// No description provided for @notificationPlanSuspended.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è stato sospeso.'**
  String notificationPlanSuspended(String plan);

  /// No description provided for @notificationPlanWithdrawn.
  ///
  /// In it, this message translates to:
  /// **'Il piano{plan} è stato ritirato ed è tornato in revisione.'**
  String notificationPlanWithdrawn(String plan);

  /// La forma preposizionale evita l’accordo di genere con il participio.
  ///
  /// In it, this message translates to:
  /// **'{slot} del {date} è stato registrato lo stato {status}.'**
  String notificationSlotMarked(String slot, String date, String status);

  /// No description provided for @notificationSlotOnBreakfast.
  ///
  /// In it, this message translates to:
  /// **'Sulla colazione'**
  String get notificationSlotOnBreakfast;

  /// No description provided for @notificationSlotOnDinner.
  ///
  /// In it, this message translates to:
  /// **'Sulla cena'**
  String get notificationSlotOnDinner;

  /// No description provided for @notificationSlotOnGeneric.
  ///
  /// In it, this message translates to:
  /// **'Su un pasto'**
  String get notificationSlotOnGeneric;

  /// No description provided for @notificationSlotOnLunch.
  ///
  /// In it, this message translates to:
  /// **'Sul pranzo'**
  String get notificationSlotOnLunch;

  /// No description provided for @notificationSlotOnSnack.
  ///
  /// In it, this message translates to:
  /// **'Sullo spuntino'**
  String get notificationSlotOnSnack;

  /// No description provided for @notificationStatusConsumed.
  ///
  /// In it, this message translates to:
  /// **'«Consumato»'**
  String get notificationStatusConsumed;

  /// No description provided for @notificationStatusSkipped.
  ///
  /// In it, this message translates to:
  /// **'«Saltato»'**
  String get notificationStatusSkipped;

  /// No description provided for @notificationStatusToConsume.
  ///
  /// In it, this message translates to:
  /// **'«Da consumare»'**
  String get notificationStatusToConsume;

  /// Tipo non riconosciuto da questa versione del client.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un evento che riguarda il tuo account.'**
  String get notificationUnknown;

  /// No description provided for @notificationsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna notifica'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In it, this message translates to:
  /// **'Segna tutte come lette'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notificationsTitle;

  /// OF-6, OF-19: segnalazione discreta, non condizione di errore.
  ///
  /// In it, this message translates to:
  /// **'Sei offline. Puoi consultare il piano già scaricato.'**
  String get offlineBar;

  /// AU-3: unico requisito, senza vincoli di composizione.
  ///
  /// In it, this message translates to:
  /// **'Almeno 12 caratteri'**
  String get passwordRequirementHint;

  /// No description provided for @passwordResetConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Imposta una nuova password'**
  String get passwordResetConfirmTitle;

  /// No description provided for @passwordResetDone.
  ///
  /// In it, this message translates to:
  /// **'Tutte le sessioni sono state chiuse. Accedi con la nuova password.'**
  String get passwordResetDone;

  /// No description provided for @passwordResetLinkExpiredBody.
  ///
  /// In it, this message translates to:
  /// **'Richiedine uno nuovo dalla schermata di accesso.'**
  String get passwordResetLinkExpiredBody;

  /// No description provided for @passwordResetLinkExpiredTitle.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento non è più valido'**
  String get passwordResetLinkExpiredTitle;

  /// No description provided for @passwordResetNewPassword.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get passwordResetNewPassword;

  /// No description provided for @passwordResetRequestNewLink.
  ///
  /// In it, this message translates to:
  /// **'Richiedi un nuovo collegamento'**
  String get passwordResetRequestNewLink;

  /// AC-17: l'esito non rivela l'esistenza dell'account.
  ///
  /// In it, this message translates to:
  /// **'Se esiste un account con questo indirizzo, riceverai un collegamento tra pochi istanti.'**
  String get passwordResetRequestSent;

  /// No description provided for @passwordResetRequestSubmit.
  ///
  /// In it, this message translates to:
  /// **'Invia collegamento'**
  String get passwordResetRequestSubmit;

  /// No description provided for @passwordResetRequestSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ti invieremo un collegamento per impostare una nuova password'**
  String get passwordResetRequestSubtitle;

  /// No description provided for @passwordResetRequestTitle.
  ///
  /// In it, this message translates to:
  /// **'Recupera l\'accesso'**
  String get passwordResetRequestTitle;

  /// No description provided for @passwordResetSubmit.
  ///
  /// In it, this message translates to:
  /// **'Reimposta password'**
  String get passwordResetSubmit;

  /// No description provided for @patientAdherenceWithPeriod.
  ///
  /// In it, this message translates to:
  /// **'Aderenza · {period}'**
  String patientAdherenceWithPeriod(String period);

  /// No description provided for @patientCreatePlan.
  ///
  /// In it, this message translates to:
  /// **'Crea un nuovo piano'**
  String get patientCreatePlan;

  /// No description provided for @patientCurrentPlanHeader.
  ///
  /// In it, this message translates to:
  /// **'PIANO IN CORSO'**
  String get patientCurrentPlanHeader;

  /// No description provided for @patientEditDay.
  ///
  /// In it, this message translates to:
  /// **'Modifica una giornata'**
  String get patientEditDay;

  /// No description provided for @patientLinkedSince.
  ///
  /// In it, this message translates to:
  /// **'Collegato dal {date}'**
  String patientLinkedSince(String date);

  /// No description provided for @patientMeasureChange.
  ///
  /// In it, this message translates to:
  /// **'{measure}: {change} {unit}'**
  String patientMeasureChange(String measure, String change, String unit);

  /// No description provided for @patientMeasureSingleValue.
  ///
  /// In it, this message translates to:
  /// **'{measure}: un solo valore nel periodo'**
  String patientMeasureSingleValue(String measure);

  /// No description provided for @patientMeasurementsHeader.
  ///
  /// In it, this message translates to:
  /// **'MISURAZIONI'**
  String get patientMeasurementsHeader;

  /// No description provided for @patientMonthStatisticsHeader.
  ///
  /// In it, this message translates to:
  /// **'STATISTICHE DEL MESE'**
  String get patientMonthStatisticsHeader;

  /// No description provided for @patientNoCurrentPlan.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano in corso redatto da te.'**
  String get patientNoCurrentPlan;

  /// No description provided for @patientNoMeasurements.
  ///
  /// In it, this message translates to:
  /// **'Nessuna misurazione'**
  String get patientNoMeasurements;

  /// No description provided for @patientNoWorkouts.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento'**
  String get patientNoWorkouts;

  /// No description provided for @patientOtherPlansHeader.
  ///
  /// In it, this message translates to:
  /// **'ALTRI PIANI REDATTI'**
  String get patientOtherPlansHeader;

  /// No description provided for @patientPickDay.
  ///
  /// In it, this message translates to:
  /// **'Giornata da modificare'**
  String get patientPickDay;

  /// No description provided for @patientPlanWithStatus.
  ///
  /// In it, this message translates to:
  /// **'{plan} · {status}'**
  String patientPlanWithStatus(String plan, String status);

  /// No description provided for @patientSortAdherence.
  ///
  /// In it, this message translates to:
  /// **'Aderenza'**
  String get patientSortAdherence;

  /// No description provided for @patientSortName.
  ///
  /// In it, this message translates to:
  /// **'Alfabetico'**
  String get patientSortName;

  /// No description provided for @patientSortRecentActivity.
  ///
  /// In it, this message translates to:
  /// **'Attività recente'**
  String get patientSortRecentActivity;

  /// No description provided for @patientWithdrawBody.
  ///
  /// In it, this message translates to:
  /// **'Il paziente non lo vedrà più.'**
  String get patientWithdrawBody;

  /// No description provided for @patientWorkoutsHeader.
  ///
  /// In it, this message translates to:
  /// **'ALLENAMENTI'**
  String get patientWorkoutsHeader;

  /// No description provided for @patientsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun paziente collegato'**
  String get patientsEmpty;

  /// No description provided for @patientsInvite.
  ///
  /// In it, this message translates to:
  /// **'Invita paziente'**
  String get patientsInvite;

  /// No description provided for @patientsInviteHint.
  ///
  /// In it, this message translates to:
  /// **'Invita un paziente con il suo nome utente'**
  String get patientsInviteHint;

  /// No description provided for @patientsPendingRequests.
  ///
  /// In it, this message translates to:
  /// **'RICHIESTE PENDENTI'**
  String get patientsPendingRequests;

  /// No description provided for @patientsRequestSent.
  ///
  /// In it, this message translates to:
  /// **'Richiesta inviata.'**
  String get patientsRequestSent;

  /// No description provided for @patientsRequestSentOn.
  ///
  /// In it, this message translates to:
  /// **'Inviata il {date} · In attesa'**
  String patientsRequestSentOn(String date);

  /// No description provided for @patientsSelect.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un paziente'**
  String get patientsSelect;

  /// No description provided for @patientsSortBy.
  ///
  /// In it, this message translates to:
  /// **'Ordina'**
  String get patientsSortBy;

  /// No description provided for @periodMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese'**
  String get periodMonth;

  /// No description provided for @periodPlan.
  ///
  /// In it, this message translates to:
  /// **'Piano'**
  String get periodPlan;

  /// No description provided for @periodWeek.
  ///
  /// In it, this message translates to:
  /// **'Settimana'**
  String get periodWeek;

  /// No description provided for @personalDataRoleNotChangeable.
  ///
  /// In it, this message translates to:
  /// **'Il ruolo non è modificabile'**
  String get personalDataRoleNotChangeable;

  /// No description provided for @personalDataSaved.
  ///
  /// In it, this message translates to:
  /// **'Dati aggiornati.'**
  String get personalDataSaved;

  /// No description provided for @personalDataTargetWeight.
  ///
  /// In it, this message translates to:
  /// **'Peso obiettivo'**
  String get personalDataTargetWeight;

  /// No description provided for @personalDataTargetWeightKg.
  ///
  /// In it, this message translates to:
  /// **'Peso obiettivo (kg)'**
  String get personalDataTargetWeightKg;

  /// No description provided for @personalDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Dati personali'**
  String get personalDataTitle;

  /// No description provided for @planActionComplete.
  ///
  /// In it, this message translates to:
  /// **'Concludi'**
  String get planActionComplete;

  /// No description provided for @planActionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get planActionDelete;

  /// No description provided for @planActionEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get planActionEdit;

  /// No description provided for @planActionReactivate.
  ///
  /// In it, this message translates to:
  /// **'Riattiva'**
  String get planActionReactivate;

  /// No description provided for @planActionResume.
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get planActionResume;

  /// No description provided for @planActionSuspend.
  ///
  /// In it, this message translates to:
  /// **'Sospendi'**
  String get planActionSuspend;

  /// No description provided for @planActionWithdraw.
  ///
  /// In it, this message translates to:
  /// **'Ritira'**
  String get planActionWithdraw;

  /// No description provided for @planCompletedOn.
  ///
  /// In it, this message translates to:
  /// **'Piano concluso il {date}'**
  String planCompletedOn(String date);

  /// No description provided for @planCreateFirst.
  ///
  /// In it, this message translates to:
  /// **'Crea il tuo primo piano alimentare'**
  String get planCreateFirst;

  /// No description provided for @planCreateFromScratch.
  ///
  /// In it, this message translates to:
  /// **'Da zero'**
  String get planCreateFromScratch;

  /// No description provided for @planCreateFromScratchDescription.
  ///
  /// In it, this message translates to:
  /// **'Componi lo schema settimanale partendo da una struttura vuota'**
  String get planCreateFromScratchDescription;

  /// No description provided for @planCreateFromTemplate.
  ///
  /// In it, this message translates to:
  /// **'Da un template'**
  String get planCreateFromTemplate;

  /// No description provided for @planCreateFromTemplateDescription.
  ///
  /// In it, this message translates to:
  /// **'Parti da uno schema già pronto e modificalo'**
  String get planCreateFromTemplateDescription;

  /// No description provided for @planCreateSubmit.
  ///
  /// In it, this message translates to:
  /// **'Crea piano'**
  String get planCreateSubmit;

  /// No description provided for @planCreateTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo piano'**
  String get planCreateTitle;

  /// No description provided for @planDayView.
  ///
  /// In it, this message translates to:
  /// **'Giorno'**
  String get planDayView;

  /// No description provided for @planDeleteIrreversible.
  ///
  /// In it, this message translates to:
  /// **'L\'operazione non può essere annullata.'**
  String get planDeleteIrreversible;

  /// No description provided for @planDeleteLossAllPeriods.
  ///
  /// In it, this message translates to:
  /// **'Andranno perdute in modo definitivo, per tutti i periodi del piano:'**
  String get planDeleteLossAllPeriods;

  /// No description provided for @planDeleteLossDays.
  ///
  /// In it, this message translates to:
  /// **'•  le giornate e le spunte di consumo'**
  String get planDeleteLossDays;

  /// No description provided for @planDeleteLossStatistics.
  ///
  /// In it, this message translates to:
  /// **'•  le statistiche di aderenza'**
  String get planDeleteLossStatistics;

  /// No description provided for @planDeleteLossSwaps.
  ///
  /// In it, this message translates to:
  /// **'•  lo storico delle inversioni'**
  String get planDeleteLossSwaps;

  /// No description provided for @planDeleteLossThisPeriod.
  ///
  /// In it, this message translates to:
  /// **'Andranno perdute in modo definitivo, per questo periodo:'**
  String get planDeleteLossThisPeriod;

  /// No description provided for @planDeleteTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il piano?'**
  String get planDeleteTitle;

  /// No description provided for @planDeleteWorkoutsKept.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti e misurazioni dello stesso periodo restano.'**
  String get planDeleteWorkoutsKept;

  /// No description provided for @planEditThisDay.
  ///
  /// In it, this message translates to:
  /// **'Modifica questa giornata'**
  String get planEditThisDay;

  /// No description provided for @planEndDate.
  ///
  /// In it, this message translates to:
  /// **'Data di fine'**
  String get planEndDate;

  /// No description provided for @planMoreActions.
  ///
  /// In it, this message translates to:
  /// **'Altre azioni'**
  String get planMoreActions;

  /// No description provided for @planNoMealsPlanned.
  ///
  /// In it, this message translates to:
  /// **'Nessun pasto previsto'**
  String get planNoMealsPlanned;

  /// No description provided for @planNoneForThisDay.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano per questo giorno'**
  String get planNoneForThisDay;

  /// No description provided for @planNoneYet.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano ancora'**
  String get planNoneYet;

  /// No description provided for @planOpenEnded.
  ///
  /// In it, this message translates to:
  /// **'A tempo indeterminato'**
  String get planOpenEnded;

  /// No description provided for @planOverlapNotice.
  ///
  /// In it, this message translates to:
  /// **'Il periodo è già occupato da un altro piano ({start} – {end}).'**
  String planOverlapNotice(String start, String end);

  /// No description provided for @planOverlapNoticeOpen.
  ///
  /// In it, this message translates to:
  /// **'Il periodo è già occupato da un altro piano (dal {start}).'**
  String planOverlapNoticeOpen(String start);

  /// No description provided for @planOverlapWithName.
  ///
  /// In it, this message translates to:
  /// **'Si sovrappone a «{name}».'**
  String planOverlapWithName(String name);

  /// No description provided for @planPatientNoPlanYet.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nutrizionista non ha ancora redatto un piano'**
  String get planPatientNoPlanYet;

  /// No description provided for @planRecipient.
  ///
  /// In it, this message translates to:
  /// **'Destinatario'**
  String get planRecipient;

  /// No description provided for @planRecordWorkout.
  ///
  /// In it, this message translates to:
  /// **'Registra allenamento'**
  String get planRecordWorkout;

  /// No description provided for @planStartDate.
  ///
  /// In it, this message translates to:
  /// **'Data di inizio'**
  String get planStartDate;

  /// No description provided for @planStartsOn.
  ///
  /// In it, this message translates to:
  /// **'Il piano inizia il {date}'**
  String planStartsOn(String date);

  /// No description provided for @planStatusActive.
  ///
  /// In it, this message translates to:
  /// **'Attivo'**
  String get planStatusActive;

  /// No description provided for @planStatusCompleted.
  ///
  /// In it, this message translates to:
  /// **'Concluso'**
  String get planStatusCompleted;

  /// No description provided for @planStatusDraft.
  ///
  /// In it, this message translates to:
  /// **'Bozza'**
  String get planStatusDraft;

  /// No description provided for @planStatusLowerActive.
  ///
  /// In it, this message translates to:
  /// **'in corso'**
  String get planStatusLowerActive;

  /// No description provided for @planStatusLowerCompleted.
  ///
  /// In it, this message translates to:
  /// **'concluso'**
  String get planStatusLowerCompleted;

  /// No description provided for @planStatusLowerDraft.
  ///
  /// In it, this message translates to:
  /// **'bozza'**
  String get planStatusLowerDraft;

  /// No description provided for @planStatusLowerScheduled.
  ///
  /// In it, this message translates to:
  /// **'programmato'**
  String get planStatusLowerScheduled;

  /// No description provided for @planStatusLowerSuspended.
  ///
  /// In it, this message translates to:
  /// **'sospeso'**
  String get planStatusLowerSuspended;

  /// No description provided for @planStatusScheduled.
  ///
  /// In it, this message translates to:
  /// **'Programmato'**
  String get planStatusScheduled;

  /// No description provided for @planStatusSuspended.
  ///
  /// In it, this message translates to:
  /// **'Sospeso'**
  String get planStatusSuspended;

  /// No description provided for @planSuspended.
  ///
  /// In it, this message translates to:
  /// **'Piano sospeso'**
  String get planSuspended;

  /// No description provided for @planSuspendedHint.
  ///
  /// In it, this message translates to:
  /// **'Riprenderà quando lo deciderai'**
  String get planSuspendedHint;

  /// No description provided for @planViewNoSwaps.
  ///
  /// In it, this message translates to:
  /// **'Nessuna inversione su questo piano.'**
  String get planViewNoSwaps;

  /// No description provided for @planViewOngoing.
  ///
  /// In it, this message translates to:
  /// **'in corso'**
  String get planViewOngoing;

  /// No description provided for @planViewOngoingUpper.
  ///
  /// In it, this message translates to:
  /// **'IN CORSO'**
  String get planViewOngoingUpper;

  /// No description provided for @planViewOpenStatistics.
  ///
  /// In it, this message translates to:
  /// **'Apri le statistiche complete'**
  String get planViewOpenStatistics;

  /// No description provided for @planViewOverallAdherence.
  ///
  /// In it, this message translates to:
  /// **'Aderenza complessiva del piano'**
  String get planViewOverallAdherence;

  /// No description provided for @planViewPeriodRange.
  ///
  /// In it, this message translates to:
  /// **'Dal {start} a {end}'**
  String planViewPeriodRange(String start, String end);

  /// No description provided for @planViewPeriodStatistics.
  ///
  /// In it, this message translates to:
  /// **'Statistiche del periodo'**
  String get planViewPeriodStatistics;

  /// No description provided for @planViewPeriods.
  ///
  /// In it, this message translates to:
  /// **'Periodi di svolgimento'**
  String get planViewPeriods;

  /// No description provided for @planViewSwapHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico delle inversioni'**
  String get planViewSwapHistory;

  /// No description provided for @planViewWeeklySchedule.
  ///
  /// In it, this message translates to:
  /// **'Schema settimanale'**
  String get planViewWeeklySchedule;

  /// No description provided for @planWeekView.
  ///
  /// In it, this message translates to:
  /// **'Settimana'**
  String get planWeekView;

  /// No description provided for @plansActivateNow.
  ///
  /// In it, this message translates to:
  /// **'Attiva ora'**
  String get plansActivateNow;

  /// No description provided for @plansAdherencePercent.
  ///
  /// In it, this message translates to:
  /// **'{value}%'**
  String plansAdherencePercent(String value);

  /// No description provided for @plansAuthoredBy.
  ///
  /// In it, this message translates to:
  /// **'Redatto da {author}'**
  String plansAuthoredBy(String author);

  /// No description provided for @plansCompleteConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Potrai sempre riattivarlo in seguito.'**
  String get plansCompleteConfirmBody;

  /// No description provided for @plansCompleteConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Concludere il piano?'**
  String get plansCompleteConfirmTitle;

  /// No description provided for @plansCurrent.
  ///
  /// In it, this message translates to:
  /// **'In corso'**
  String get plansCurrent;

  /// No description provided for @plansDateRange.
  ///
  /// In it, this message translates to:
  /// **'{start} – {end}'**
  String plansDateRange(String start, String end);

  /// No description provided for @plansEmptyOwn.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora un piano alimentare.'**
  String get plansEmptyOwn;

  /// No description provided for @plansEmptyPatient.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nutrizionista non ha ancora redatto un piano.'**
  String get plansEmptyPatient;

  /// No description provided for @plansFrom.
  ///
  /// In it, this message translates to:
  /// **'Dal {date}'**
  String plansFrom(String date);

  /// No description provided for @plansPatientNotice.
  ///
  /// In it, this message translates to:
  /// **'Il contenuto del piano è a cura del tuo nutrizionista: puoi spuntare e invertire i pasti.'**
  String get plansPatientNotice;

  /// ST-8, ST-9: il piano riattivato è voce unica, con il numero di periodi accanto.
  ///
  /// In it, this message translates to:
  /// **'{count} periodi'**
  String plansPeriodCount(int count);

  /// No description provided for @plansStartHere.
  ///
  /// In it, this message translates to:
  /// **'Inizia da qui'**
  String get plansStartHere;

  /// No description provided for @plansWithdrawConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Tornerà in Bozza: potrai riprenderlo dalla redazione.'**
  String get plansWithdrawConfirmBody;

  /// No description provided for @plansWithdrawConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Ritirare il piano?'**
  String get plansWithdrawConfirmTitle;

  /// No description provided for @profileGroup.
  ///
  /// In it, this message translates to:
  /// **'Gruppo'**
  String get profileGroup;

  /// No description provided for @profileLogout.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi disconnetterti da questo dispositivo?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileNutritionist.
  ///
  /// In it, this message translates to:
  /// **'Nutrizionista'**
  String get profileNutritionist;

  /// No description provided for @profilePersonalData.
  ///
  /// In it, this message translates to:
  /// **'Dati personali'**
  String get profilePersonalData;

  /// No description provided for @profilePlans.
  ///
  /// In it, this message translates to:
  /// **'Piani'**
  String get profilePlans;

  /// No description provided for @profileSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get profileSettings;

  /// No description provided for @registerSubmit.
  ///
  /// In it, this message translates to:
  /// **'Crea account'**
  String get registerSubmit;

  /// No description provided for @roleNutritionist.
  ///
  /// In it, this message translates to:
  /// **'Nutrizionista'**
  String get roleNutritionist;

  /// No description provided for @roleNutritionistDescription.
  ///
  /// In it, this message translates to:
  /// **'Redigi e segui i piani dei tuoi pazienti'**
  String get roleNutritionistDescription;

  /// No description provided for @roleNutritionistTitle.
  ///
  /// In it, this message translates to:
  /// **'Sono un nutrizionista'**
  String get roleNutritionistTitle;

  /// No description provided for @roleSelectionNotChangeable.
  ///
  /// In it, this message translates to:
  /// **'La scelta non è modificabile in seguito'**
  String get roleSelectionNotChangeable;

  /// No description provided for @roleSelectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Come userai HealthyLog?'**
  String get roleSelectionTitle;

  /// No description provided for @roleUser.
  ///
  /// In it, this message translates to:
  /// **'Utente'**
  String get roleUser;

  /// No description provided for @roleUserDescription.
  ///
  /// In it, this message translates to:
  /// **'Consulti la tua dieta, segni i pasti e registri gli allenamenti'**
  String get roleUserDescription;

  /// No description provided for @roleUserTitle.
  ///
  /// In it, this message translates to:
  /// **'Seguo un piano'**
  String get roleUserTitle;

  /// No description provided for @scheduleConfirmPlan.
  ///
  /// In it, this message translates to:
  /// **'Conferma piano'**
  String get scheduleConfirmPlan;

  /// No description provided for @scheduleIncompleteTitle.
  ///
  /// In it, this message translates to:
  /// **'Schema incompleto'**
  String get scheduleIncompleteTitle;

  /// No description provided for @scheduleRetroactivityNotice.
  ///
  /// In it, this message translates to:
  /// **'Le modifiche decorrono da oggi e valgono per tutte le settimane: le giornate già trascorse restano invariate. Per cambiare una sola giornata, usa «Modifica questa giornata» dalla vista del giorno.'**
  String get scheduleRetroactivityNotice;

  /// No description provided for @scheduleSave.
  ///
  /// In it, this message translates to:
  /// **'Salva modifiche'**
  String get scheduleSave;

  /// No description provided for @scheduleSaveAsTemplate.
  ///
  /// In it, this message translates to:
  /// **'Salva come template'**
  String get scheduleSaveAsTemplate;

  /// No description provided for @scheduleSaved.
  ///
  /// In it, this message translates to:
  /// **'Piano salvato.'**
  String get scheduleSaved;

  /// CD-13: gli slot ancora privi di contenuto di una giornata.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 pasto senza contenuto} other{{count} pasti senza contenuto}}'**
  String scheduleSlotsWithoutContent(int count);

  /// No description provided for @scheduleTemplateCreated.
  ///
  /// In it, this message translates to:
  /// **'Template creato.'**
  String get scheduleTemplateCreated;

  /// No description provided for @scheduleTitle.
  ///
  /// In it, this message translates to:
  /// **'Redazione dello schema'**
  String get scheduleTitle;

  /// No description provided for @settingsDevices.
  ///
  /// In it, this message translates to:
  /// **'Dispositivi collegati'**
  String get settingsDevices;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguage;

  /// LO-1: come sopra.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// LO-1: le lingue si presentano nel proprio nome, non tradotte.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get settingsLanguageItalian;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionDateTime.
  ///
  /// In it, this message translates to:
  /// **'Data e ora'**
  String get settingsSectionDateTime;

  /// No description provided for @settingsSectionLanguageAndFormats.
  ///
  /// In it, this message translates to:
  /// **'Lingua e formati'**
  String get settingsSectionLanguageAndFormats;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In it, this message translates to:
  /// **'Sicurezza'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsThemeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTimezone.
  ///
  /// In it, this message translates to:
  /// **'Fuso orario'**
  String get settingsTimezone;

  /// No description provided for @settingsTimezoneSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca fuso orario'**
  String get settingsTimezoneSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @settingsUnitImperial.
  ///
  /// In it, this message translates to:
  /// **'Imperiale'**
  String get settingsUnitImperial;

  /// No description provided for @settingsUnitMetric.
  ///
  /// In it, this message translates to:
  /// **'Metrico'**
  String get settingsUnitMetric;

  /// No description provided for @settingsUnitRetroactiveNotice.
  ///
  /// In it, this message translates to:
  /// **'Il cambio si applica a tutti i dati, compresi grafici e storico.'**
  String get settingsUnitRetroactiveNotice;

  /// No description provided for @settingsUnitSystem.
  ///
  /// In it, this message translates to:
  /// **'Unità di misura'**
  String get settingsUnitSystem;

  /// No description provided for @sexFemale.
  ///
  /// In it, this message translates to:
  /// **'Femmina'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In it, this message translates to:
  /// **'Maschio'**
  String get sexMale;

  /// No description provided for @signedNegative.
  ///
  /// In it, this message translates to:
  /// **'−{value}'**
  String signedNegative(String value);

  /// AN-10: la variazione reca il proprio segno, senza qualificazioni.
  ///
  /// In it, this message translates to:
  /// **'+{value}'**
  String signedPositive(String value);

  /// No description provided for @slotAccessoryNote.
  ///
  /// In it, this message translates to:
  /// **'Nota accessoria'**
  String get slotAccessoryNote;

  /// No description provided for @slotAddOfType.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi {type}'**
  String slotAddOfType(String type);

  /// No description provided for @slotAdherenceWeight.
  ///
  /// In it, this message translates to:
  /// **'Peso di aderenza: {value}'**
  String slotAdherenceWeight(String value);

  /// No description provided for @slotAdherenceWeightHelp.
  ///
  /// In it, this message translates to:
  /// **'Quanto questo pasto incide sull\'aderenza. A zero non viene conteggiato.'**
  String get slotAdherenceWeightHelp;

  /// No description provided for @slotContent.
  ///
  /// In it, this message translates to:
  /// **'Contenuto'**
  String get slotContent;

  /// No description provided for @slotDescriptiveLabel.
  ///
  /// In it, this message translates to:
  /// **'Etichetta descrittiva'**
  String get slotDescriptiveLabel;

  /// No description provided for @slotNotSpecified.
  ///
  /// In it, this message translates to:
  /// **'Non specificato'**
  String get slotNotSpecified;

  /// No description provided for @slotRecipeName.
  ///
  /// In it, this message translates to:
  /// **'Denominazione della ricetta'**
  String get slotRecipeName;

  /// No description provided for @slotRecipeText.
  ///
  /// In it, this message translates to:
  /// **'Testo della ricetta'**
  String get slotRecipeText;

  /// No description provided for @slotToBeDefined.
  ///
  /// In it, this message translates to:
  /// **'Da definire'**
  String get slotToBeDefined;

  /// No description provided for @slotTypeBreakfast.
  ///
  /// In it, this message translates to:
  /// **'Colazione'**
  String get slotTypeBreakfast;

  /// No description provided for @slotTypeDinner.
  ///
  /// In it, this message translates to:
  /// **'Cena'**
  String get slotTypeDinner;

  /// No description provided for @slotTypeLunch.
  ///
  /// In it, this message translates to:
  /// **'Pranzo'**
  String get slotTypeLunch;

  /// No description provided for @slotTypeSnack.
  ///
  /// In it, this message translates to:
  /// **'Spuntino'**
  String get slotTypeSnack;

  /// No description provided for @statisticsAdherence.
  ///
  /// In it, this message translates to:
  /// **'Aderenza'**
  String get statisticsAdherence;

  /// No description provided for @statisticsAppearWithPlan.
  ///
  /// In it, this message translates to:
  /// **'Le statistiche del piano compaiono quando ne esiste uno.'**
  String get statisticsAppearWithPlan;

  /// No description provided for @statisticsBody.
  ///
  /// In it, this message translates to:
  /// **'Corpo'**
  String get statisticsBody;

  /// No description provided for @statisticsChangePeriod.
  ///
  /// In it, this message translates to:
  /// **'Cambia periodo'**
  String get statisticsChangePeriod;

  /// No description provided for @statisticsExclusionDaysSuspended.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 giorno di sospensione} other{{count} giorni di sospensione}}'**
  String statisticsExclusionDaysSuspended(int count);

  /// No description provided for @statisticsExclusionDaysUncovered.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 giorno senza piano} other{{count} giorni senza piano}}'**
  String statisticsExclusionDaysUncovered(int count);

  /// No description provided for @statisticsExclusionNotice.
  ///
  /// In it, this message translates to:
  /// **'Il calcolo esclude {what}.'**
  String statisticsExclusionNotice(String what);

  /// No description provided for @statisticsMonthOf.
  ///
  /// In it, this message translates to:
  /// **'Mese di {month}'**
  String statisticsMonthOf(String month);

  /// No description provided for @statisticsNoDataForPeriod.
  ///
  /// In it, this message translates to:
  /// **'Dati non disponibili per questo periodo'**
  String get statisticsNoDataForPeriod;

  /// No description provided for @statisticsNoDataYet.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono ancora dati'**
  String get statisticsNoDataYet;

  /// No description provided for @statisticsNoPlanForPeriod.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano su cui riferire il periodo'**
  String get statisticsNoPlanForPeriod;

  /// No description provided for @statisticsPercent.
  ///
  /// In it, this message translates to:
  /// **'{value}%'**
  String statisticsPercent(String value);

  /// No description provided for @statisticsPeriodOrdinal.
  ///
  /// In it, this message translates to:
  /// **'{index}° periodo'**
  String statisticsPeriodOrdinal(int index);

  /// No description provided for @statisticsPlanRange.
  ///
  /// In it, this message translates to:
  /// **'{plan} · {start} – {end}'**
  String statisticsPlanRange(String plan, String start, String end);

  /// No description provided for @statisticsUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Statistiche non disponibili'**
  String get statisticsUnavailable;

  /// No description provided for @statisticsWeekRange.
  ///
  /// In it, this message translates to:
  /// **'Settimana dal {start} al {end}'**
  String statisticsWeekRange(String start, String end);

  /// No description provided for @statisticsWholePlan.
  ///
  /// In it, this message translates to:
  /// **'Intero piano'**
  String get statisticsWholePlan;

  /// No description provided for @statisticsWorkouts.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti'**
  String get statisticsWorkouts;

  /// No description provided for @swapChooseDestination.
  ///
  /// In it, this message translates to:
  /// **'Scegli dove spostarlo'**
  String get swapChooseDestination;

  /// No description provided for @templateDeleteConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'I piani già creati da «{name}» non ne risentono.'**
  String templateDeleteConfirmBody(String name);

  /// No description provided for @templateDeleteConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il template?'**
  String get templateDeleteConfirmTitle;

  /// No description provided for @templateLastEdited.
  ///
  /// In it, this message translates to:
  /// **'Ultima modifica: {when}'**
  String templateLastEdited(String when);

  /// No description provided for @templateNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo template'**
  String get templateNew;

  /// No description provided for @templatePreviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Anteprima template'**
  String get templatePreviewTitle;

  /// No description provided for @templateRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina template'**
  String get templateRename;

  /// No description provided for @templateRenameShort.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get templateRenameShort;

  /// No description provided for @templateSaved.
  ///
  /// In it, this message translates to:
  /// **'Template salvato.'**
  String get templateSaved;

  /// No description provided for @templateScheduleTitle.
  ///
  /// In it, this message translates to:
  /// **'Redazione del template'**
  String get templateScheduleTitle;

  /// No description provided for @templateUse.
  ///
  /// In it, this message translates to:
  /// **'Usa questo template'**
  String get templateUse;

  /// No description provided for @templatesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun template. Crealo con il pulsante in basso.'**
  String get templatesEmpty;

  /// No description provided for @timezoneAfricaCairo.
  ///
  /// In it, this message translates to:
  /// **'Il Cairo'**
  String get timezoneAfricaCairo;

  /// No description provided for @timezoneAfricaJohannesburg.
  ///
  /// In it, this message translates to:
  /// **'Johannesburg'**
  String get timezoneAfricaJohannesburg;

  /// No description provided for @timezoneAmericaArgentinaBuenosAires.
  ///
  /// In it, this message translates to:
  /// **'Buenos Aires'**
  String get timezoneAmericaArgentinaBuenosAires;

  /// No description provided for @timezoneAmericaChicago.
  ///
  /// In it, this message translates to:
  /// **'Chicago'**
  String get timezoneAmericaChicago;

  /// No description provided for @timezoneAmericaDenver.
  ///
  /// In it, this message translates to:
  /// **'Denver'**
  String get timezoneAmericaDenver;

  /// No description provided for @timezoneAmericaLosAngeles.
  ///
  /// In it, this message translates to:
  /// **'Los Angeles'**
  String get timezoneAmericaLosAngeles;

  /// No description provided for @timezoneAmericaNewYork.
  ///
  /// In it, this message translates to:
  /// **'New York'**
  String get timezoneAmericaNewYork;

  /// No description provided for @timezoneAmericaSaoPaulo.
  ///
  /// In it, this message translates to:
  /// **'San Paolo'**
  String get timezoneAmericaSaoPaulo;

  /// No description provided for @timezoneAsiaBangkok.
  ///
  /// In it, this message translates to:
  /// **'Bangkok'**
  String get timezoneAsiaBangkok;

  /// No description provided for @timezoneAsiaDubai.
  ///
  /// In it, this message translates to:
  /// **'Dubai'**
  String get timezoneAsiaDubai;

  /// No description provided for @timezoneAsiaHongKong.
  ///
  /// In it, this message translates to:
  /// **'Hong Kong'**
  String get timezoneAsiaHongKong;

  /// No description provided for @timezoneAsiaKolkata.
  ///
  /// In it, this message translates to:
  /// **'Nuova Delhi'**
  String get timezoneAsiaKolkata;

  /// No description provided for @timezoneAsiaSeoul.
  ///
  /// In it, this message translates to:
  /// **'Seul'**
  String get timezoneAsiaSeoul;

  /// No description provided for @timezoneAsiaShanghai.
  ///
  /// In it, this message translates to:
  /// **'Shanghai'**
  String get timezoneAsiaShanghai;

  /// No description provided for @timezoneAsiaTokyo.
  ///
  /// In it, this message translates to:
  /// **'Tokyo'**
  String get timezoneAsiaTokyo;

  /// No description provided for @timezoneAustraliaPerth.
  ///
  /// In it, this message translates to:
  /// **'Perth'**
  String get timezoneAustraliaPerth;

  /// No description provided for @timezoneAustraliaSydney.
  ///
  /// In it, this message translates to:
  /// **'Sydney'**
  String get timezoneAustraliaSydney;

  /// No description provided for @timezoneEuropeAmsterdam.
  ///
  /// In it, this message translates to:
  /// **'Amsterdam'**
  String get timezoneEuropeAmsterdam;

  /// No description provided for @timezoneEuropeAthens.
  ///
  /// In it, this message translates to:
  /// **'Atene'**
  String get timezoneEuropeAthens;

  /// No description provided for @timezoneEuropeBerlin.
  ///
  /// In it, this message translates to:
  /// **'Berlino'**
  String get timezoneEuropeBerlin;

  /// No description provided for @timezoneEuropeDublin.
  ///
  /// In it, this message translates to:
  /// **'Dublino'**
  String get timezoneEuropeDublin;

  /// No description provided for @timezoneEuropeHelsinki.
  ///
  /// In it, this message translates to:
  /// **'Helsinki'**
  String get timezoneEuropeHelsinki;

  /// No description provided for @timezoneEuropeLisbon.
  ///
  /// In it, this message translates to:
  /// **'Lisbona'**
  String get timezoneEuropeLisbon;

  /// No description provided for @timezoneEuropeLondon.
  ///
  /// In it, this message translates to:
  /// **'Londra'**
  String get timezoneEuropeLondon;

  /// No description provided for @timezoneEuropeMadrid.
  ///
  /// In it, this message translates to:
  /// **'Madrid'**
  String get timezoneEuropeMadrid;

  /// No description provided for @timezoneEuropeMoscow.
  ///
  /// In it, this message translates to:
  /// **'Mosca'**
  String get timezoneEuropeMoscow;

  /// No description provided for @timezoneEuropeParis.
  ///
  /// In it, this message translates to:
  /// **'Parigi'**
  String get timezoneEuropeParis;

  /// No description provided for @timezoneEuropeRome.
  ///
  /// In it, this message translates to:
  /// **'Roma'**
  String get timezoneEuropeRome;

  /// No description provided for @timezoneEuropeVienna.
  ///
  /// In it, this message translates to:
  /// **'Vienna'**
  String get timezoneEuropeVienna;

  /// No description provided for @timezoneEuropeZurich.
  ///
  /// In it, this message translates to:
  /// **'Zurigo'**
  String get timezoneEuropeZurich;

  /// No description provided for @timezonePacificAuckland.
  ///
  /// In it, this message translates to:
  /// **'Auckland'**
  String get timezonePacificAuckland;

  /// No description provided for @timezoneUtc.
  ///
  /// In it, this message translates to:
  /// **'UTC'**
  String get timezoneUtc;

  /// No description provided for @unitCentimetres.
  ///
  /// In it, this message translates to:
  /// **'cm'**
  String get unitCentimetres;

  /// No description provided for @unitInches.
  ///
  /// In it, this message translates to:
  /// **'in'**
  String get unitInches;

  /// LO-5: l’energia è in chilocalorie in entrambi i sistemi.
  ///
  /// In it, this message translates to:
  /// **'kcal'**
  String get unitKilocalories;

  /// LO-4: peso nel sistema metrico.
  ///
  /// In it, this message translates to:
  /// **'kg'**
  String get unitKilograms;

  /// LO-4: peso nel sistema imperiale.
  ///
  /// In it, this message translates to:
  /// **'lb'**
  String get unitPounds;

  /// No description provided for @usernameHint.
  ///
  /// In it, this message translates to:
  /// **'Servirà al tuo nutrizionista per trovarti'**
  String get usernameHint;

  /// No description provided for @validationEmailAlreadyRegistered.
  ///
  /// In it, this message translates to:
  /// **'Questo indirizzo è già registrato'**
  String get validationEmailAlreadyRegistered;

  /// No description provided for @validationInvalidFormat.
  ///
  /// In it, this message translates to:
  /// **'Formato non valido'**
  String get validationInvalidFormat;

  /// No description provided for @validationInvalidValue.
  ///
  /// In it, this message translates to:
  /// **'Valore non valido'**
  String get validationInvalidValue;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationRequired.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get validationRequired;

  /// No description provided for @validationTooLong.
  ///
  /// In it, this message translates to:
  /// **'Troppo lungo'**
  String get validationTooLong;

  /// No description provided for @validationUsernameAlreadyTaken.
  ///
  /// In it, this message translates to:
  /// **'Questo nome utente è già in uso'**
  String get validationUsernameAlreadyTaken;

  /// No description provided for @verifyEmailBackToLogin.
  ///
  /// In it, this message translates to:
  /// **'Torna all\'accesso'**
  String get verifyEmailBackToLogin;

  /// No description provided for @verifyEmailLinkExpiredBody.
  ///
  /// In it, this message translates to:
  /// **'Torna all\'accesso per richiederne uno nuovo.'**
  String get verifyEmailLinkExpiredBody;

  /// No description provided for @verifyEmailLinkExpiredTitle.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento non è più valido'**
  String get verifyEmailLinkExpiredTitle;

  /// No description provided for @verifyEmailResend.
  ///
  /// In it, this message translates to:
  /// **'Invia di nuovo'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In it, this message translates to:
  /// **'Invia di nuovo ({seconds}s)'**
  String verifyEmailResendIn(int seconds);

  /// No description provided for @verifyEmailSentTo.
  ///
  /// In it, this message translates to:
  /// **'Abbiamo inviato un collegamento di conferma a {email}'**
  String verifyEmailSentTo(String email);

  /// No description provided for @verifyEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tua posta'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailUseAnotherAddress.
  ///
  /// In it, this message translates to:
  /// **'Usa un altro indirizzo'**
  String get verifyEmailUseAnotherAddress;

  /// No description provided for @weekNext.
  ///
  /// In it, this message translates to:
  /// **'Settimana successiva'**
  String get weekNext;

  /// No description provided for @weekNoPlan.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano'**
  String get weekNoPlan;

  /// No description provided for @weekPlanCompleted.
  ///
  /// In it, this message translates to:
  /// **'Piano concluso'**
  String get weekPlanCompleted;

  /// No description provided for @weekPlanNotStarted.
  ///
  /// In it, this message translates to:
  /// **'Piano non ancora iniziato'**
  String get weekPlanNotStarted;

  /// No description provided for @weekPrevious.
  ///
  /// In it, this message translates to:
  /// **'Settimana precedente'**
  String get weekPrevious;

  /// No description provided for @weekThisWeek.
  ///
  /// In it, this message translates to:
  /// **'Questa settimana'**
  String get weekThisWeek;

  /// No description provided for @weekdayFriday.
  ///
  /// In it, this message translates to:
  /// **'Venerdì'**
  String get weekdayFriday;

  /// No description provided for @weekdayInitialFriday.
  ///
  /// In it, this message translates to:
  /// **'V'**
  String get weekdayInitialFriday;

  /// 7.3: iniziale del selettore dei giorni.
  ///
  /// In it, this message translates to:
  /// **'L'**
  String get weekdayInitialMonday;

  /// No description provided for @weekdayInitialSaturday.
  ///
  /// In it, this message translates to:
  /// **'S'**
  String get weekdayInitialSaturday;

  /// No description provided for @weekdayInitialSunday.
  ///
  /// In it, this message translates to:
  /// **'D'**
  String get weekdayInitialSunday;

  /// No description provided for @weekdayInitialThursday.
  ///
  /// In it, this message translates to:
  /// **'G'**
  String get weekdayInitialThursday;

  /// No description provided for @weekdayInitialTuesday.
  ///
  /// In it, this message translates to:
  /// **'M'**
  String get weekdayInitialTuesday;

  /// No description provided for @weekdayInitialWednesday.
  ///
  /// In it, this message translates to:
  /// **'M'**
  String get weekdayInitialWednesday;

  /// No description provided for @weekdayMonday.
  ///
  /// In it, this message translates to:
  /// **'Lunedì'**
  String get weekdayMonday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In it, this message translates to:
  /// **'Sabato'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In it, this message translates to:
  /// **'Domenica'**
  String get weekdaySunday;

  /// No description provided for @weekdayThursday.
  ///
  /// In it, this message translates to:
  /// **'Giovedì'**
  String get weekdayThursday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In it, this message translates to:
  /// **'Martedì'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In it, this message translates to:
  /// **'Mercoledì'**
  String get weekdayWednesday;

  /// No description provided for @workoutActivityType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di attività'**
  String get workoutActivityType;

  /// No description provided for @workoutActivityTypeRequired.
  ///
  /// In it, this message translates to:
  /// **'Indica il tipo di attività'**
  String get workoutActivityTypeRequired;

  /// No description provided for @workoutAddOneOff.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi allenamento occasionale'**
  String get workoutAddOneOff;

  /// No description provided for @workoutAddRecurring.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi allenamento ricorrente'**
  String get workoutAddRecurring;

  /// No description provided for @workoutBulletType.
  ///
  /// In it, this message translates to:
  /// **'• {type}'**
  String workoutBulletType(String type);

  /// No description provided for @workoutBulletTypeWithCalories.
  ///
  /// In it, this message translates to:
  /// **'• {type} — {calories} kcal'**
  String workoutBulletTypeWithCalories(String type, int calories);

  /// No description provided for @workoutCaloriesBurned.
  ///
  /// In it, this message translates to:
  /// **'Calorie bruciate'**
  String get workoutCaloriesBurned;

  /// No description provided for @workoutCaloriesOptional.
  ///
  /// In it, this message translates to:
  /// **'Se lo sai. Non è obbligatorio.'**
  String get workoutCaloriesOptional;

  /// No description provided for @workoutCaloriesWithUnit.
  ///
  /// In it, this message translates to:
  /// **'{value} kcal'**
  String workoutCaloriesWithUnit(int value);

  /// No description provided for @workoutCease.
  ///
  /// In it, this message translates to:
  /// **'Cessa'**
  String get workoutCease;

  /// No description provided for @workoutClearFilters.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi i filtri'**
  String get workoutClearFilters;

  /// No description provided for @workoutDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questo allenamento?'**
  String get workoutDeleteConfirm;

  /// No description provided for @workoutDeleteKeepsPlanning.
  ///
  /// In it, this message translates to:
  /// **'La pianificazione resta: l\'allenamento tornerà previsto e non svolto.'**
  String get workoutDeleteKeepsPlanning;

  /// No description provided for @workoutDuplicateMany.
  ///
  /// In it, this message translates to:
  /// **'Hai già registrato {count} allenamenti in questo giorno'**
  String workoutDuplicateMany(int count);

  /// No description provided for @workoutDuplicateSingle.
  ///
  /// In it, this message translates to:
  /// **'Hai già registrato un allenamento in questo giorno'**
  String get workoutDuplicateSingle;

  /// No description provided for @workoutEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica allenamento'**
  String get workoutEditTitle;

  /// No description provided for @workoutFilters.
  ///
  /// In it, this message translates to:
  /// **'Filtri'**
  String get workoutFilters;

  /// No description provided for @workoutMarkAsDone.
  ///
  /// In it, this message translates to:
  /// **'Segna come svolto'**
  String get workoutMarkAsDone;

  /// No description provided for @workoutNoTypesYet.
  ///
  /// In it, this message translates to:
  /// **'Nessun tipo ancora registrato.'**
  String get workoutNoTypesYet;

  /// No description provided for @workoutNoWeeklyGoal.
  ///
  /// In it, this message translates to:
  /// **'Nessun obiettivo settimanale'**
  String get workoutNoWeeklyGoal;

  /// No description provided for @workoutNonePlanned.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento pianificato'**
  String get workoutNonePlanned;

  /// No description provided for @workoutNonePlannedDot.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento pianificato.'**
  String get workoutNonePlannedDot;

  /// No description provided for @workoutNoneRecorded.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento registrato'**
  String get workoutNoneRecorded;

  /// No description provided for @workoutNoneWithFilters.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento con questi filtri'**
  String get workoutNoneWithFilters;

  /// No description provided for @workoutOneOff.
  ///
  /// In it, this message translates to:
  /// **'Allenamento occasionale'**
  String get workoutOneOff;

  /// No description provided for @workoutPerWeek.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti a settimana'**
  String get workoutPerWeek;

  /// No description provided for @workoutPerWeekSuffix.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 allenamento a settimana} other{{count} allenamenti a settimana}}'**
  String workoutPerWeekSuffix(int count);

  /// No description provided for @workoutPeriod.
  ///
  /// In it, this message translates to:
  /// **'Periodo'**
  String get workoutPeriod;

  /// No description provided for @workoutPickAtLeastOneDay.
  ///
  /// In it, this message translates to:
  /// **'Scegli almeno un giorno'**
  String get workoutPickAtLeastOneDay;

  /// No description provided for @workoutPickPeriod.
  ///
  /// In it, this message translates to:
  /// **'Scegli un periodo'**
  String get workoutPickPeriod;

  /// No description provided for @workoutPlanning.
  ///
  /// In it, this message translates to:
  /// **'Pianificazione'**
  String get workoutPlanning;

  /// No description provided for @workoutPlanningNotice.
  ///
  /// In it, this message translates to:
  /// **'Le modifiche valgono da oggi in avanti: i giorni trascorsi restano come erano.'**
  String get workoutPlanningNotice;

  /// No description provided for @workoutRecord.
  ///
  /// In it, this message translates to:
  /// **'Registra allenamento'**
  String get workoutRecord;

  /// No description provided for @workoutRecordAnyway.
  ///
  /// In it, this message translates to:
  /// **'Registra comunque'**
  String get workoutRecordAnyway;

  /// No description provided for @workoutRecordTitle.
  ///
  /// In it, this message translates to:
  /// **'Registra un allenamento'**
  String get workoutRecordTitle;

  /// No description provided for @workoutRecurring.
  ///
  /// In it, this message translates to:
  /// **'Allenamento ricorrente'**
  String get workoutRecurring;

  /// No description provided for @workoutRemoveGoal.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi obiettivo'**
  String get workoutRemoveGoal;

  /// No description provided for @workoutSetGoal.
  ///
  /// In it, this message translates to:
  /// **'Imposta'**
  String get workoutSetGoal;

  /// No description provided for @workoutSheetFooter.
  ///
  /// In it, this message translates to:
  /// **'Se vuoi, aggiungi calorie e nota. Puoi anche chiudere: l\'allenamento è registrato lo stesso.'**
  String get workoutSheetFooter;

  /// No description provided for @workoutStatsDistribution.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione per tipo'**
  String get workoutStatsDistribution;

  /// No description provided for @workoutStatsGoalComparison.
  ///
  /// In it, this message translates to:
  /// **'Confronto con l’obiettivo'**
  String get workoutStatsGoalComparison;

  /// No description provided for @workoutStatsGoalProgress.
  ///
  /// In it, this message translates to:
  /// **'{done} su {goal} previsti'**
  String workoutStatsGoalProgress(int done, int goal);

  /// No description provided for @workoutStatsGoalProgressWeekly.
  ///
  /// In it, this message translates to:
  /// **'{done} su {goal} previsti dall’obiettivo settimanale'**
  String workoutStatsGoalProgressWeekly(int done, int goal);

  /// No description provided for @workoutStatsGoalWeeks.
  ///
  /// In it, this message translates to:
  /// **'Su {weeks} settimane intere, ciascuna con l’obiettivo allora vigente.'**
  String workoutStatsGoalWeeks(int weeks);

  /// No description provided for @workoutStatsGoalWeeksNotice.
  ///
  /// In it, this message translates to:
  /// **'Su {weeks} settimane intere, ciascuna con l’obiettivo allora vigente.'**
  String workoutStatsGoalWeeksNotice(int weeks);

  /// No description provided for @workoutStatsNonePlannedInPeriod.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento pianificato nel periodo.'**
  String get workoutStatsNonePlannedInPeriod;

  /// No description provided for @workoutStatsNoneRecordedInPeriod.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento registrato nel periodo.'**
  String get workoutStatsNoneRecordedInPeriod;

  /// No description provided for @workoutStatsPlanComparison.
  ///
  /// In it, this message translates to:
  /// **'Confronto con la pianificazione'**
  String get workoutStatsPlanComparison;

  /// No description provided for @workoutStatsPlanProgress.
  ///
  /// In it, this message translates to:
  /// **'{planned} pianificati, {done} svolti'**
  String workoutStatsPlanProgress(int planned, int done);

  /// No description provided for @workoutStatsSuspendedNotice.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Comprende 1 giorno di sospensione, che l’aderenza esclude.} other{Comprende {count} giorni di sospensione, che l’aderenza esclude.}}'**
  String workoutStatsSuspendedNotice(int count);

  /// No description provided for @workoutStatsTotalDone.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 allenamento svolto} other{{count} allenamenti svolti}}'**
  String workoutStatsTotalDone(int count);

  /// No description provided for @workoutStatsWeeklyTrend.
  ///
  /// In it, this message translates to:
  /// **'Andamento settimanale'**
  String get workoutStatsWeeklyTrend;

  /// No description provided for @workoutWeeklyGoal.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo settimanale'**
  String get workoutWeeklyGoal;

  /// No description provided for @workoutWeeklyGoalHelp.
  ///
  /// In it, this message translates to:
  /// **'Quante volte ti proponi di allenarti in una settimana. È indipendente dai giorni che hai pianificato.'**
  String get workoutWeeklyGoalHelp;

  /// No description provided for @workoutWhenDone.
  ///
  /// In it, this message translates to:
  /// **'Quando lo hai svolto'**
  String get workoutWhenDone;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'it':
      return L10nIt();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
