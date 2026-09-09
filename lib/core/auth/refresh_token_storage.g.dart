// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(refreshTokenStorage)
final refreshTokenStorageProvider = RefreshTokenStorageProvider._();

final class RefreshTokenStorageProvider
    extends
        $FunctionalProvider<
          RefreshTokenStorage,
          RefreshTokenStorage,
          RefreshTokenStorage
        >
    with $Provider<RefreshTokenStorage> {
  RefreshTokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshTokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshTokenStorageHash();

  @$internal
  @override
  $ProviderElement<RefreshTokenStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshTokenStorage create(Ref ref) {
    return refreshTokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshTokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshTokenStorage>(value),
    );
  }
}

String _$refreshTokenStorageHash() =>
    r'4d3529c1d53f1f7df2c45a9a560a9c0c1c418258';
