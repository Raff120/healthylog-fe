/// Tipo di evento che ha generato la notifica (NT-4). Rispecchia
/// `it.healthylog.model.NotificationType` sul backend.
///
/// FR-22: il codice non è un testo destinato all'Utente. La descrizione
/// sintetica di NT-2 è composta dal client a partire dal tipo e dal
/// payload, nella lingua selezionata (LO-1) — vedi
/// `domain/notification_presentation.dart`.
enum NotificationType {
  planAssigned,
  planWithdrawn,
  planModified,
  planSuspended,
  planResumed,
  planCompleted,
  planActivatedAutomatically,
  planCompletedAutomatically,
  mealSwappedByCook,
  slotMarkedByCook,
  measurementRecordedByNutritionist,
  careLinkRequestReceived,
  careLinkRequestAccepted,
  careLinkRequestRejected,
  careLinkRevoked,
  groupCookGranted,
  groupCookRevoked,
  groupOwnershipTransferred,
  groupMemberRemoved,
  groupDisbanded,

  /// Tipo non riconosciuto da questa versione del client. Un server più
  /// recente può introdurne di nuovi: la notifica resta visibile ed
  /// eliminabile invece di far fallire l'intero elenco.
  unknown;

  static NotificationType fromJson(String value) => switch (value) {
        'PLAN_ASSIGNED' => NotificationType.planAssigned,
        'PLAN_WITHDRAWN' => NotificationType.planWithdrawn,
        'PLAN_MODIFIED' => NotificationType.planModified,
        'PLAN_SUSPENDED' => NotificationType.planSuspended,
        'PLAN_RESUMED' => NotificationType.planResumed,
        'PLAN_COMPLETED' => NotificationType.planCompleted,
        'PLAN_ACTIVATED_AUTOMATICALLY' => NotificationType.planActivatedAutomatically,
        'PLAN_COMPLETED_AUTOMATICALLY' => NotificationType.planCompletedAutomatically,
        'MEAL_SWAPPED_BY_COOK' => NotificationType.mealSwappedByCook,
        'SLOT_MARKED_BY_COOK' => NotificationType.slotMarkedByCook,
        'MEASUREMENT_RECORDED_BY_NUTRITIONIST' => NotificationType.measurementRecordedByNutritionist,
        'CARE_LINK_REQUEST_RECEIVED' => NotificationType.careLinkRequestReceived,
        'CARE_LINK_REQUEST_ACCEPTED' => NotificationType.careLinkRequestAccepted,
        'CARE_LINK_REQUEST_REJECTED' => NotificationType.careLinkRequestRejected,
        'CARE_LINK_REVOKED' => NotificationType.careLinkRevoked,
        'GROUP_COOK_GRANTED' => NotificationType.groupCookGranted,
        'GROUP_COOK_REVOKED' => NotificationType.groupCookRevoked,
        'GROUP_OWNERSHIP_TRANSFERRED' => NotificationType.groupOwnershipTransferred,
        'GROUP_MEMBER_REMOVED' => NotificationType.groupMemberRemoved,
        'GROUP_DISBANDED' => NotificationType.groupDisbanded,
        _ => NotificationType.unknown,
      };
}
