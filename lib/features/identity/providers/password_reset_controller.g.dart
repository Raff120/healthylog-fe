// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Richiesta di recupero password (AC-16, AU-18): l'esito è sempre il
/// medesimo, qui come sul server — la schermata non riceve nulla su cui
/// distinguere l'esistenza dell'account.

@ProviderFor(PasswordResetRequestController)
final passwordResetRequestControllerProvider =
    PasswordResetRequestControllerProvider._();

/// Richiesta di recupero password (AC-16, AU-18): l'esito è sempre il
/// medesimo, qui come sul server — la schermata non riceve nulla su cui
/// distinguere l'esistenza dell'account.
final class PasswordResetRequestControllerProvider
    extends
        $NotifierProvider<PasswordResetRequestController, AsyncValue<void>?> {
  /// Richiesta di recupero password (AC-16, AU-18): l'esito è sempre il
  /// medesimo, qui come sul server — la schermata non riceve nulla su cui
  /// distinguere l'esistenza dell'account.
  PasswordResetRequestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordResetRequestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordResetRequestControllerHash();

  @$internal
  @override
  PasswordResetRequestController create() => PasswordResetRequestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$passwordResetRequestControllerHash() =>
    r'6a4522aa8f49e0f53ce302be1164fb64024048a1';

/// Richiesta di recupero password (AC-16, AU-18): l'esito è sempre il
/// medesimo, qui come sul server — la schermata non riceve nulla su cui
/// distinguere l'esistenza dell'account.

abstract class _$PasswordResetRequestController
    extends $Notifier<AsyncValue<void>?> {
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

/// Reimpostazione della password (AC-16, AC-18, AU-19: invalida tutte le
/// sessioni, quindi non aggiorna la sessione corrente qui — l'Utente
/// rientra dall'accesso).

@ProviderFor(PasswordResetConfirmController)
final passwordResetConfirmControllerProvider =
    PasswordResetConfirmControllerProvider._();

/// Reimpostazione della password (AC-16, AC-18, AU-19: invalida tutte le
/// sessioni, quindi non aggiorna la sessione corrente qui — l'Utente
/// rientra dall'accesso).
final class PasswordResetConfirmControllerProvider
    extends
        $NotifierProvider<PasswordResetConfirmController, AsyncValue<void>?> {
  /// Reimpostazione della password (AC-16, AC-18, AU-19: invalida tutte le
  /// sessioni, quindi non aggiorna la sessione corrente qui — l'Utente
  /// rientra dall'accesso).
  PasswordResetConfirmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordResetConfirmControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordResetConfirmControllerHash();

  @$internal
  @override
  PasswordResetConfirmController create() => PasswordResetConfirmController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$passwordResetConfirmControllerHash() =>
    r'ad5792e6d748e259b08443d2ab480724604f27b5';

/// Reimpostazione della password (AC-16, AC-18, AU-19: invalida tutte le
/// sessioni, quindi non aggiorna la sessione corrente qui — l'Utente
/// rientra dall'accesso).

abstract class _$PasswordResetConfirmController
    extends $Notifier<AsyncValue<void>?> {
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
