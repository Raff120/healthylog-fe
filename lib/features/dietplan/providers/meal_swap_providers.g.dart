// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_swap_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mealSwapApi)
final mealSwapApiProvider = MealSwapApiProvider._();

final class MealSwapApiProvider
    extends $FunctionalProvider<MealSwapApi, MealSwapApi, MealSwapApi>
    with $Provider<MealSwapApi> {
  MealSwapApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealSwapApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealSwapApiHash();

  @$internal
  @override
  $ProviderElement<MealSwapApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MealSwapApi create(Ref ref) {
    return mealSwapApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealSwapApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealSwapApi>(value),
    );
  }
}

String _$mealSwapApiHash() => r'5c9cb93d79ab543772aed27b97319b9318d9890f';

/// Se non `null`, la vista settimanale è in modalità di selezione (6.5
/// interfaccia.md).

@ProviderFor(MealSwapSelection)
final mealSwapSelectionProvider = MealSwapSelectionProvider._();

/// Se non `null`, la vista settimanale è in modalità di selezione (6.5
/// interfaccia.md).
final class MealSwapSelectionProvider
    extends $NotifierProvider<MealSwapSelection, MealSwapOrigin?> {
  /// Se non `null`, la vista settimanale è in modalità di selezione (6.5
  /// interfaccia.md).
  MealSwapSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealSwapSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealSwapSelectionHash();

  @$internal
  @override
  MealSwapSelection create() => MealSwapSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealSwapOrigin? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealSwapOrigin?>(value),
    );
  }
}

String _$mealSwapSelectionHash() => r'cd8c8972dd14f0e593b2201c60922394d0668d1e';

/// Se non `null`, la vista settimanale è in modalità di selezione (6.5
/// interfaccia.md).

abstract class _$MealSwapSelection extends $Notifier<MealSwapOrigin?> {
  MealSwapOrigin? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MealSwapOrigin?, MealSwapOrigin?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MealSwapOrigin?, MealSwapOrigin?>,
              MealSwapOrigin?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
/// all'esito: la giornata aggiornata si ottiene invalidando la cache di
/// [planDayRangeProvider], sullo stesso criterio di
/// [PlanDaySlotStatusController].

@ProviderFor(MealSwapController)
final mealSwapControllerProvider = MealSwapControllerProvider._();

/// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
/// all'esito: la giornata aggiornata si ottiene invalidando la cache di
/// [planDayRangeProvider], sullo stesso criterio di
/// [PlanDaySlotStatusController].
final class MealSwapControllerProvider
    extends $NotifierProvider<MealSwapController, AsyncValue<void>?> {
  /// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
  /// all'esito: la giornata aggiornata si ottiene invalidando la cache di
  /// [planDayRangeProvider], sullo stesso criterio di
  /// [PlanDaySlotStatusController].
  MealSwapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealSwapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealSwapControllerHash();

  @$internal
  @override
  MealSwapController create() => MealSwapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$mealSwapControllerHash() =>
    r'99f2f763a37200133f482061084910ba062ec7ba';

/// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
/// all'esito: la giornata aggiornata si ottiene invalidando la cache di
/// [planDayRangeProvider], sullo stesso criterio di
/// [PlanDaySlotStatusController].

abstract class _$MealSwapController extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
