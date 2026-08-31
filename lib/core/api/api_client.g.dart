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

String _$publicApiClientHash() => r'1265365eff97c4dbd3e51bc59039e03912faedab';

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6), per gli endpoint che lo richiedono. Il rinnovo trasparente
/// alla scadenza (TK-13, TK-14) è compito di un task successivo di F06.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6), per gli endpoint che lo richiedono. Il rinnovo trasparente
/// alla scadenza (TK-13, TK-14) è compito di un task successivo di F06.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP che allega il token di accesso corrente quando presente
  /// (TK-6), per gli endpoint che lo richiedono. Il rinnovo trasparente
  /// alla scadenza (TK-13, TK-14) è compito di un task successivo di F06.
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

String _$apiClientHash() => r'71a78ac7c0dfdb0c341fc4f8482886b3681265da';
