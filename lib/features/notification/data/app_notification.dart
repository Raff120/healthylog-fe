import 'notification_type.dart';

/// Notifica in-app (NT-1). Denominata `AppNotification` per non collidere
/// con `Notification` di Flutter, che è la classe base della propagazione
/// degli eventi lungo l'albero dei widget.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.occurredAt,
    this.actorId,
    this.actorName,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: NotificationType.fromJson(json['type'] as String? ?? ''),
        payload: {
          for (final entry in (json['payload'] as Map<String, dynamic>? ?? const {}).entries)
            entry.key: '${entry.value}',
        },
        actorId: json['actorId'] as String?,
        actorName: json['actorName'] as String?,
        occurredAt: DateTime.parse(json['occurredAt'] as String).toLocal(),
        readAt: json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String).toLocal(),
      );

  final String id;
  final NotificationType type;

  /// NT-3: riferimenti all'elemento a cui la notifica conduce.
  final Map<String, String> payload;

  /// NT-2: chi ha determinato l'evento; assente per le transizioni
  /// automatiche del sistema (NT-6).
  final String? actorId;
  final String? actorName;

  final DateTime occurredAt;

  /// NT-9: assente per le non lette.
  final DateTime? readAt;

  bool get isRead => readAt != null;
}
