// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
/// specifica-tecnica.md): per gli endpoint pubblici della feature
/// identity (registrazione, accesso, rinnovo...). Distinto da
/// [apiClient] per non introdurre una dipendenza circolare — il
/// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
/// che un token di accesso esista.
///
/// `keepAlive`: un client HTTP è per natura un servizio applicativo,
/// non uno stato legato a una schermata. Senza, un provider che lo
/// ottiene con `ref.read` invece di `ref.watch` (come i provider
/// dell'API di una singola feature, che lo leggono una sola volta nel
/// proprio `build`) non lo terrebbe in vita abbastanza a lungo:
/// l'eliminazione automatica può intervenire mentre una richiesta è
/// ancora in corso, invalidando il `ref` catturato dagli intercettori
/// e bloccandola in modo silenzioso, prima ancora che raggiunga la
/// rete — lo stesso rischio già corretto per `SessionController`.

@ProviderFor(publicApiClient)
final publicApiClientProvider = PublicApiClientProvider._();

/// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
/// specifica-tecnica.md): per gli endpoint pubblici della feature
/// identity (registrazione, accesso, rinnovo...). Distinto da
/// [apiClient] per non introdurre una dipendenza circolare — il
/// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
/// che un token di accesso esista.
///
/// `keepAlive`: un client HTTP è per natura un servizio applicativo,
/// non uno stato legato a una schermata. Senza, un provider che lo
/// ottiene con `ref.read` invece di `ref.watch` (come i provider
/// dell'API di una singola feature, che lo leggono una sola volta nel
/// proprio `build`) non lo terrebbe in vita abbastanza a lungo:
/// l'eliminazione automatica può intervenire mentre una richiesta è
/// ancora in corso, invalidando il `ref` catturato dagli intercettori
/// e bloccandola in modo silenzioso, prima ancora che raggiunga la
/// rete — lo stesso rischio già corretto per `SessionController`.

final class PublicApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
  /// specifica-tecnica.md): per gli endpoint pubblici della feature
  /// identity (registrazione, accesso, rinnovo...). Distinto da
  /// [apiClient] per non introdurre una dipendenza circolare — il
  /// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
  /// che un token di accesso esista.
  ///
  /// `keepAlive`: un client HTTP è per natura un servizio applicativo,
  /// non uno stato legato a una schermata. Senza, un provider che lo
  /// ottiene con `ref.read` invece di `ref.watch` (come i provider
  /// dell'API di una singola feature, che lo leggono una sola volta nel
  /// proprio `build`) non lo terrebbe in vita abbastanza a lungo:
  /// l'eliminazione automatica può intervenire mentre una richiesta è
  /// ancora in corso, invalidando il `ref` catturato dagli intercettori
  /// e bloccandola in modo silenzioso, prima ancora che raggiunga la
  /// rete — lo stesso rischio già corretto per `SessionController`.
  PublicApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicApiClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return publicApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$publicApiClientHash() => r'2bc723a8476748ad16e7bea3eb191be770d71cca';

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
/// gli endpoint che richiedono autenticazione. `keepAlive`: stessa
/// ragione di [publicApiClient].
///
/// L'ordine degli intercettori è significativo: sia le richieste sia gli
/// errori attraversano la coda nell'ordine di aggiunta (dio incatena gli
/// `onError` con `Future.catchError` in quello stesso ordine).
/// [TokenRefreshInterceptor] e [ConnectivityInterceptor] DEVONO quindi
/// precedere [ApiErrorInterceptor] per intercettare la risposta grezza
/// prima che questo la traduca e la completi con `reject` — che, per
/// impostazione predefinita, salta il resto della coda (vedi il
/// commento su [TokenRefreshInterceptor]). [ConnectivityInterceptor]
/// precede a sua volta [TokenRefreshInterceptor], per classificare
/// sempre l'errore grezzo della richiesta originale (OF-6),
/// indipendentemente da come quest'ultimo lo gestisca.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
/// gli endpoint che richiedono autenticazione. `keepAlive`: stessa
/// ragione di [publicApiClient].
///
/// L'ordine degli intercettori è significativo: sia le richieste sia gli
/// errori attraversano la coda nell'ordine di aggiunta (dio incatena gli
/// `onError` con `Future.catchError` in quello stesso ordine).
/// [TokenRefreshInterceptor] e [ConnectivityInterceptor] DEVONO quindi
/// precedere [ApiErrorInterceptor] per intercettare la risposta grezza
/// prima che questo la traduca e la completi con `reject` — che, per
/// impostazione predefinita, salta il resto della coda (vedi il
/// commento su [TokenRefreshInterceptor]). [ConnectivityInterceptor]
/// precede a sua volta [TokenRefreshInterceptor], per classificare
/// sempre l'errore grezzo della richiesta originale (OF-6),
/// indipendentemente da come quest'ultimo lo gestisca.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP che allega il token di accesso corrente quando presente
  /// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
  /// gli endpoint che richiedono autenticazione. `keepAlive`: stessa
  /// ragione di [publicApiClient].
  ///
  /// L'ordine degli intercettori è significativo: sia le richieste sia gli
  /// errori attraversano la coda nell'ordine di aggiunta (dio incatena gli
  /// `onError` con `Future.catchError` in quello stesso ordine).
  /// [TokenRefreshInterceptor] e [ConnectivityInterceptor] DEVONO quindi
  /// precedere [ApiErrorInterceptor] per intercettare la risposta grezza
  /// prima che questo la traduca e la completi con `reject` — che, per
  /// impostazione predefinita, salta il resto della coda (vedi il
  /// commento su [TokenRefreshInterceptor]). [ConnectivityInterceptor]
  /// precede a sua volta [TokenRefreshInterceptor], per classificare
  /// sempre l'errore grezzo della richiesta originale (OF-6),
  /// indipendentemente da come quest'ultimo lo gestisca.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiClientHash() => r'6ce863ca50b20a87763922b2e0dbaed81506bcd5';
