import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/app_notification.dart';
import '../data/notification_api.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationApi notificationApi(Ref ref) => NotificationApi(ref.watch(apiClientProvider));

/// NT-7: il centro notifiche, in ordine cronologico decrescente. NT-10:
/// la sola lettura non marca nulla — la marcatura è del solo
/// [NotificationController].
@riverpod
class Notifications extends _$Notifications {
  @override
  Future<List<AppNotification>> build() => ref.read(notificationApiProvider).list();
}

/// NT-8: il conteggio delle non lette, che l'indicatore dell'intestazione
/// presenta senza aprire il centro notifiche. Tenuto in vita fra le
/// schermate: l'indicatore compare in ogni destinazione principale e
/// ricalcolarlo a ogni cambio di destinazione lo farebbe lampeggiare.
@Riverpod(keepAlive: true)
class UnreadNotificationCount extends _$UnreadNotificationCount {
  @override
  Future<int> build() => _count();

  Future<void> refresh() async {
    state = AsyncValue.data(await _count());
  }

  /// L'indicatore non è una superficie d'errore. Il fallimento della
  /// richiesta — rete assente su tutte le altre, o server irraggiungibile
  /// — si risolve nell'assenza dell'indicatore, non in un errore
  /// presentato: lo stato offline ha già la propria segnalazione discreta
  /// (OF-6, OF-22), e ER-1 vuole distinta da essa l'indisponibilità.
  Future<int> _count() async {
    try {
      return await ref.read(notificationApiProvider).unreadCount();
    } catch (_) {
      return 0;
    }
  }
}
