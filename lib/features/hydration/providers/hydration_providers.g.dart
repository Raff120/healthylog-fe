// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hydrationApi)
final hydrationApiProvider = HydrationApiProvider._();

final class HydrationApiProvider
    extends $FunctionalProvider<HydrationApi, HydrationApi, HydrationApi>
    with $Provider<HydrationApi> {
  HydrationApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydrationApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydrationApiHash();

  @$internal
  @override
  $ProviderElement<HydrationApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HydrationApi create(Ref ref) {
    return hydrationApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydrationApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydrationApi>(value),
    );
  }
}

String _$hydrationApiHash() => r'eefcb7571c486a16d05cbdb4ab082cc3cc31998f';

/// AQ-16: la giornata di idratazione, per la vista giornaliera.
/// `family` per data, come `planDay` e `dayWorkouts`.
///
/// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
/// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
/// comandi servono di più.

@ProviderFor(waterIntakeDay)
final waterIntakeDayProvider = WaterIntakeDayFamily._();

/// AQ-16: la giornata di idratazione, per la vista giornaliera.
/// `family` per data, come `planDay` e `dayWorkouts`.
///
/// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
/// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
/// comandi servono di più.

final class WaterIntakeDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<WaterIntakeDay>,
          WaterIntakeDay,
          FutureOr<WaterIntakeDay>
        >
    with $FutureModifier<WaterIntakeDay>, $FutureProvider<WaterIntakeDay> {
  /// AQ-16: la giornata di idratazione, per la vista giornaliera.
  /// `family` per data, come `planDay` e `dayWorkouts`.
  ///
  /// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
  /// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
  /// comandi servono di più.
  WaterIntakeDayProvider._({
    required WaterIntakeDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'waterIntakeDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$waterIntakeDayHash();

  @override
  String toString() {
    return r'waterIntakeDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WaterIntakeDay> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WaterIntakeDay> create(Ref ref) {
    final argument = this.argument as DateTime;
    return waterIntakeDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WaterIntakeDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$waterIntakeDayHash() => r'725c7c40c6230997663e54d72c5d75e0b39893d8';

/// AQ-16: la giornata di idratazione, per la vista giornaliera.
/// `family` per data, come `planDay` e `dayWorkouts`.
///
/// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
/// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
/// comandi servono di più.

final class WaterIntakeDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WaterIntakeDay>, DateTime> {
  WaterIntakeDayFamily._()
    : super(
        retry: null,
        name: r'waterIntakeDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AQ-16: la giornata di idratazione, per la vista giornaliera.
  /// `family` per data, come `planDay` e `dayWorkouts`.
  ///
  /// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
  /// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
  /// comandi servono di più.

  WaterIntakeDayProvider call(DateTime date) =>
      WaterIntakeDayProvider._(argument: date, from: this);

  @override
  String toString() => r'waterIntakeDayProvider';
}

/// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.

@ProviderFor(DailyWaterGoal)
final dailyWaterGoalProvider = DailyWaterGoalProvider._();

/// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.
final class DailyWaterGoalProvider
    extends $AsyncNotifierProvider<DailyWaterGoal, int?> {
  /// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.
  DailyWaterGoalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyWaterGoalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyWaterGoalHash();

  @$internal
  @override
  DailyWaterGoal create() => DailyWaterGoal();
}

String _$dailyWaterGoalHash() => r'a67a52e50d15f3b35dd23a02d5e2137655813671';

/// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.

abstract class _$DailyWaterGoal extends $AsyncNotifier<int?> {
  FutureOr<int?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int?>, int?>,
              AsyncValue<int?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
/// è quello comune alle statistiche, [userId] compreso — ammesso al solo
/// Nutrizionista sul proprio Paziente (AQ-31).

@ProviderFor(waterStatistics)
final waterStatisticsProvider = WaterStatisticsFamily._();

/// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
/// è quello comune alle statistiche, [userId] compreso — ammesso al solo
/// Nutrizionista sul proprio Paziente (AQ-31).

final class WaterStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<WaterStatistics>,
          WaterStatistics,
          FutureOr<WaterStatistics>
        >
    with $FutureModifier<WaterStatistics>, $FutureProvider<WaterStatistics> {
  /// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
  /// è quello comune alle statistiche, [userId] compreso — ammesso al solo
  /// Nutrizionista sul proprio Paziente (AQ-31).
  WaterStatisticsProvider._({
    required WaterStatisticsFamily super.from,
    required StatisticsQuery super.argument,
  }) : super(
         retry: null,
         name: r'waterStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$waterStatisticsHash();

  @override
  String toString() {
    return r'waterStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WaterStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WaterStatistics> create(Ref ref) {
    final argument = this.argument as StatisticsQuery;
    return waterStatistics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WaterStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$waterStatisticsHash() => r'57a991cb4af77b0c10bb9d5144880daed79b2672';

/// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
/// è quello comune alle statistiche, [userId] compreso — ammesso al solo
/// Nutrizionista sul proprio Paziente (AQ-31).

final class WaterStatisticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WaterStatistics>, StatisticsQuery> {
  WaterStatisticsFamily._()
    : super(
        retry: null,
        name: r'waterStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
  /// è quello comune alle statistiche, [userId] compreso — ammesso al solo
  /// Nutrizionista sul proprio Paziente (AQ-31).

  WaterStatisticsProvider call(StatisticsQuery query) =>
      WaterStatisticsProvider._(argument: query, from: this);

  @override
  String toString() => r'waterStatisticsProvider';
}

/// AQ-5, AQ-7, AQ-8: aggiunta e annullamento. Ogni esito rinnova la
/// giornata e le statistiche per invalidazione, come i controller degli
/// allenamenti.

@ProviderFor(WaterIntakeController)
final waterIntakeControllerProvider = WaterIntakeControllerProvider._();

/// AQ-5, AQ-7, AQ-8: aggiunta e annullamento. Ogni esito rinnova la
/// giornata e le statistiche per invalidazione, come i controller degli
/// allenamenti.
final class WaterIntakeControllerProvider
    extends $NotifierProvider<WaterIntakeController, AsyncValue<void>?> {
  /// AQ-5, AQ-7, AQ-8: aggiunta e annullamento. Ogni esito rinnova la
  /// giornata e le statistiche per invalidazione, come i controller degli
  /// allenamenti.
  WaterIntakeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'waterIntakeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waterIntakeControllerHash();

  @$internal
  @override
  WaterIntakeController create() => WaterIntakeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$waterIntakeControllerHash() =>
    r'78469f57e8f865a597669d2290f69e7575922264';

/// AQ-5, AQ-7, AQ-8: aggiunta e annullamento. Ogni esito rinnova la
/// giornata e le statistiche per invalidazione, come i controller degli
/// allenamenti.

abstract class _$WaterIntakeController extends $Notifier<AsyncValue<void>?> {
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
