// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database_wipe_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider dedicato per lo stesso motivo di [appDatabaseProvider]: un
/// confine di I/O reale (file su nativo, IndexedDB/OPFS sul web) che i
/// banchi di prova devono poter sostituire, non solo la base dati che
/// vi si appoggia.

@ProviderFor(deleteDatabaseFile)
final deleteDatabaseFileProvider = DeleteDatabaseFileProvider._();

/// Provider dedicato per lo stesso motivo di [appDatabaseProvider]: un
/// confine di I/O reale (file su nativo, IndexedDB/OPFS sul web) che i
/// banchi di prova devono poter sostituire, non solo la base dati che
/// vi si appoggia.

final class DeleteDatabaseFileProvider
    extends
        $FunctionalProvider<
          DeleteDatabaseFile,
          DeleteDatabaseFile,
          DeleteDatabaseFile
        >
    with $Provider<DeleteDatabaseFile> {
  /// Provider dedicato per lo stesso motivo di [appDatabaseProvider]: un
  /// confine di I/O reale (file su nativo, IndexedDB/OPFS sul web) che i
  /// banchi di prova devono poter sostituire, non solo la base dati che
  /// vi si appoggia.
  DeleteDatabaseFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteDatabaseFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteDatabaseFileHash();

  @$internal
  @override
  $ProviderElement<DeleteDatabaseFile> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteDatabaseFile create(Ref ref) {
    return deleteDatabaseFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteDatabaseFile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteDatabaseFile>(value),
    );
  }
}

String _$deleteDatabaseFileHash() =>
    r'a6d3ec224f1d7859240c17ebbe58743681c8f061';

@ProviderFor(localDatabaseWipeService)
final localDatabaseWipeServiceProvider = LocalDatabaseWipeServiceProvider._();

final class LocalDatabaseWipeServiceProvider
    extends
        $FunctionalProvider<
          LocalDatabaseWipeService,
          LocalDatabaseWipeService,
          LocalDatabaseWipeService
        >
    with $Provider<LocalDatabaseWipeService> {
  LocalDatabaseWipeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDatabaseWipeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDatabaseWipeServiceHash();

  @$internal
  @override
  $ProviderElement<LocalDatabaseWipeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalDatabaseWipeService create(Ref ref) {
    return localDatabaseWipeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDatabaseWipeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDatabaseWipeService>(value),
    );
  }
}

String _$localDatabaseWipeServiceHash() =>
    r'64a4301f7d7e295d5b2881db75b2d325d41d0e3b';
