// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Modifica della password dell'Utente autenticato (AC-19, AU-20).
///
/// Non passa da `ProfileController`: la password non fa parte del
/// profilo che quello espone, e l'esito non ne muta alcun campo. Le
/// sessioni attive restano aperte (AU-20) — non ricorre il sospetto di
/// compromissione che AC-18 presume nel recupero.

@ProviderFor(ChangePasswordController)
final changePasswordControllerProvider = ChangePasswordControllerProvider._();

/// Modifica della password dell'Utente autenticato (AC-19, AU-20).
///
/// Non passa da `ProfileController`: la password non fa parte del
/// profilo che quello espone, e l'esito non ne muta alcun campo. Le
/// sessioni attive restano aperte (AU-20) — non ricorre il sospetto di
/// compromissione che AC-18 presume nel recupero.
final class ChangePasswordControllerProvider
    extends $NotifierProvider<ChangePasswordController, AsyncValue<void>?> {
  /// Modifica della password dell'Utente autenticato (AC-19, AU-20).
  ///
  /// Non passa da `ProfileController`: la password non fa parte del
  /// profilo che quello espone, e l'esito non ne muta alcun campo. Le
  /// sessioni attive restano aperte (AU-20) — non ricorre il sospetto di
  /// compromissione che AC-18 presume nel recupero.
  ChangePasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordControllerHash();

  @$internal
  @override
  ChangePasswordController create() => ChangePasswordController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$changePasswordControllerHash() =>
    r'2f090fa8d8d10c26a3a4d88426cd1e0264993b4c';

/// Modifica della password dell'Utente autenticato (AC-19, AU-20).
///
/// Non passa da `ProfileController`: la password non fa parte del
/// profilo che quello espone, e l'esito non ne muta alcun campo. Le
/// sessioni attive restano aperte (AU-20) — non ricorre il sospetto di
/// compromissione che AC-18 presume nel recupero.

abstract class _$ChangePasswordController extends $Notifier<AsyncValue<void>?> {
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
