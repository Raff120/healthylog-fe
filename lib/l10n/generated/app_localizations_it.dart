// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class L10nIt extends L10n {
  L10nIt([String locale = 'it']) : super(locale);

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonNotSet => 'Non impostato';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonSearch => 'Cerca';

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
  String get settingsDevices => 'Dispositivi collegati';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsSectionDateTime => 'Data e ora';

  @override
  String get settingsSectionLanguageAndFormats => 'Lingua e formati';

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
}
