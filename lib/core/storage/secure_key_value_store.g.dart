// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_key_value_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureKeyValueStore)
final secureKeyValueStoreProvider = SecureKeyValueStoreProvider._();

final class SecureKeyValueStoreProvider
    extends
        $FunctionalProvider<
          SecureKeyValueStore,
          SecureKeyValueStore,
          SecureKeyValueStore
        >
    with $Provider<SecureKeyValueStore> {
  SecureKeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureKeyValueStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureKeyValueStoreHash();

  @$internal
  @override
  $ProviderElement<SecureKeyValueStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureKeyValueStore create(Ref ref) {
    return secureKeyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureKeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureKeyValueStore>(value),
    );
  }
}

String _$secureKeyValueStoreHash() =>
    r'1ee7252662efc740b2dd39830b52043571775499';
