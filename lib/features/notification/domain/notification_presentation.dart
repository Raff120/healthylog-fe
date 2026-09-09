import 'package:flutter/material.dart';

import '../../../l10n/l10n_context.dart';
import '../data/app_notification.dart';
import '../data/notification_type.dart';

/// Composizione della notifica per l'interfaccia (12.3 interfaccia.md).
///
/// FR-22, ER-2: il server non restituisce testi destinati all'Utente. La
/// descrizione sintetica di NT-2 nasce qui, dal tipo e dal payload, nella
/// lingua selezionata (LO-1).
///
/// NT-1: nessuna formulazione sollecita o incoraggia (2.1). Le frasi
/// constatano ciò che è avvenuto.
class NotificationPresentation {
  const NotificationPresentation({required this.icon, required this.text, this.destination});

  final IconData icon;
  final String text;

  /// NT-3: l'indirizzo dell'elemento a cui la notifica si riferisce, ove
  /// pertinente. Assente quando non vi è nulla da raggiungere — lo
  /// scioglimento di un Gruppo che non esiste più, per esempio.
  final String? destination;
}

/// Le icone Material sono le più prossime alle Lucide di 2.5, stesso
/// criterio già seguito dalle destinazioni della navigazione.
NotificationPresentation describeNotification(BuildContext context, AppNotification notification) {
  final l10n = context.l10n;
  final payload = notification.payload;
  final plan = _quoted(context, payload['planName']);
  final group = _quoted(context, payload['groupName']);
  final planId = payload['planId'];

  return switch (notification.type) {
    NotificationType.planAssigned => NotificationPresentation(
        icon: Icons.assignment_outlined,
        // AS-8: denominazione, autore e data di decorrenza.
        text: l10n.notificationPlanAssigned(plan, _fromDate(context, payload['startDate'])),
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planWithdrawn => NotificationPresentation(
        icon: Icons.undo_outlined,
        text: l10n.notificationPlanWithdrawn(plan),
      ),
    NotificationType.planModified => NotificationPresentation(
        icon: Icons.edit_outlined,
        text: payload['date'] == null
            ? l10n.notificationPlanModified(plan)
            : l10n.notificationPlanDayModified(_day(context, payload['date']), plan),
        destination: payload['date'] == null ? (planId == null ? null : '/diet-plans/$planId') : '/home',
      ),
    NotificationType.planSuspended => NotificationPresentation(
        icon: Icons.pause_circle_outline,
        text: l10n.notificationPlanSuspended(plan),
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planResumed => NotificationPresentation(
        icon: Icons.play_circle_outline,
        text: l10n.notificationPlanResumed(plan),
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planCompleted => NotificationPresentation(
        icon: Icons.check_circle_outline,
        text: l10n.notificationPlanCompleted(plan),
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    // NT-6: determinate dal sistema, non da una persona. La formulazione
    // non attribuisce l'atto a nessuno.
    NotificationType.planActivatedAutomatically => NotificationPresentation(
        icon: Icons.play_circle_outline,
        text: l10n.notificationPlanActivatedAutomatically(plan),
        destination: '/home',
      ),
    NotificationType.planCompletedAutomatically => NotificationPresentation(
        icon: Icons.check_circle_outline,
        text: l10n.notificationPlanCompletedAutomatically(plan),
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.mealSwappedByCook => NotificationPresentation(
        icon: Icons.swap_horiz,
        text: l10n.mealSwappedNotification(_onDate(context, payload['firstDate'])),
        destination: '/home',
      ),
    NotificationType.slotMarkedByCook => NotificationPresentation(
        icon: Icons.check_box_outlined,
        text: l10n.notificationSlotMarked(
          _slotOn(context, payload['slotType']),
          _day(context, payload['date']),
          _statusLabel(context, payload['status']),
        ),
        destination: '/home',
      ),
    NotificationType.measurementRecordedByNutritionist => NotificationPresentation(
        icon: Icons.straighten_outlined,
        text: l10n.notificationMeasurementRecorded(_day(context, payload['date'])),
        destination: '/activity',
      ),
    NotificationType.careLinkRequestReceived => NotificationPresentation(
        icon: Icons.medical_services_outlined,
        text: l10n.notificationCareRequestReceived,
        destination: '/profile/nutritionist',
      ),
    NotificationType.careLinkRequestAccepted => NotificationPresentation(
        icon: Icons.person_add_alt,
        text: l10n.notificationCareRequestAccepted,
        destination: '/home',
      ),
    NotificationType.careLinkRequestRejected => NotificationPresentation(
        icon: Icons.person_off_outlined,
        // CP-6: il solo esito, senza motivazione.
        text: l10n.notificationCareRequestRejected,
      ),
    NotificationType.careLinkRevoked => NotificationPresentation(
        icon: Icons.link_off,
        text: l10n.notificationCareLinkRevoked,
        destination: '/profile/nutritionist',
      ),
    NotificationType.groupCookGranted => NotificationPresentation(
        icon: Icons.restaurant_outlined,
        text: l10n.notificationGroupCookGranted(group),
        destination: '/group',
      ),
    NotificationType.groupCookRevoked => NotificationPresentation(
        icon: Icons.restaurant_outlined,
        text: l10n.notificationGroupCookRevoked(group),
        destination: '/group',
      ),
    NotificationType.groupOwnershipTransferred => NotificationPresentation(
        icon: Icons.shield_outlined,
        text: l10n.notificationGroupOwnershipTransferred(group),
        destination: '/group',
      ),
    NotificationType.groupMemberRemoved => NotificationPresentation(
        icon: Icons.group_remove_outlined,
        text: l10n.notificationGroupMemberRemoved(group),
      ),
    NotificationType.groupDisbanded => NotificationPresentation(
        icon: Icons.group_off_outlined,
        // NT-15: il gruppo non esiste più, non vi è nulla da raggiungere.
        text: l10n.notificationGroupDisbanded(group),
      ),
    NotificationType.unknown => NotificationPresentation(
        icon: Icons.notifications_none,
        text: l10n.notificationUnknown,
      ),
  };
}

/// GG-11, LO-3: la denominazione è contenuto dell'Utente e non va
/// tradotta né alterata. In sua assenza la frase resta corretta senza.
String _quoted(BuildContext context, String? name) =>
    name == null || name.isEmpty ? '' : context.l10n.notificationPlanNameQuoted(name);

String _fromDate(BuildContext context, String? isoDate) {
  final day = _day(context, isoDate);
  return day.isEmpty ? '' : context.l10n.notificationInForceFrom(day);
}

String _onDate(BuildContext context, String? isoDate) {
  final day = _day(context, isoDate);
  return day.isEmpty ? '' : context.l10n.notificationOnDay(day);
}

/// LO-9: formato proprio della lingua selezionata.
String _day(BuildContext context, String? isoDate) {
  if (isoDate == null) return '';
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '';
  return MaterialLocalizations.of(context).formatShortDate(date);
}

String _slotOn(BuildContext context, String? slotType) => switch (slotType) {
      'BREAKFAST' => context.l10n.notificationSlotOnBreakfast,
      'LUNCH' => context.l10n.notificationSlotOnLunch,
      'DINNER' => context.l10n.notificationSlotOnDinner,
      'SNACK' => context.l10n.notificationSlotOnSnack,
      _ => context.l10n.notificationSlotOnGeneric,
    };

String _statusLabel(BuildContext context, String? status) => switch (status) {
      'CONSUMED' => context.l10n.notificationStatusConsumed,
      'SKIPPED' => context.l10n.notificationStatusSkipped,
      _ => context.l10n.notificationStatusToConsume,
    };
