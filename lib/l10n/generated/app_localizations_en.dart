// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get activityMeasurements => 'Measurements';

  @override
  String get activityWorkouts => 'Workouts';

  @override
  String get adherenceBySlotType => 'By meal type';

  @override
  String get adherenceByWeekday => 'By day of the week';

  @override
  String get adherenceOverall => 'Overall';

  @override
  String adherencePeriodRange(String start, String end) {
    return 'Period from $start to $end';
  }

  @override
  String get adherenceWeeklyTrend => 'Weekly trend';

  @override
  String get bodyMeasurementsTitle => 'Measurements';

  @override
  String get bodyStatsNoMeasurements => 'No measurements in the period';

  @override
  String get bodyStatsNutritionistLegend =>
      'Hollow circles are the measurements recorded by the nutritionist.';

  @override
  String get bodyStatsSingleValue => 'A single value: no change to show';

  @override
  String get careLinkActiveHeader => 'ACTIVE LINK';

  @override
  String get careLinkRevoked =>
      'Link revoked. You have full control of your plan again.';

  @override
  String careLinkedNow(String name) {
    return 'You are now linked to $name.';
  }

  @override
  String careLinkedSince(String date) {
    return 'Since $date';
  }

  @override
  String get careManagePlanYourself => 'You can manage the plan yourself';

  @override
  String get careNoNutritionist => 'No nutritionist linked';

  @override
  String get careNutritionistNotice =>
      'Your nutritionist writes your plan and follows its progress. You can always swap and tick meals, but not change their content.';

  @override
  String get careRequestAccepting => 'If you accept, the nutritionist:';

  @override
  String get careRequestExpired => 'Expired';

  @override
  String get careRequestKeepAfterRevoke =>
      'You can revoke the link at any time. After revocation they keep only the schedules of the plans they wrote and the measurements they recorded personally.';

  @override
  String careRequestReceivedOn(String date) {
    return 'Received on $date';
  }

  @override
  String get careRequestTitle => 'Link request';

  @override
  String get careRequestWillRead =>
      'will read your data for the periods covered by their plans';

  @override
  String get careRequestWillRecordMeasurements =>
      'will be able to record measurements on your behalf';

  @override
  String get careRequestWillWritePlan => 'will write your diet plan';

  @override
  String get careRequestYouCannotEdit =>
      'and you will no longer be able to change the content of the plan they assign you';

  @override
  String get careRequestsReceivedHeader => 'REQUESTS RECEIVED';

  @override
  String get careRevokeKeepsList =>
      '• the schedules of the plans they wrote, with their validity period;\n• the measurements they recorded personally;\n• the essential personal details.';

  @override
  String get careRevokeLink => 'Revoke the link';

  @override
  String get careRevokeLosesList =>
      '• ticks, swaps and adherence statistics;\n• workouts and measurements recorded by the person.';

  @override
  String get careRevokeNutritionistBody =>
      'The nutritionist immediately loses all access to your data and all authority over your plan, which stays yours.';

  @override
  String get careRevokeNutritionistKeeps => 'The nutritionist keeps:';

  @override
  String get careRevokeNutritionistLoses => 'They do not keep:';

  @override
  String get careRevokeNutritionistSideBody =>
      'You immediately lose all access to the person’s data and all authority over their plans.';

  @override
  String get careRevokeTitle => 'Revoke the link?';

  @override
  String get careRevokeYouKeep => 'You keep:';

  @override
  String get careRevokeYouLose => 'You do not keep:';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordCurrentWrong =>
      'The current password is not correct';

  @override
  String get changePasswordDone => 'Password updated.';

  @override
  String get changePasswordNew => 'New password';

  @override
  String get changePasswordSameAsCurrent =>
      'The new password is the same as the current one';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonAll => 'All';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDecline => 'Decline';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonGenerate => 'Generate';

  @override
  String get commonListAnd => ' and ';

  @override
  String get commonName => 'Name';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonNote => 'Note';

  @override
  String get commonRecord => 'Log';

  @override
  String get commonRegenerate => 'Regenerate';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonRevoke => 'Revoke';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonShare => 'Share';

  @override
  String get commonToday => 'Today';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get dayPreviewNoSlots => 'No slots';

  @override
  String get deleteAccountConfirm => 'Request deletion';

  @override
  String get deleteAccountConfirmTitle => 'Delete the account?';

  @override
  String get deleteAccountGracePeriod =>
      'The request opens a seven-day reconsideration period: during it the account is deactivated and no third party accesses it, but the data remain. Signing in again withdraws the request.';

  @override
  String get deleteAccountGroupDissolution =>
      'You are the only member of your group: the group will be disbanded.';

  @override
  String get deleteAccountGroupSuccession =>
      'You are the Owner of a group: ownership passes automatically to another member.';

  @override
  String get deleteAccountIntro =>
      'Deleting removes the following permanently:';

  @override
  String get deleteAccountLossActivity => '•  your workouts and measurements';

  @override
  String get deleteAccountLossMemberships =>
      '•  your templates, notifications and memberships';

  @override
  String get deleteAccountLossPlans => '•  your diet plans, days and ticks';

  @override
  String get deleteAccountLossStatistics =>
      '•  the swap history and the statistics';

  @override
  String get deleteAccountNutritionistKeeps =>
      'Your nutritionist keeps the schedules of the plans they wrote and the measurements they recorded personally, stripped of your identifying data.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String deletionPendingBody(String date) {
    return 'Your account will be permanently deleted on $date. Until then you can withdraw the request.';
  }

  @override
  String get deletionPendingCancel => 'Withdraw deletion';

  @override
  String get deletionPendingTitle => 'Deletion requested';

  @override
  String get devicesCurrent => '(this device)';

  @override
  String devicesLastUsed(String when) {
    return 'Last used: $when';
  }

  @override
  String get devicesRevoke => 'Revoke';

  @override
  String get devicesRevokeAllOthers => 'Sign out all other devices';

  @override
  String get devicesRevokeAllOthersBody =>
      'The other active sessions will be closed.';

  @override
  String devicesRevokeConfirm(String device) {
    return 'Sign out “$device”?';
  }

  @override
  String get devicesSignOut => 'Sign out';

  @override
  String get devicesTitle => 'Connected devices';

  @override
  String get editAddSnack => 'Add snack';

  @override
  String get editDayConsumedNotEditable => 'Already consumed: cannot be edited';

  @override
  String get editDayEditScheduleInstead =>
      'Edit the schedule instead, for every day';

  @override
  String get editDayNotEditable => 'This day cannot be edited';

  @override
  String get editDayNotEditableReason =>
      'Only days covered by an active plan can be edited';

  @override
  String get editDayOnlyThisDayNotice =>
      'Changes apply to this day only: the weekly schedule stays unchanged.';

  @override
  String get editDaySave => 'Save day';

  @override
  String get editDaySaved => 'Day saved.';

  @override
  String editDayTitle(String date) {
    return 'Day of $date';
  }

  @override
  String get editDiscardBody => 'If you leave, your unsaved changes are lost.';

  @override
  String get editDiscardConfirm => 'Leave without saving';

  @override
  String get editDiscardTitle => 'Unsaved changes';

  @override
  String get editRecipeFieldsInvalid => 'Check the highlighted recipe fields.';

  @override
  String get editRecipeNameRequired =>
      'A name is required when the recipe text is present';

  @override
  String get editRemoveSlotBody => 'The content you entered will be lost.';

  @override
  String get editRemoveSlotTitle => 'Remove the slot?';

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
      'The code is not valid or has expired. Request a new one.';

  @override
  String get errorWorkoutFutureDate =>
      'A workout is recorded once done: for the future there is planning.';

  @override
  String get fieldBirthDate => 'Date of birth';

  @override
  String get fieldBirthPlace => 'Place of birth';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get fieldEmail => 'Email address';

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldHeight => 'Height';

  @override
  String get fieldHeightCm => 'Height (cm)';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldUsername => 'Username';

  @override
  String get groupCreate => 'Create a group';

  @override
  String get groupDissolve => 'Disband the group';

  @override
  String get groupDissolveBody =>
      'Every member leaves the group. Each keeps their own plan and history: no personal data is involved.';

  @override
  String get groupDissolveTitle => 'Disband the group?';

  @override
  String get groupJoinConfirm => 'Confirm joining';

  @override
  String get groupJoinNoticeStart =>
      'Your meals become visible to the other members, and Cooks can swap and tick meals on your plan.';

  @override
  String get groupJoinWithCode => 'Join with a code';

  @override
  String get groupLeave => 'Leave the group';

  @override
  String get groupLeaveKeepsData => 'You keep your plan and your history.';

  @override
  String get groupLeaveTitle => 'Leave the group?';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get groupNone => 'You are not in a group';

  @override
  String get groupNoneDescription =>
      'A group organises the meals of several people who cook together';

  @override
  String get groupOnlyMember => 'You are the only member';

  @override
  String get groupPromoteCook => 'Make Cook';

  @override
  String get groupRemoveMember => 'Remove from group';

  @override
  String groupRemoveMemberBody(String name) {
    return '$name keeps their own plan and history.';
  }

  @override
  String get groupRemoveMemberTitle => 'Remove from the group?';

  @override
  String get groupRename => 'Rename group';

  @override
  String get groupRevokeCook => 'Revoke Cook privilege';

  @override
  String get groupRoleCook => 'Cook';

  @override
  String get groupRoleOwner => 'Owner';

  @override
  String get groupTransferFirstBody =>
      'To leave the group you must first transfer ownership to another member, from the menu next to their name.';

  @override
  String get groupTransferFirstTitle => 'Transfer ownership first';

  @override
  String get groupTransferOwnership => 'Transfer ownership';

  @override
  String groupTransferOwnershipBody(String name) {
    return '$name becomes the group Owner. The transfer cannot be undone: only the new Owner can hand it back.';
  }

  @override
  String get groupTransferOwnershipTitle => 'Transfer ownership?';

  @override
  String get inviteCodeCopied => 'Code copied';

  @override
  String get inviteCodeField => 'Invite code';

  @override
  String inviteExpiresInDays(int days) {
    return 'In $days days';
  }

  @override
  String inviteExpiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get inviteExpiry => 'Expiry';

  @override
  String get inviteGenerate => 'Generate code';

  @override
  String get inviteMaxUses => 'Maximum number of uses (optional)';

  @override
  String get inviteNoActiveCode => 'No active code';

  @override
  String get inviteNoExpiry => 'No expiry';

  @override
  String inviteRemainingUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uses left',
      one: '1 use left',
    );
    return '$_temp0';
  }

  @override
  String inviteShareMessage(String group, String code) {
    return 'Join my group “$group” on HealthyLog with the code $code';
  }

  @override
  String get inviteePatientCheckUsername => 'Check the username and try again';

  @override
  String get inviteePatientMessage => 'Introduction message';

  @override
  String get inviteePatientMessageHint => 'Helps the person recognise you';

  @override
  String get inviteePatientNotFound => 'No user with this name';

  @override
  String get inviteePatientSend => 'Send request';

  @override
  String get inviteePatientTitle => 'Invite a patient';

  @override
  String get inviteePatientUsernameHint => 'Enter the person’s exact username';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginToRegister => 'No account yet? Sign up';

  @override
  String get mealChange => 'Change';

  @override
  String get mealChangeStatusTitle => 'Change the status?';

  @override
  String get mealFutureDayBody => 'This day has not arrived yet.';

  @override
  String get mealFutureDayTitle => 'Record a future meal?';

  @override
  String get mealMove => 'Move';

  @override
  String get mealOfflineUnavailable => 'Not available offline.';

  @override
  String get mealReplacementNote => 'Replacement note';

  @override
  String get mealReplacementNoteLost =>
      'The replacement note will be permanently lost.';

  @override
  String get mealSeeRecipe => 'View recipe';

  @override
  String mealStatusByCook(String verb, String name) {
    return '$verb by $name';
  }

  @override
  String get mealStatusVerbConsumed => 'Consumed';

  @override
  String get mealStatusVerbRestored => 'Restored';

  @override
  String get mealStatusVerbSkipped => 'Skipped';

  @override
  String mealSwappedNotification(String when) {
    return 'Two meals of your plan were swapped$when.';
  }

  @override
  String get mealTick => 'Tick';

  @override
  String get measureArm => 'Arm';

  @override
  String get measureChest => 'Chest';

  @override
  String get measureHips => 'Hips';

  @override
  String measureNamedValueWithUnit(String measure, String value, String unit) {
    return '$measure: $value $unit';
  }

  @override
  String get measureThigh => 'Thigh';

  @override
  String measureValueWithUnit(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get measureWaist => 'Waist';

  @override
  String get measureWeight => 'Weight';

  @override
  String measureWithUnit(String measure, String unit) {
    return '$measure ($unit)';
  }

  @override
  String get measurementAtLeastOneValue => 'Enter at least one value';

  @override
  String get measurementByNutritionist => 'Recorded by your nutritionist.';

  @override
  String get measurementDeleteConfirm => 'Delete this measurement?';

  @override
  String get measurementEditTitle => 'Edit measurement';

  @override
  String get measurementForPatientNotice =>
      'You record it: the person can view it but not change it.';

  @override
  String get measurementNoneRecorded => 'No measurements logged';

  @override
  String get measurementRecord => 'Log measurement';

  @override
  String get measurementRecordTitle => 'Log a measurement';

  @override
  String get memberSelectorSideBySide => 'Side-by-side view';

  @override
  String get memberSelectorSingle => 'Single view';

  @override
  String memberViewingPlanOf(String name) {
    return 'You are viewing $name’s plan';
  }

  @override
  String get navActivity => 'Activity';

  @override
  String navNotAvailableYet(String destination) {
    return '$destination: not available yet.';
  }

  @override
  String get navPatients => 'Patients';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProfile => 'Profile';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navTemplates => 'Templates';

  @override
  String get notificationCareLinkRevoked =>
      'The professional link was revoked.';

  @override
  String get notificationCareRequestAccepted =>
      'Your link request was accepted.';

  @override
  String get notificationCareRequestReceived =>
      'You received a professional link request.';

  @override
  String get notificationCareRequestRejected =>
      'Your link request was declined.';

  @override
  String notificationGroupCookGranted(String group) {
    return 'You were made Cook of the group$group.';
  }

  @override
  String notificationGroupCookRevoked(String group) {
    return 'You are no longer Cook of the group$group.';
  }

  @override
  String notificationGroupDisbanded(String group) {
    return 'The group$group was disbanded.';
  }

  @override
  String notificationGroupMemberRemoved(String group) {
    return 'You were removed from the group$group.';
  }

  @override
  String notificationGroupOwnershipTransferred(String group) {
    return 'You became Owner of the group$group.';
  }

  @override
  String notificationInForceFrom(String date) {
    return ', in force from $date';
  }

  @override
  String notificationMeasurementRecorded(String date) {
    return 'A measurement was recorded for $date.';
  }

  @override
  String notificationOnDay(String date) {
    return ' on $date';
  }

  @override
  String notificationPlanActivatedAutomatically(String plan) {
    return 'The plan$plan has come into force.';
  }

  @override
  String notificationPlanAssigned(String plan, String from) {
    return 'You have been assigned the plan$plan$from.';
  }

  @override
  String notificationPlanCompleted(String plan) {
    return 'The plan$plan was completed.';
  }

  @override
  String notificationPlanCompletedAutomatically(String plan) {
    return 'The plan$plan ended on its planned date.';
  }

  @override
  String notificationPlanDayModified(String date, String plan) {
    return 'The $date day of the plan$plan was changed.';
  }

  @override
  String notificationPlanModified(String plan) {
    return 'The plan$plan was changed.';
  }

  @override
  String notificationPlanNameQuoted(String name) {
    return ' “$name”';
  }

  @override
  String notificationPlanResumed(String plan) {
    return 'The plan$plan was resumed.';
  }

  @override
  String notificationPlanSuspended(String plan) {
    return 'The plan$plan was suspended.';
  }

  @override
  String notificationPlanWithdrawn(String plan) {
    return 'The plan$plan was withdrawn and is back in review.';
  }

  @override
  String notificationSlotMarked(String slot, String date, String status) {
    return '$slot on $date the status $status was recorded.';
  }

  @override
  String get notificationSlotOnBreakfast => 'On the breakfast';

  @override
  String get notificationSlotOnDinner => 'On the dinner';

  @override
  String get notificationSlotOnGeneric => 'On a meal';

  @override
  String get notificationSlotOnLunch => 'On the lunch';

  @override
  String get notificationSlotOnSnack => 'On the snack';

  @override
  String get notificationStatusConsumed => '“Consumed”';

  @override
  String get notificationStatusSkipped => '“Skipped”';

  @override
  String get notificationStatusToConsume => '“To consume”';

  @override
  String get notificationUnknown =>
      'Something happened that concerns your account.';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineBar =>
      'You are offline. You can view the plan already downloaded.';

  @override
  String get passwordRequirementHint => 'At least 8 characters';

  @override
  String get passwordResetConfirmTitle => 'Set a new password';

  @override
  String get passwordResetDone =>
      'All sessions have been closed. Sign in with your new password.';

  @override
  String get passwordResetLinkExpiredBody =>
      'Request a new one from the sign-in screen.';

  @override
  String get passwordResetLinkExpiredTitle => 'The link is no longer valid';

  @override
  String get passwordResetNewPassword => 'New password';

  @override
  String get passwordResetRequestNewLink => 'Request a new link';

  @override
  String get passwordResetRequestSent =>
      'If an account exists for this address, you will receive a link shortly.';

  @override
  String get passwordResetRequestSubmit => 'Send link';

  @override
  String get passwordResetRequestSubtitle =>
      'We will send you a link to set a new password';

  @override
  String get passwordResetRequestTitle => 'Recover access';

  @override
  String get passwordResetSubmit => 'Reset password';

  @override
  String patientAdherenceWithPeriod(String period) {
    return 'Adherence · $period';
  }

  @override
  String get patientCreatePlan => 'Create a new plan';

  @override
  String get patientCurrentPlanHeader => 'CURRENT PLAN';

  @override
  String get patientEditDay => 'Edit a day';

  @override
  String patientLinkedSince(String date) {
    return 'Linked since $date';
  }

  @override
  String patientMeasureChange(String measure, String change, String unit) {
    return '$measure: $change $unit';
  }

  @override
  String patientMeasureSingleValue(String measure) {
    return '$measure: a single value in the period';
  }

  @override
  String get patientMeasurementsHeader => 'MEASUREMENTS';

  @override
  String get patientMonthStatisticsHeader => 'THIS MONTH';

  @override
  String get patientNoCurrentPlan => 'No current plan written by you.';

  @override
  String get patientNoMeasurements => 'No measurements';

  @override
  String get patientNoWorkouts => 'No workouts';

  @override
  String get patientOtherPlansHeader => 'OTHER PLANS WRITTEN';

  @override
  String get patientPickDay => 'Day to edit';

  @override
  String patientPlanWithStatus(String plan, String status) {
    return '$plan · $status';
  }

  @override
  String get patientSortAdherence => 'Adherence';

  @override
  String get patientSortName => 'Alphabetical';

  @override
  String get patientSortRecentActivity => 'Recent activity';

  @override
  String get patientWithdrawBody => 'The patient will no longer see it.';

  @override
  String get patientWorkoutsHeader => 'WORKOUTS';

  @override
  String get patientsEmpty => 'No patients linked';

  @override
  String get patientsInvite => 'Invite patient';

  @override
  String get patientsInviteHint => 'Invite a patient by their username';

  @override
  String get patientsPendingRequests => 'PENDING REQUESTS';

  @override
  String get patientsRequestSent => 'Request sent.';

  @override
  String patientsRequestSentOn(String date) {
    return 'Sent on $date · Pending';
  }

  @override
  String get patientsSelect => 'Select a patient';

  @override
  String get patientsSortBy => 'Sort';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodPlan => 'Plan';

  @override
  String get periodWeek => 'Week';

  @override
  String get personalDataChangePassword => 'Change password';

  @override
  String get personalDataRoleNotChangeable => 'Your role cannot be changed';

  @override
  String get personalDataSaved => 'Details updated.';

  @override
  String get personalDataTargetWeight => 'Target weight';

  @override
  String get personalDataTargetWeightKg => 'Target weight (kg)';

  @override
  String get personalDataTitle => 'Personal details';

  @override
  String get planActionComplete => 'Complete';

  @override
  String get planActionDelete => 'Delete';

  @override
  String get planActionEdit => 'Edit';

  @override
  String get planActionExport => 'Export';

  @override
  String get planActionReactivate => 'Reactivate';

  @override
  String get planActionResume => 'Resume';

  @override
  String get planActionSuspend => 'Suspend';

  @override
  String get planActionWithdraw => 'Withdraw';

  @override
  String planCompletedOn(String date) {
    return 'Plan completed on $date';
  }

  @override
  String get planCreateFirst => 'Create your first diet plan';

  @override
  String get planCreateFromScratch => 'From scratch';

  @override
  String get planCreateFromScratchDescription =>
      'Build the weekly schedule from an empty structure';

  @override
  String get planCreateFromTemplate => 'From a template';

  @override
  String get planCreateFromTemplateDescription =>
      'Start from a ready-made schedule and adjust it';

  @override
  String get planCreateSubmit => 'Create plan';

  @override
  String get planCreateTitle => 'New plan';

  @override
  String get planDayView => 'Day';

  @override
  String get planDeleteIrreversible => 'This action cannot be undone.';

  @override
  String get planDeleteLossAllPeriods =>
      'The following are permanently lost, for every period of the plan:';

  @override
  String get planDeleteLossDays => '•  the days and the consumption ticks';

  @override
  String get planDeleteLossStatistics => '•  the adherence statistics';

  @override
  String get planDeleteLossSwaps => '•  the swap history';

  @override
  String get planDeleteLossThisPeriod =>
      'The following are permanently lost, for this period:';

  @override
  String get planDeleteTitle => 'Delete the plan?';

  @override
  String get planDeleteWorkoutsKept =>
      'Workouts and measurements from the same period are kept.';

  @override
  String get planEditThisDay => 'Edit this day';

  @override
  String get planEndDate => 'End date';

  @override
  String get planExportInProgress => 'Preparing the document…';

  @override
  String get planMoreActions => 'More actions';

  @override
  String get planNoMealsPlanned => 'No meals planned';

  @override
  String get planNoneForThisDay => 'No plan for this day';

  @override
  String get planNoneYet => 'No plan yet';

  @override
  String get planOpenEnded => 'Open-ended';

  @override
  String planOverlapNotice(String start, String end) {
    return 'The period is already taken by another plan ($start – $end).';
  }

  @override
  String planOverlapNoticeOpen(String start) {
    return 'The period is already taken by another plan (from $start).';
  }

  @override
  String planOverlapWithName(String name) {
    return 'It overlaps “$name”.';
  }

  @override
  String get planPatientNoPlanYet =>
      'Your nutritionist has not written a plan yet';

  @override
  String get planRecipient => 'Recipient';

  @override
  String get planRecordWorkout => 'Log workout';

  @override
  String get planStartDate => 'Start date';

  @override
  String planStartsOn(String date) {
    return 'The plan starts on $date';
  }

  @override
  String get planStatusActive => 'Active';

  @override
  String get planStatusCompleted => 'Completed';

  @override
  String get planStatusDraft => 'Draft';

  @override
  String get planStatusLowerActive => 'ongoing';

  @override
  String get planStatusLowerCompleted => 'completed';

  @override
  String get planStatusLowerDraft => 'draft';

  @override
  String get planStatusLowerScheduled => 'scheduled';

  @override
  String get planStatusLowerSuspended => 'suspended';

  @override
  String get planStatusScheduled => 'Scheduled';

  @override
  String get planStatusSuspended => 'Suspended';

  @override
  String get planSuspended => 'Plan suspended';

  @override
  String get planSuspendedHint => 'It resumes when you decide';

  @override
  String get planViewNoSwaps => 'No swaps on this plan.';

  @override
  String get planViewOngoing => 'ongoing';

  @override
  String get planViewOngoingUpper => 'ONGOING';

  @override
  String get planViewOpenStatistics => 'Open full statistics';

  @override
  String get planViewOverallAdherence => 'Overall plan adherence';

  @override
  String planViewPeriodRange(String start, String end) {
    return 'From $start to $end';
  }

  @override
  String get planViewPeriodStatistics => 'Period statistics';

  @override
  String get planViewPeriods => 'Periods';

  @override
  String get planViewSwapHistory => 'Swap history';

  @override
  String get planViewWeeklySchedule => 'Weekly schedule';

  @override
  String get planWeekView => 'Week';

  @override
  String get plansActivateNow => 'Activate now';

  @override
  String plansAdherencePercent(String value) {
    return '$value%';
  }

  @override
  String plansAuthoredBy(String author) {
    return 'Written by $author';
  }

  @override
  String get plansCompleteConfirmBody => 'You can always reactivate it later.';

  @override
  String get plansCompleteConfirmTitle => 'Complete the plan?';

  @override
  String get plansCurrent => 'Current';

  @override
  String plansDateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get plansEmptyOwn => 'You do not have a diet plan yet.';

  @override
  String get plansEmptyPatient =>
      'Your nutritionist has not written a plan yet.';

  @override
  String plansFrom(String date) {
    return 'From $date';
  }

  @override
  String get plansPatientNotice =>
      'Your nutritionist manages the plan content: you can tick and swap meals.';

  @override
  String plansPeriodCount(int count) {
    return '$count periods';
  }

  @override
  String get plansStartHere => 'Start here';

  @override
  String get plansWithdrawConfirmBody =>
      'It goes back to Draft: you can resume editing it.';

  @override
  String get plansWithdrawConfirmTitle => 'Withdraw the plan?';

  @override
  String get privacyPolicyAccept => 'I accept the data processing notice';

  @override
  String get privacyPolicyAcceptRequired =>
      'You must accept the notice to continue';

  @override
  String get privacyPolicyRead => 'Read the notice';

  @override
  String get privacyPolicyTitle => 'Data processing notice';

  @override
  String get privacyPolicyUpdatedBody =>
      'We have updated it: read and accept it to continue.';

  @override
  String get privacyPolicyUpdatedTitle => 'The notice has changed';

  @override
  String get profileGroup => 'Group';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLogoutConfirm => 'Sign out from this device?';

  @override
  String get profileNutritionist => 'Nutritionist';

  @override
  String get profilePersonalData => 'Personal details';

  @override
  String get profilePlans => 'Plans';

  @override
  String get profileSettings => 'Settings';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get roleNutritionist => 'Nutritionist';

  @override
  String get roleNutritionistDescription =>
      'Write and follow your patients’ plans';

  @override
  String get roleNutritionistTitle => 'I am a nutritionist';

  @override
  String get roleSelectionNotChangeable =>
      'This choice cannot be changed later';

  @override
  String get roleSelectionTitle => 'How will you use HealthyLog?';

  @override
  String get roleUser => 'User';

  @override
  String get roleUserDescription =>
      'View your diet, tick off meals and log workouts';

  @override
  String get roleUserTitle => 'I follow a plan';

  @override
  String get scheduleConfirmPlan => 'Confirm plan';

  @override
  String get scheduleIncompleteTitle => 'Incomplete schedule';

  @override
  String get scheduleRetroactivityNotice =>
      'Changes take effect today and apply to every week: days already past remain unchanged. To change a single day, use “Edit this day” from the day view.';

  @override
  String get scheduleSave => 'Save changes';

  @override
  String get scheduleSaveAsTemplate => 'Save as template';

  @override
  String get scheduleSaved => 'Plan saved.';

  @override
  String scheduleSlotsWithoutContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals without content',
      one: '1 meal without content',
    );
    return '$_temp0';
  }

  @override
  String get scheduleTemplateCreated => 'Template created.';

  @override
  String get scheduleTitle => 'Weekly schedule';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDevices => 'Connected devices';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsPrivacyPolicy => 'Notice';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionDateTime => 'Date and time';

  @override
  String get settingsSectionLanguageAndFormats => 'Language and formats';

  @override
  String get settingsSectionPrivacy => 'Privacy';

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

  @override
  String get settingsUnitImperial => 'Imperial';

  @override
  String get settingsUnitMetric => 'Metric';

  @override
  String get settingsUnitRetroactiveNotice =>
      'The change applies to all data, including charts and history.';

  @override
  String get settingsUnitSystem => 'Units';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexMale => 'Male';

  @override
  String signedNegative(String value) {
    return '−$value';
  }

  @override
  String signedPositive(String value) {
    return '+$value';
  }

  @override
  String get slotAccessoryNote => 'Side note';

  @override
  String slotAddOfType(String type) {
    return 'Add $type';
  }

  @override
  String slotAdherenceWeight(String value) {
    return 'Adherence weight: $value';
  }

  @override
  String get slotAdherenceWeightHelp =>
      'How much this meal counts towards adherence. At zero it is not counted.';

  @override
  String get slotContent => 'Content';

  @override
  String get slotDescriptiveLabel => 'Descriptive label';

  @override
  String get slotNotSpecified => 'Not specified';

  @override
  String get slotRecipeName => 'Recipe name';

  @override
  String get slotRecipeText => 'Recipe text';

  @override
  String get slotToBeDefined => 'To be defined';

  @override
  String get slotTypeBreakfast => 'Breakfast';

  @override
  String get slotTypeDinner => 'Dinner';

  @override
  String get slotTypeLunch => 'Lunch';

  @override
  String get slotTypeSnack => 'Snack';

  @override
  String get statisticsAdherence => 'Adherence';

  @override
  String get statisticsAppearWithPlan =>
      'Plan statistics appear once a plan exists.';

  @override
  String get statisticsBody => 'Body';

  @override
  String statisticsExclusionDaysSuspended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suspended days',
      one: '1 suspended day',
    );
    return '$_temp0';
  }

  @override
  String statisticsExclusionDaysUncovered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days without a plan',
      one: '1 day without a plan',
    );
    return '$_temp0';
  }

  @override
  String statisticsExclusionNotice(String what) {
    return 'The calculation excludes $what.';
  }

  @override
  String statisticsMonthOf(String month) {
    return '$month';
  }

  @override
  String get statisticsNoDataForPeriod => 'No data available for this period';

  @override
  String get statisticsNoDataYet => 'No data yet';

  @override
  String get statisticsNoPlanForPeriod => 'No plan to refer the period to';

  @override
  String statisticsPercent(String value) {
    return '$value%';
  }

  @override
  String statisticsPeriodOrdinal(int index) {
    return 'Period $index';
  }

  @override
  String statisticsPlanRange(String plan, String start, String end) {
    return '$plan · $start – $end';
  }

  @override
  String get statisticsUnavailable => 'Statistics not available';

  @override
  String statisticsWeekRange(String start, String end) {
    return 'Week from $start to $end';
  }

  @override
  String get statisticsWholePlan => 'Whole plan';

  @override
  String get statisticsWorkouts => 'Workouts';

  @override
  String get swapChooseDestination => 'Choose where to move it';

  @override
  String templateDeleteConfirmBody(String name) {
    return 'Plans already created from “$name” are unaffected.';
  }

  @override
  String get templateDeleteConfirmTitle => 'Delete the template?';

  @override
  String templateLastEdited(String when) {
    return 'Last edited: $when';
  }

  @override
  String get templateNew => 'New template';

  @override
  String get templatePreviewTitle => 'Template preview';

  @override
  String get templateRename => 'Rename template';

  @override
  String get templateRenameShort => 'Rename';

  @override
  String get templateSaved => 'Template saved.';

  @override
  String get templateScheduleTitle => 'Template schedule';

  @override
  String get templateUse => 'Use this template';

  @override
  String get templatesEmpty =>
      'No templates yet. Create one with the button below.';

  @override
  String get timezoneAfricaCairo => 'Cairo';

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
  String get timezoneAmericaSaoPaulo => 'São Paulo';

  @override
  String get timezoneAsiaBangkok => 'Bangkok';

  @override
  String get timezoneAsiaDubai => 'Dubai';

  @override
  String get timezoneAsiaHongKong => 'Hong Kong';

  @override
  String get timezoneAsiaKolkata => 'New Delhi';

  @override
  String get timezoneAsiaSeoul => 'Seoul';

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
  String get timezoneEuropeAthens => 'Athens';

  @override
  String get timezoneEuropeBerlin => 'Berlin';

  @override
  String get timezoneEuropeDublin => 'Dublin';

  @override
  String get timezoneEuropeHelsinki => 'Helsinki';

  @override
  String get timezoneEuropeLisbon => 'Lisbon';

  @override
  String get timezoneEuropeLondon => 'London';

  @override
  String get timezoneEuropeMadrid => 'Madrid';

  @override
  String get timezoneEuropeMoscow => 'Moscow';

  @override
  String get timezoneEuropeParis => 'Paris';

  @override
  String get timezoneEuropeRome => 'Rome';

  @override
  String get timezoneEuropeVienna => 'Vienna';

  @override
  String get timezoneEuropeZurich => 'Zurich';

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
  String get usernameHint => 'Your nutritionist will use it to find you';

  @override
  String get validationEmailAlreadyRegistered =>
      'This address is already registered';

  @override
  String get validationInvalidFormat => 'Invalid format';

  @override
  String get validationInvalidValue => 'Invalid value';

  @override
  String get validationPasswordsDoNotMatch => 'The passwords do not match';

  @override
  String get validationRequired => 'Required field';

  @override
  String get validationTooLong => 'Too long';

  @override
  String get validationUsernameAlreadyTaken => 'This username is already taken';

  @override
  String get verifyEmailCode => 'Confirmation code';

  @override
  String get verifyEmailCodeIncomplete => 'The code has six digits';

  @override
  String get verifyEmailConfirm => 'Confirm';

  @override
  String get verifyEmailResend => 'Send again';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Send again (${seconds}s)';
  }

  @override
  String verifyEmailSentTo(String email) {
    return 'We sent a confirmation code to $email';
  }

  @override
  String get verifyEmailTitle => 'Check your inbox';

  @override
  String get verifyEmailUseAnotherAddress => 'Use a different address';

  @override
  String get weekNext => 'Next week';

  @override
  String get weekNoPlan => 'No plan';

  @override
  String get weekPlanCompleted => 'Plan completed';

  @override
  String get weekPlanNotStarted => 'Plan not started yet';

  @override
  String get weekPrevious => 'Previous week';

  @override
  String weekRangeAcrossMonths(String start, String end) {
    return '$start – $end';
  }

  @override
  String weekRangeSameMonth(String startDay, String endDay, String monthYear) {
    return '$monthYear $startDay – $endDay';
  }

  @override
  String get weekThisWeek => 'This week';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdayInitialFriday => 'F';

  @override
  String get weekdayInitialMonday => 'M';

  @override
  String get weekdayInitialSaturday => 'S';

  @override
  String get weekdayInitialSunday => 'S';

  @override
  String get weekdayInitialThursday => 'T';

  @override
  String get weekdayInitialTuesday => 'T';

  @override
  String get weekdayInitialWednesday => 'W';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get workoutActivityType => 'Activity type';

  @override
  String get workoutActivityTypeRequired => 'Enter the activity type';

  @override
  String get workoutAddOneOff => 'Add one-off workout';

  @override
  String get workoutAddRecurring => 'Add recurring workout';

  @override
  String workoutBulletType(String type) {
    return '• $type';
  }

  @override
  String workoutBulletTypeWithCalories(String type, int calories) {
    return '• $type — $calories kcal';
  }

  @override
  String get workoutCaloriesBurned => 'Calories burned';

  @override
  String get workoutCaloriesOptional => 'If you know it. Not required.';

  @override
  String workoutCaloriesWithUnit(int value) {
    return '$value kcal';
  }

  @override
  String get workoutCease => 'Stop';

  @override
  String get workoutClearFilters => 'Clear filters';

  @override
  String get workoutDeleteConfirm => 'Delete this workout?';

  @override
  String get workoutDeleteKeepsPlanning =>
      'The planning stays: the workout goes back to planned and not done.';

  @override
  String workoutDuplicateMany(int count) {
    return 'You already logged $count workouts on this day';
  }

  @override
  String get workoutDuplicateSingle =>
      'You already logged a workout on this day';

  @override
  String get workoutEditTitle => 'Edit workout';

  @override
  String get workoutFilters => 'Filters';

  @override
  String get workoutMarkAsDone => 'Mark as done';

  @override
  String get workoutNoTypesYet => 'No activity types logged yet.';

  @override
  String get workoutNoWeeklyGoal => 'No weekly goal';

  @override
  String get workoutNonePlanned => 'No workouts planned';

  @override
  String get workoutNonePlannedDot => 'No workouts planned.';

  @override
  String get workoutNoneRecorded => 'No workouts logged';

  @override
  String get workoutNoneWithFilters => 'No workouts match these filters';

  @override
  String get workoutOneOff => 'One-off workout';

  @override
  String get workoutPerWeek => 'Workouts per week';

  @override
  String workoutPerWeekSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts per week',
      one: '1 workout per week',
    );
    return '$_temp0';
  }

  @override
  String get workoutPeriod => 'Period';

  @override
  String get workoutPickAtLeastOneDay => 'Pick at least one day';

  @override
  String get workoutPickPeriod => 'Pick a period';

  @override
  String get workoutPlanning => 'Planning';

  @override
  String get workoutPlanningNotice =>
      'Changes apply from today onwards: past days stay as they were.';

  @override
  String get workoutRecord => 'Log workout';

  @override
  String get workoutRecordAnyway => 'Log anyway';

  @override
  String get workoutRecordTitle => 'Log a workout';

  @override
  String get workoutRecurring => 'Recurring workout';

  @override
  String get workoutRemoveGoal => 'Remove goal';

  @override
  String get workoutSetGoal => 'Set';

  @override
  String get workoutSheetFooter =>
      'Add calories and a note if you like. You can also close: the workout is logged either way.';

  @override
  String get workoutStatsDistribution => 'Distribution by type';

  @override
  String get workoutStatsGoalComparison => 'Compared with the goal';

  @override
  String workoutStatsGoalProgress(int done, int goal) {
    return '$done of $goal planned';
  }

  @override
  String workoutStatsGoalProgressWeekly(int done, int goal) {
    return '$done of $goal set by the weekly goal';
  }

  @override
  String workoutStatsGoalWeeks(int weeks) {
    return 'Over $weeks whole weeks, each with the goal in force at the time.';
  }

  @override
  String workoutStatsGoalWeeksNotice(int weeks) {
    return 'Over $weeks whole weeks, each with the goal in force at the time.';
  }

  @override
  String get workoutStatsNonePlannedInPeriod =>
      'No workouts planned in the period.';

  @override
  String get workoutStatsNoneRecordedInPeriod =>
      'No workouts logged in the period.';

  @override
  String get workoutStatsPlanComparison => 'Compared with the planning';

  @override
  String workoutStatsPlanProgress(int planned, int done) {
    return '$planned planned, $done done';
  }

  @override
  String workoutStatsSuspendedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Includes $count suspended days, which adherence excludes.',
      one: 'Includes 1 suspended day, which adherence excludes.',
    );
    return '$_temp0';
  }

  @override
  String workoutStatsTotalDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts done',
      one: '1 workout done',
    );
    return '$_temp0';
  }

  @override
  String get workoutStatsWeeklyTrend => 'Weekly trend';

  @override
  String get workoutWeeklyGoal => 'Weekly goal';

  @override
  String get workoutWeeklyGoalHelp =>
      'How many times you intend to train in a week. It is independent of the days you planned.';

  @override
  String get workoutWhenDone => 'When you did it';
}
