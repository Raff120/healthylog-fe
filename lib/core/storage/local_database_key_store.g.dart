// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database_key_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localDatabaseKeyStore)
final localDatabaseKeyStoreProvider = LocalDatabaseKeyStoreProvider._();

final class LocalDatabaseKeyStoreProvider
    extends
        $FunctionalProvider<
          LocalDatabaseKeyStore,
          LocalDatabaseKeyStore,
          LocalDatabaseKeyStore
        >
    with $Provider<LocalDatabaseKeyStore> {
  LocalDatabaseKeyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDatabaseKeyStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDatabaseKeyStoreHash();

  @$internal
  @override
  $ProviderElement<LocalDatabaseKeyStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalDatabaseKeyStore create(Ref ref) {
    return localDatabaseKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDatabaseKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDatabaseKeyStore>(value),
    );
  }
}

String _$localDatabaseKeyStoreHash() =>
    r'a41e4314b941d05fa820a9636bdea511d01f78be';
