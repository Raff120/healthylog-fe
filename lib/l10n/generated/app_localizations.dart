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

  /// No description provided for @commonDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get commonDelete;

  /// No description provided for @commonNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get commonNotSet;

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
