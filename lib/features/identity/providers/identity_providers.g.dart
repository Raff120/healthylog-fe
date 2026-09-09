// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Usa [publicApiClientProvider], non [apiClientProvider]: tutti gli
/// endpoint della feature identity sono pubblici (4.4 tecnica), e
/// [apiClientProvider] dipende dalla sessione — usarlo qui produrrebbe
/// una dipendenza circolare, dato che il ripristino della sessione
/// (TK-8) chiama `/auth/refresh` attraverso questo stesso provider.

@ProviderFor(identityApi)
final identityApiProvider = IdentityApiProvider._();

/// Usa [publicApiClientProvider], non [apiClientProvider]: tutti gli
/// endpoint della feature identity sono pubblici (4.4 tecnica), e
/// [apiClientProvider] dipende dalla sessione — usarlo qui produrrebbe
/// una dipendenza circolare, dato che il ripristino della sessione
/// (TK-8) chiama `/auth/refresh` attraverso questo stesso provider.

final class IdentityApiProvider
    extends $FunctionalProvider<IdentityApi, IdentityApi, IdentityApi>
    with $Provider<IdentityApi> {
  /// Usa [publicApiClientProvider], non [apiClientProvider]: tutti gli
  /// endpoint della feature identity sono pubblici (4.4 tecnica), e
  /// [apiClientProvider] dipende dalla sessione — usarlo qui produrrebbe
  /// una dipendenza circolare, dato che il ripristino della sessione
  /// (TK-8) chiama `/auth/refresh` attraverso questo stesso provider.
  IdentityApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityApiHash();

  @$internal
  @override
  $ProviderElement<IdentityApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdentityApi create(Ref ref) {
    return identityApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityApi>(value),
    );
  }
}

String _$identityApiHash() => r'244284cf743676b60732a0f9f441e783f5fb5575';
