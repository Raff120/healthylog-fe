// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_local_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dietPlanLocalStore)
final dietPlanLocalStoreProvider = DietPlanLocalStoreProvider._();

final class DietPlanLocalStoreProvider
    extends
        $FunctionalProvider<
          DietPlanLocalStore,
          DietPlanLocalStore,
          DietPlanLocalStore
        >
    with $Provider<DietPlanLocalStore> {
  DietPlanLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dietPlanLocalStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dietPlanLocalStoreHash();

  @$internal
  @override
  $ProviderElement<DietPlanLocalStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DietPlanLocalStore create(Ref ref) {
    return dietPlanLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DietPlanLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DietPlanLocalStore>(value),
    );
  }
}

String _$dietPlanLocalStoreHash() =>
    r'11718c614a29064c328e112ec1667e3115b6194d';
