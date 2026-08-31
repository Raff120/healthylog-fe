// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionsApi)
final sessionsApiProvider = SessionsApiProvider._();

final class SessionsApiProvider
    extends $FunctionalProvider<SessionsApi, SessionsApi, SessionsApi>
    with $Provider<SessionsApi> {
  SessionsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsApiHash();

  @$internal
  @override
  $ProviderElement<SessionsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionsApi create(Ref ref) {
    return sessionsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionsApi>(value),
    );
  }
}

String _$sessionsApiHash() => r'f035ab5e98c1f49a2de822e8274ee5749adc9c3f';

/// Elenco dei dispositivi attivi (AC-14, TK-18).

@ProviderFor(DevicesController)
final devicesControllerProvider = DevicesControllerProvider._();

/// Elenco dei dispositivi attivi (AC-14, TK-18).
final class DevicesControllerProvider
    extends $AsyncNotifierProvider<DevicesController, List<DeviceSession>> {
  /// Elenco dei dispositivi attivi (AC-14, TK-18).
  DevicesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicesControllerHash();

  @$internal
  @override
  DevicesController create() => DevicesController();
}

String _$devicesControllerHash() => r'8ed643b39caefc52668ade2f13952677b976c8fe';

/// Elenco dei dispositivi attivi (AC-14, TK-18).

abstract class _$DevicesController extends $AsyncNotifier<List<DeviceSession>> {
  FutureOr<List<DeviceSession>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DeviceSession>>, List<DeviceSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DeviceSession>>, List<DeviceSession>>,
              AsyncValue<List<DeviceSession>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
