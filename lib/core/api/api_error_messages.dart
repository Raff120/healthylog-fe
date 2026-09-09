import 'package:flutter/widgets.dart';

import '../../l10n/l10n_context.dart';

/// Traduzione dei codici d'errore (ER-2, FR-22): il testo presentato
/// all'Utente è generato qui a partire dal codice, mai dal corpo della
/// risposta, e nella lingua selezionata (LO-1).
///
/// Un codice non riconosciuto — introdotto da una versione più recente
/// del server — riceve il messaggio generico, non il codice grezzo.
String describeApiError(BuildContext context, String code) {
  final l10n = context.l10n;
  return switch (code) {
    'VALIDATION_FAILED' => l10n.errorValidationFailed,
    'INVALID_CREDENTIALS' => l10n.errorInvalidCredentials,
    'ACCOUNT_NOT_VERIFIED' => l10n.errorAccountNotVerified,
    'EMAIL_ALREADY_USED' => l10n.errorEmailAlreadyUsed,
    'USERNAME_ALREADY_USED' => l10n.errorUsernameAlreadyUsed,
    'EMAIL_ALREADY_VERIFIED' => l10n.errorEmailAlreadyVerified,
    'VERIFICATION_TOKEN_INVALID' => l10n.errorVerificationTokenInvalid,
    'VERIFICATION_RESEND_RATE_LIMITED' => l10n.errorVerificationResendRateLimited,
    'PASSWORD_RESET_TOKEN_INVALID' => l10n.errorPasswordResetTokenInvalid,
    'PASSWORD_TOO_LONG' => l10n.errorPasswordTooLong,
    'REFRESH_TOKEN_INVALID' => l10n.errorRefreshTokenInvalid,
    'AUTHENTICATION_REQUIRED' => l10n.errorAuthenticationRequired,
    'NETWORK_ERROR' => l10n.errorNetwork,
    'PLAN_INCOMPLETE' => l10n.errorPlanIncomplete,
    'PLAN_SCHEDULE_NOT_EDITABLE' => l10n.errorPlanScheduleNotEditable,
    'PLAN_TRANSITION_NOT_ALLOWED' => l10n.errorPlanTransitionNotAllowed,
    'PLAN_ACTIVE_CANNOT_DELETE' => l10n.errorPlanActiveCannotDelete,
    'PLAN_PERIOD_OVERLAP' => l10n.errorPlanPeriodOverlap,
    'PLAN_NOT_ACTIVE' => l10n.errorPlanNotActive,
    'TIMEZONE_INVALID' => l10n.errorTimezoneInvalid,
    // 6.4 funzionale, IN-21: ragioni di rifiuto dell'inversione, desunte
    // dalle regole — usate sia per il rifiuto del server sia, sul client,
    // per la barra a chi insiste su uno slot non compatibile (6.5
    // interfaccia.md).
    'SWAP_PAST_DAY' => l10n.errorSwapPastDay,
    'SLOT_ALREADY_CONSUMED' => l10n.errorSlotAlreadyConsumed,
    'SWAP_TYPE_NOT_ALLOWED' => l10n.errorSwapTypeNotAllowed,
    'SWAP_DIFFERENT_WEEKS' => l10n.errorSwapDifferentWeeks,
    'SWAP_DIFFERENT_DAYS' => l10n.errorSwapDifferentDays,
    // 7 funzionale, F23: allenamenti.
    'WORKOUT_FUTURE_DATE' => l10n.errorWorkoutFutureDate,
    // 4.4 funzionale, F19: gruppo, inviti e membri.
    'ALREADY_IN_GROUP' => l10n.errorAlreadyInGroup,
    'NUTRITIONIST_CANNOT_JOIN_GROUP' => l10n.errorNutritionistCannotJoinGroup,
    'INVITE_CODE_INVALID' => l10n.errorInviteCodeInvalid,
    'OWNER_COOK_PRIVILEGE_INSEPARABLE' => l10n.errorOwnerCookPrivilegeInseparable,
    // 4.3 e 5.3 funzionale, F21/F22: collegamento professionale e Paziente.
    'ALREADY_LINKED' => l10n.errorAlreadyLinked,
    'CARE_LINK_REQUEST_NOT_PENDING' => l10n.errorCareLinkRequestNotPending,
    'CARE_LINK_REQUEST_ALREADY_PENDING' => l10n.errorCareLinkRequestAlreadyPending,
    'CARE_LINK_NOT_ACTIVE' => l10n.errorCareLinkNotActive,
    'PATIENT_PLAN_LOCKED' => l10n.errorPatientPlanLocked,
    'PAST_DAY_NOT_EDITABLE' => l10n.errorPastDayNotEditable,
    _ => l10n.errorGeneric,
  };
}
