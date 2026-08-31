// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(identityApi)
final identityApiProvider = IdentityApiProvider._();

final class IdentityApiProvider
    extends $FunctionalProvider<IdentityApi, IdentityApi, IdentityApi>
    with $Provider<IdentityApi> {
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

String _$identityApiHash() => r'2f972f3c56d9ae4959ad79c9fb99648d4109d56d';
