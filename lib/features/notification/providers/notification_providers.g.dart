// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationApi)
final notificationApiProvider = NotificationApiProvider._();

final class NotificationApiProvider
    extends
        $FunctionalProvider<NotificationApi, NotificationApi, NotificationApi>
    with $Provider<NotificationApi> {
  NotificationApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationApiHash();

  @$internal
  @override
  $ProviderElement<NotificationApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationApi create(Ref ref) {
    return notificationApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationApi>(value),
    );
  }
}

String _$notificationApiHash() => r'49d8aa598973ab360ebe576403957b444fabdaec';

/// NT-7: il centro notifiche, in ordine cronologico decrescente. NT-10:
/// la sola lettura non marca nulla — la marcatura è del solo
/// [NotificationController].

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

/// NT-7: il centro notifiche, in ordine cronologico decrescente. NT-10:
/// la sola lettura non marca nulla — la marcatura è del solo
/// [NotificationController].
final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<AppNotification>> {
  /// NT-7: il centro notifiche, in ordine cronologico decrescente. NT-10:
  /// la sola lettura non marca nulla — la marcatura è del solo
  /// [NotificationController].
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();
}

String _$notificationsHash() => r'd02ecf9a94438eacf37dcf484591bf8127fbb815';

/// NT-7: il centro notifiche, in ordine cronologico decrescente. NT-10:
/// la sola lettura non marca nulla — la marcatura è del solo
/// [NotificationController].

abstract class _$Notifications extends $AsyncNotifier<List<AppNotification>> {
  FutureOr<List<AppNotification>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// NT-8: il conteggio delle non lette, che l'indicatore dell'intestazione
/// presenta senza aprire il centro notifiche. Tenuto in vita fra le
/// schermate: l'indicatore compare in ogni destinazione principale e
/// ricalcolarlo a ogni cambio di destinazione lo farebbe lampeggiare.

@ProviderFor(UnreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// NT-8: il conteggio delle non lette, che l'indicatore dell'intestazione
/// presenta senza aprire il centro notifiche. Tenuto in vita fra le
/// schermate: l'indicatore compare in ogni destinazione principale e
/// ricalcolarlo a ogni cambio di destinazione lo farebbe lampeggiare.
final class UnreadNotificationCountProvider
    extends $AsyncNotifierProvider<UnreadNotificationCount, int> {
  /// NT-8: il conteggio delle non lette, che l'indicatore dell'intestazione
  /// presenta senza aprire il centro notifiche. Tenuto in vita fra le
  /// schermate: l'indicatore compare in ogni destinazione principale e
  /// ricalcolarlo a ogni cambio di destinazione lo farebbe lampeggiare.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  UnreadNotificationCount create() => UnreadNotificationCount();
}

String _$unreadNotificationCountHash() =>
    r'1ca459e9066666701ae04035cb7b9911c2049687';

/// NT-8: il conteggio delle non lette, che l'indicatore dell'intestazione
/// presenta senza aprire il centro notifiche. Tenuto in vita fra le
/// schermate: l'indicatore compare in ogni destinazione principale e
/// ricalcolarlo a ogni cambio di destinazione lo farebbe lampeggiare.

abstract class _$UnreadNotificationCount extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// NT-10, NT-11, NT-12: lettura ed eliminazione.

@ProviderFor(NotificationController)
final notificationControllerProvider = NotificationControllerProvider._();

/// NT-10, NT-11, NT-12: lettura ed eliminazione.
final class NotificationControllerProvider
    extends $NotifierProvider<NotificationController, AsyncValue<void>?> {
  /// NT-10, NT-11, NT-12: lettura ed eliminazione.
  NotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationControllerHash();

  @$internal
  @override
  NotificationController create() => NotificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$notificationControllerHash() =>
    r'fd9371953bef4b204ba6b603d997cc4cfb212991';

/// NT-10, NT-11, NT-12: lettura ed eliminazione.

abstract class _$NotificationController extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
