import 'package:flutter/material.dart';

import '../data/app_notification.dart';
import '../data/notification_type.dart';

/// Composizione della notifica per l'interfaccia (12.3 interfaccia.md).
///
/// FR-22, ER-2: il server non restituisce testi destinati all'Utente. La
/// descrizione sintetica di NT-2 nasce qui, dal tipo e dal payload, ed è
/// il solo punto in cui i due si traducono in parole — quando F29
/// introdurrà l'inglese (LO-1) sarà questo file a cambiare, non le
/// schermate.
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
NotificationPresentation describeNotification(AppNotification notification) {
  final payload = notification.payload;
  final planName = payload['planName'];
  final groupName = payload['groupName'];
  final planId = payload['planId'];

  return switch (notification.type) {
    NotificationType.planAssigned => NotificationPresentation(
        icon: Icons.assignment_outlined,
        // AS-8: denominazione, autore e data di decorrenza.
        text: 'Ti è stato assegnato il piano${_quoted(planName)}'
            '${_fromDate(payload['startDate'])}.',
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planWithdrawn => NotificationPresentation(
        icon: Icons.undo_outlined,
        text: 'Il piano${_quoted(planName)} è stato ritirato ed è tornato in revisione.',
      ),
    NotificationType.planModified => NotificationPresentation(
        icon: Icons.edit_outlined,
        text: payload['date'] == null
            ? 'Il piano${_quoted(planName)} è stato modificato.'
            : 'La giornata del ${_day(payload['date'])} del piano${_quoted(planName)} è stata modificata.',
        destination: payload['date'] == null
            ? (planId == null ? null : '/diet-plans/$planId')
            : '/home',
      ),
    NotificationType.planSuspended => NotificationPresentation(
        icon: Icons.pause_circle_outline,
        text: 'Il piano${_quoted(planName)} è stato sospeso.',
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planResumed => NotificationPresentation(
        icon: Icons.play_circle_outline,
        text: 'Il piano${_quoted(planName)} è stato ripreso.',
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.planCompleted => NotificationPresentation(
        icon: Icons.check_circle_outline,
        text: 'Il piano${_quoted(planName)} è stato concluso.',
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    // NT-6: determinate dal sistema, non da una persona. La formulazione
    // non attribuisce l'atto a nessuno.
    NotificationType.planActivatedAutomatically => NotificationPresentation(
        icon: Icons.play_circle_outline,
        text: 'Il piano${_quoted(planName)} è entrato in vigore.',
        destination: '/home',
      ),
    NotificationType.planCompletedAutomatically => NotificationPresentation(
        icon: Icons.check_circle_outline,
        text: 'Il piano${_quoted(planName)} si è concluso alla data prevista.',
        destination: planId == null ? null : '/diet-plans/$planId',
      ),
    NotificationType.mealSwappedByCook => NotificationPresentation(
        icon: Icons.swap_horiz,
        text: 'Due pasti del tuo piano sono stati invertiti'
            '${_onDate(payload['firstDate'])}.',
        destination: '/home',
      ),
    NotificationType.slotMarkedByCook => NotificationPresentation(
        icon: Icons.check_box_outlined,
        text: '${_slotOn(payload['slotType'])} del ${_day(payload['date'])} '
            'è stato registrato lo stato ${_statusLabel(payload['status'])}.',
        destination: '/home',
      ),
    NotificationType.measurementRecordedByNutritionist => NotificationPresentation(
        icon: Icons.straighten_outlined,
        text: 'È stata registrata una misurazione del ${_day(payload['date'])}.',
        destination: '/activity',
      ),
    NotificationType.careLinkRequestReceived => NotificationPresentation(
        icon: Icons.medical_services_outlined,
        text: 'Hai ricevuto una richiesta di collegamento professionale.',
        destination: '/profile/nutritionist',
      ),
    NotificationType.careLinkRequestAccepted => NotificationPresentation(
        icon: Icons.person_add_alt,
        text: 'La tua richiesta di collegamento è stata accettata.',
        destination: '/home',
      ),
    NotificationType.careLinkRequestRejected => NotificationPresentation(
        icon: Icons.person_off_outlined,
        // CP-6: il solo esito, senza motivazione.
        text: 'La tua richiesta di collegamento è stata rifiutata.',
      ),
    NotificationType.careLinkRevoked => NotificationPresentation(
        icon: Icons.link_off,
        text: 'Il collegamento professionale è stato revocato.',
        destination: '/profile/nutritionist',
      ),
    NotificationType.groupCookGranted => NotificationPresentation(
        icon: Icons.restaurant_outlined,
        text: 'Sei stato nominato Cuoco del gruppo${_quoted(groupName)}.',
        destination: '/group',
      ),
    NotificationType.groupCookRevoked => NotificationPresentation(
        icon: Icons.restaurant_outlined,
        text: 'Non sei più Cuoco del gruppo${_quoted(groupName)}.',
        destination: '/group',
      ),
    NotificationType.groupOwnershipTransferred => NotificationPresentation(
        icon: Icons.shield_outlined,
        text: 'Sei diventato Proprietario del gruppo${_quoted(groupName)}.',
        destination: '/group',
      ),
    NotificationType.groupMemberRemoved => NotificationPresentation(
        icon: Icons.group_remove_outlined,
        text: 'Sei stato rimosso dal gruppo${_quoted(groupName)}.',
      ),
    NotificationType.groupDisbanded => NotificationPresentation(
        icon: Icons.group_off_outlined,
        // NT-15: il gruppo non esiste più, non vi è nulla da raggiungere.
        text: 'Il gruppo${_quoted(groupName)} è stato sciolto.',
      ),
    NotificationType.unknown => const NotificationPresentation(
        icon: Icons.notifications_none,
        text: 'Si è verificato un evento che riguarda il tuo account.',
      ),
  };
}

/// GG-11, LO-3: la denominazione è contenuto dell'Utente e non va
/// tradotta né alterata. In sua assenza la frase resta corretta senza.
String _quoted(String? name) => name == null || name.isEmpty ? '' : ' «$name»';

String _fromDate(String? isoDate) {
  final day = _day(isoDate);
  return day.isEmpty ? '' : ', in vigore dal $day';
}

String _onDate(String? isoDate) {
  final day = _day(isoDate);
  return day.isEmpty ? '' : ' nella giornata del $day';
}

/// LO-9: formato italiano. F29 lo renderà dipendente dalla lingua.
String _day(String? isoDate) {
  if (isoDate == null) return '';
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// La forma preposizionale evita l'accordo di genere con il participio
/// che segue, che varierebbe fra "la colazione" e "il pranzo".
String _slotOn(String? slotType) => switch (slotType) {
      'BREAKFAST' => 'Sulla colazione',
      'LUNCH' => 'Sul pranzo',
      'DINNER' => 'Sulla cena',
      'SNACK' => 'Sullo spuntino',
      _ => 'Su un pasto',
    };

String _statusLabel(String? status) => switch (status) {
      'CONSUMED' => '«Consumato»',
      'SKIPPED' => '«Saltato»',
      _ => '«Da consumare»',
    };
