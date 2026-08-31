// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Invio del modulo di accesso (AC-8). Le credenziali errate e il blocco
/// temporaneo (AU-21, AU-23) producono lo stesso codice indistinto
/// `INVALID_CREDENTIALS`, tradotto dalla schermata (5.2 interfaccia.md);
/// `ACCOUNT_NOT_VERIFIED` è gestito a parte, per condurre alla verifica
/// invece che a un messaggio d'errore.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Invio del modulo di accesso (AC-8). Le credenziali errate e il blocco
/// temporaneo (AU-21, AU-23) producono lo stesso codice indistinto
/// `INVALID_CREDENTIALS`, tradotto dalla schermata (5.2 interfaccia.md);
/// `ACCOUNT_NOT_VERIFIED` è gestito a parte, per condurre alla verifica
/// invece che a un messaggio d'errore.
final class LoginControllerProvider
    extends $NotifierProvider<LoginController, AsyncValue<void>?> {
  /// Invio del modulo di accesso (AC-8). Le credenziali errate e il blocco
  /// temporaneo (AU-21, AU-23) producono lo stesso codice indistinto
  /// `INVALID_CREDENTIALS`, tradotto dalla schermata (5.2 interfaccia.md);
  /// `ACCOUNT_NOT_VERIFIED` è gestito a parte, per condurre alla verifica
  /// invece che a un messaggio d'errore.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$loginControllerHash() => r'e24eb53bb532a4f1fd2c4b0fd9d1bf4b9d92253a';

/// Invio del modulo di accesso (AC-8). Le credenziali errate e il blocco
/// temporaneo (AU-21, AU-23) producono lo stesso codice indistinto
/// `INVALID_CREDENTIALS`, tradotto dalla schermata (5.2 interfaccia.md);
/// `ACCOUNT_NOT_VERIFIED` è gestito a parte, per condurre alla verifica
/// invece che a un messaggio d'errore.

abstract class _$LoginController extends $Notifier<AsyncValue<void>?> {
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
