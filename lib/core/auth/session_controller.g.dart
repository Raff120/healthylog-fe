// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). La sola tenuta in memoria è
/// provvisoria: la conservazione del token di rinnovo nell'archivio
/// sicuro del dispositivo (TK-8) e il ripristino all'avvio sono compiti
/// del prossimo task di F06 — qui la sessione esiste solo per la durata
/// del processo.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). La sola tenuta in memoria è
/// provvisoria: la conservazione del token di rinnovo nell'archivio
/// sicuro del dispositivo (TK-8) e il ripristino all'avvio sono compiti
/// del prossimo task di F06 — qui la sessione esiste solo per la durata
/// del processo.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AuthSession?> {
  /// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
  /// sola volta per dispositivo, AC-11, TK-15). La sola tenuta in memoria è
  /// provvisoria: la conservazione del token di rinnovo nell'archivio
  /// sicuro del dispositivo (TK-8) e il ripristino all'avvio sono compiti
  /// del prossimo task di F06 — qui la sessione esiste solo per la durata
  /// del processo.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSession?>(value),
    );
  }
}

String _$sessionControllerHash() => r'91426b8e4d92fda9dbe125b533271e7e0b2d2bc1';

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). La sola tenuta in memoria è
/// provvisoria: la conservazione del token di rinnovo nell'archivio
/// sicuro del dispositivo (TK-8) e il ripristino all'avvio sono compiti
/// del prossimo task di F06 — qui la sessione esiste solo per la durata
/// del processo.

abstract class _$SessionController extends $Notifier<AuthSession?> {
  AuthSession? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthSession?, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthSession?, AuthSession?>,
              AuthSession?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
