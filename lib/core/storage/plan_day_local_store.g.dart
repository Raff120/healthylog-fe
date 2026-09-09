// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day_local_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planDayLocalStore)
final planDayLocalStoreProvider = PlanDayLocalStoreProvider._();

final class PlanDayLocalStoreProvider
    extends
        $FunctionalProvider<
          PlanDayLocalStore,
          PlanDayLocalStore,
          PlanDayLocalStore
        >
    with $Provider<PlanDayLocalStore> {
  PlanDayLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDayLocalStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDayLocalStoreHash();

  @$internal
  @override
  $ProviderElement<PlanDayLocalStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlanDayLocalStore create(Ref ref) {
    return planDayLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanDayLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanDayLocalStore>(value),
    );
  }
}

String _$planDayLocalStoreHash() => r'c9f9904d24dca9f6189be72b809be5d3d341bf6e';
