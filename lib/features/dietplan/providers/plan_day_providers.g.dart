// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_day_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planDayApi)
final planDayApiProvider = PlanDayApiProvider._();

final class PlanDayApiProvider
    extends $FunctionalProvider<PlanDayApi, PlanDayApi, PlanDayApi>
    with $Provider<PlanDayApi> {
  PlanDayApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDayApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDayApiHash();

  @$internal
  @override
  $ProviderElement<PlanDayApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanDayApi create(Ref ref) {
    return planDayApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanDayApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanDayApi>(value),
    );
  }
}

String _$planDayApiHash() => r'6939ecb8c3fca2f9e6ec355ff49592abad02da0a';

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.

@ProviderFor(SelectedDay)
final selectedDayProvider = SelectedDayProvider._();

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
final class SelectedDayProvider
    extends $NotifierProvider<SelectedDay, DateTime> {
  /// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
  /// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
  /// a oggi (VG-19) sono task successivi, sullo stesso stato.
  SelectedDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDayHash();

  @$internal
  @override
  SelectedDay create() => SelectedDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDayHash() => r'889586dee26fe79298721e46dfb08bc5c8691310';

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.

abstract class _$SelectedDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.

@ProviderFor(planDay)
final planDayProvider = PlanDayFamily._();

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.

final class PlanDayProvider
    extends $FunctionalProvider<AsyncValue<PlanDay>, PlanDay, FutureOr<PlanDay>>
    with $FutureModifier<PlanDay>, $FutureProvider<PlanDay> {
  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data: ogni giorno visitato ha una propria
  /// cache, così tornare a un giorno già consultato non richiede una nuova
  /// richiesta.
  PlanDayProvider._({
    required PlanDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'planDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planDayHash();

  @override
  String toString() {
    return r'planDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlanDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlanDay> create(Ref ref) {
    final argument = this.argument as DateTime;
    return planDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planDayHash() => r'dc74d77c4d2ebff7fc5aa0a6a4ba2a058c49e575';

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.

final class PlanDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlanDay>, DateTime> {
  PlanDayFamily._()
    : super(
        retry: null,
        name: r'planDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
  /// sola lettura). `family` per data: ogni giorno visitato ha una propria
  /// cache, così tornare a un giorno già consultato non richiede una nuova
  /// richiesta.

  PlanDayProvider call(DateTime date) =>
      PlanDayProvider._(argument: date, from: this);

  @override
  String toString() => r'planDayProvider';
}

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.

@ProviderFor(PlanDaySlotStatusController)
final planDaySlotStatusControllerProvider =
    PlanDaySlotStatusControllerProvider._();

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
final class PlanDaySlotStatusControllerProvider
    extends $NotifierProvider<PlanDaySlotStatusController, AsyncValue<void>?> {
  /// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
  /// disposta dalla card del pasto. Nessuno stato locale da esporre: la
  /// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
  /// sullo stesso criterio già seguito da `DietPlanLifecycleController`
  /// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
  PlanDaySlotStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDaySlotStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDaySlotStatusControllerHash();

  @$internal
  @override
  PlanDaySlotStatusController create() => PlanDaySlotStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$planDaySlotStatusControllerHash() =>
    r'ac8820d68aab42c31efadde1a47446d9d5381b0f';

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.

abstract class _$PlanDaySlotStatusController
    extends $Notifier<AsyncValue<void>?> {
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
