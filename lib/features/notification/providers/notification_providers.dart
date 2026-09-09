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

  /// NT-12: lo scorrimento laterale ha conferma implicita (12.3), e la
  /// voce va tolta dall'elenco nel fotogramma stesso in cui il gesto si
  /// conclude — non al ritorno del server. L'eliminazione effettiva
  /// prosegue nel [NotificationController], che ripristina l'elenco se
  /// non riesce.
  void removeLocally(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.where((notification) => notification.id != id).toList());
  }
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

/// NT-10, NT-11, NT-12: lettura ed eliminazione.
@riverpod
class NotificationController extends _$NotificationController {
  @override
  AsyncValue<void>? build() => null;

  /// NT-10: conseguente al solo tocco esplicito su una notifica.
  Future<void> markRead(String id) => _run(() => ref.read(notificationApiProvider).markRead(id));

  /// NT-11: tutte le non lette in un'unica operazione.
  Future<void> markAllRead() => _run(() => ref.read(notificationApiProvider).markAllRead());

  /// NT-12: ammessa su notifiche lette e non lette. NT-15: non ha effetto
  /// sull'evento a cui si riferisce.
  Future<void> delete(String id) {
    ref.read(notificationsProvider.notifier).removeLocally(id);
    return _run(() => ref.read(notificationApiProvider).delete(id));
  }

  Future<void> _run(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    final outcome = await AsyncValue.guard(operation);
    // Il controller vive quanto la schermata che lo osserva. Un'operazione
    // ancora in volo quando la schermata è lasciata — il tocco su una
    // notifica, che marca e naviga insieme (NT-10, NT-3) — la troverebbe
    // già smontata: scrivere lo stato o invalidare da lì solleverebbe.
    // L'operazione sul server è comunque conclusa.
    if (!ref.mounted) return;
    state = outcome;
    if (outcome.hasError) {
      // L'elenco è riportato a quanto il server conosce: una rimozione
      // anticipata che non ha avuto seguito torna al suo posto.
      ref.invalidate(notificationsProvider);
      return;
    }
    ref.invalidate(notificationsProvider);
    await ref.read(unreadNotificationCountProvider.notifier).refresh();
  }
}
