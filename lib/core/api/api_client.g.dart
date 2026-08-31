// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Client HTTP di base (4.2, 4.3 specifica-tecnica.md): JSON con codifica
/// UTF-8, percorsi privi di prefisso (AP-3), errori tradotti in
/// [ApiException]. Non allega ancora alcuna intestazione di autorizzazione:
/// la sessione è predisposta in F06.

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Client HTTP di base (4.2, 4.3 specifica-tecnica.md): JSON con codifica
/// UTF-8, percorsi privi di prefisso (AP-3), errori tradotti in
/// [ApiException]. Non allega ancora alcuna intestazione di autorizzazione:
/// la sessione è predisposta in F06.

final class ApiClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client HTTP di base (4.2, 4.3 specifica-tecnica.md): JSON con codifica
  /// UTF-8, percorsi privi di prefisso (AP-3), errori tradotti in
  /// [ApiException]. Non allega ancora alcuna intestazione di autorizzazione:
  /// la sessione è predisposta in F06.
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

String _$apiClientHash() => r'7b4941a4719feec77a035e32b2cdce361f9e9032';
