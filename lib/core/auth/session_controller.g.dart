// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.
///
/// `keepAlive`: letto con `ref.read` (non `ref.watch`) dagli
/// intercettori HTTP, che altrimenti non lo terrebbero in vita — la
/// sessione andrebbe perduta ogni volta che nessuna schermata la osserva.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.
///
/// `keepAlive`: letto con `ref.read` (non `ref.watch`) dagli
/// intercettori HTTP, che altrimenti non lo terrebbero in vita — la
/// sessione andrebbe perduta ogni volta che nessuna schermata la osserva.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, AuthSession?> {
  /// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
  /// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
  /// ripristino dal token di rinnovo conservato nell'archivio sicuro
  /// (TK-8): un token presente ma non più valido (revocato, scaduto) è
  /// trattato come sessione assente, non come errore da mostrare.
  ///
  /// `keepAlive`: letto con `ref.read` (non `ref.watch`) dagli
  /// intercettori HTTP, che altrimenti non lo terrebbero in vita — la
  /// sessione andrebbe perduta ogni volta che nessuna schermata la osserva.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'c0e7dde1d5c71f3623ea6d22d53acdbd9aa97d0d';

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.
///
/// `keepAlive`: letto con `ref.read` (non `ref.watch`) dagli
/// intercettori HTTP, che altrimenti non lo terrebbero in vita — la
/// sessione andrebbe perduta ogni volta che nessuna schermata la osserva.

abstract class _$SessionController extends $AsyncNotifier<AuthSession?> {
  FutureOr<AuthSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthSession?>, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSession?>, AuthSession?>,
              AsyncValue<AuthSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
