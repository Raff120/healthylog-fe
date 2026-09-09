// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get errorAccountNotVerified => 'Confirm your email address first.';

  @override
  String get errorAlreadyInGroup =>
      'You already belong to a group: leave it before creating a new one.';

  @override
  String get errorAlreadyLinked =>
      'This person is already linked to a nutritionist: that link must be revoked first.';

  @override
  String get errorAuthenticationRequired => 'You need to sign in to continue.';

  @override
  String get errorCareLinkNotActive => 'The link has already been revoked.';

  @override
  String get errorCareLinkRequestAlreadyPending =>
      'You already have a pending request to this person.';

  @override
  String get errorCareLinkRequestNotPending =>
      'This request is no longer pending.';

  @override
  String get errorEmailAlreadyUsed =>
      'This email address is already registered.';

  @override
  String get errorEmailAlreadyVerified =>
      'This address has already been verified.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorInviteCodeInvalid => 'The code you entered is not valid.';

  @override
  String get errorNetwork => 'No connection. Try again.';

  @override
  String get errorNutritionistCannotJoinGroup =>
      'A Nutritionist cannot belong to a group.';

  @override
  String get errorOwnerCookPrivilegeInseparable =>
      'The Owner cannot give up the Cook privilege: transfer ownership first.';

  @override
  String get errorPasswordResetTokenInvalid =>
      'The link is no longer valid. Request a new one.';

  @override
  String get errorPasswordTooLong => 'The password is too long.';

  @override
  String get errorPastDayNotEditable => 'Past days cannot be edited.';

  @override
  String get errorPatientPlanLocked =>
      'Your nutritionist manages this plan: you can tick and swap, but not change its content.';

  @override
  String get errorPlanActiveCannotDelete =>
      'An Active plan cannot be deleted: suspend or complete it first.';

  @override
  String get errorPlanIncomplete => 'The weekly schedule is not complete yet.';

  @override
  String get errorPlanNotActive => 'This day is not covered by an active plan.';

  @override
  String get errorPlanPeriodOverlap => 'The period overlaps an existing plan.';

  @override
  String get errorPlanScheduleNotEditable =>
      'This plan’s schedule can no longer be edited.';

  @override
  String get errorPlanTransitionNotAllowed =>
      'This operation is no longer possible for the plan.';

  @override
  String get errorRefreshTokenInvalid =>
      'Your session is no longer valid. Sign in again.';

  @override
  String get errorSlotAlreadyConsumed => 'This meal has already been consumed.';

  @override
  String get errorSwapDifferentDays => 'They must belong to the same day.';

  @override
  String get errorSwapDifferentWeeks => 'They belong to different weeks.';

  @override
  String get errorSwapPastDay => 'This day has already passed.';

  @override
  String get errorSwapTypeNotAllowed =>
      'These meals cannot be swapped with each other.';

  @override
  String get errorTimezoneInvalid => 'Time zone not recognised.';

  @override
  String get errorUsernameAlreadyUsed => 'This username is already taken.';

  @override
  String get errorValidationFailed => 'Check the details you entered.';

  @override
  String get errorVerificationResendRateLimited =>
      'Too many resend requests. Try again in a few minutes.';

  @override
  String get errorVerificationTokenInvalid =>
      'The link is no longer valid. Request a new one.';

  @override
  String get errorWorkoutFutureDate =>
      'A workout is recorded once done: for the future there is planning.';

  @override
  String get settingsDevices => 'Connected devices';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionDateTime => 'Date and time';

  @override
  String get settingsSectionLanguageAndFormats => 'Language and formats';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsTimezone => 'Time zone';

  @override
  String get settingsTimezoneSearch => 'Search time zone';

  @override
  String get settingsTitle => 'Settings';
}
