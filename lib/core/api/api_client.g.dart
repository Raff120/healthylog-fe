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

@ProviderFor(publicApiClient)
final publicApiClientProvider = PublicApiClientProvider._();

/// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
/// specifica-tecnica.md): per gli endpoint pubblici della feature
/// identity (registrazione, accesso, rinnovo...). Distinto da
/// [apiClient] per non introdurre una dipendenza circolare — il
/// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
/// che un token di accesso esista.

final class PublicApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
  /// specifica-tecnica.md): per gli endpoint pubblici della feature
  /// identity (registrazione, accesso, rinnovo...). Distinto da
  /// [apiClient] per non introdurre una dipendenza circolare — il
  /// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
  /// che un token di accesso esista.
  PublicApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicApiClientProvider',
        isAutoDispose: true,
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

String _$publicApiClientHash() => r'0811ad6f4c8f1549d45ce6e05348c5edff15afd7';

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
/// gli endpoint che richiedono autenticazione.
///
/// L'ordine degli intercettori è significativo: le richieste passano
/// nell'ordine di aggiunta (intestazione prima di tutto), gli errori
/// tornano nell'ordine inverso — [ApiErrorInterceptor] deve tradurre la
/// risposta in [ApiException] prima che [TokenRefreshInterceptor] possa
/// riconoscere `TOKEN_EXPIRED`.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
/// gli endpoint che richiedono autenticazione.
///
/// L'ordine degli intercettori è significativo: le richieste passano
/// nell'ordine di aggiunta (intestazione prima di tutto), gli errori
/// tornano nell'ordine inverso — [ApiErrorInterceptor] deve tradurre la
/// risposta in [ApiException] prima che [TokenRefreshInterceptor] possa
/// riconoscere `TOKEN_EXPIRED`.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP che allega il token di accesso corrente quando presente
  /// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
  /// gli endpoint che richiedono autenticazione.
  ///
  /// L'ordine degli intercettori è significativo: le richieste passano
  /// nell'ordine di aggiunta (intestazione prima di tutto), gli errori
  /// tornano nell'ordine inverso — [ApiErrorInterceptor] deve tradurre la
  /// risposta in [ApiException] prima che [TokenRefreshInterceptor] possa
  /// riconoscere `TOKEN_EXPIRED`.
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
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

String _$apiClientHash() => r'75b3ef9ac89d1be4dace4edb11f84c6798084d92';
