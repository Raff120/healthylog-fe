// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'username_availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Verifica di disponibilità del nome utente (5.1 interfaccia.md), invocata
/// dopo una breve pausa dalla digitazione — il rinvio (debounce) è gestito
/// dalla schermata, non qui.

@ProviderFor(UsernameAvailabilityController)
final usernameAvailabilityControllerProvider =
    UsernameAvailabilityControllerProvider._();

/// Verifica di disponibilità del nome utente (5.1 interfaccia.md), invocata
/// dopo una breve pausa dalla digitazione — il rinvio (debounce) è gestito
/// dalla schermata, non qui.
final class UsernameAvailabilityControllerProvider
    extends
        $NotifierProvider<UsernameAvailabilityController, AsyncValue<bool>?> {
  /// Verifica di disponibilità del nome utente (5.1 interfaccia.md), invocata
  /// dopo una breve pausa dalla digitazione — il rinvio (debounce) è gestito
  /// dalla schermata, non qui.
  UsernameAvailabilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usernameAvailabilityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usernameAvailabilityControllerHash();

  @$internal
  @override
  UsernameAvailabilityController create() => UsernameAvailabilityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>?>(value),
    );
  }
}

String _$usernameAvailabilityControllerHash() =>
    r'33cd598a518b1f10f5c33cb83faff51981bf889b';

/// Verifica di disponibilità del nome utente (5.1 interfaccia.md), invocata
/// dopo una breve pausa dalla digitazione — il rinvio (debounce) è gestito
/// dalla schermata, non qui.

abstract class _$UsernameAvailabilityController
    extends $Notifier<AsyncValue<bool>?> {
  AsyncValue<bool>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>?, AsyncValue<bool>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>?, AsyncValue<bool>?>,
              AsyncValue<bool>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
