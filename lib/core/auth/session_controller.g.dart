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

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, AuthSession?> {
  /// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
  /// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
  /// ripristino dal token di rinnovo conservato nell'archivio sicuro
  /// (TK-8): un token presente ma non più valido (revocato, scaduto) è
  /// trattato come sessione assente, non come errore da mostrare.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'9d3ab2226e0e508c66f28033fea3ad37552443fb';

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.

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
