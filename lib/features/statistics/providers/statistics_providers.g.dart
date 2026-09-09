// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statisticsApi)
final statisticsApiProvider = StatisticsApiProvider._();

final class StatisticsApiProvider
    extends $FunctionalProvider<StatisticsApi, StatisticsApi, StatisticsApi>
    with $Provider<StatisticsApi> {
  StatisticsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsApiHash();

  @$internal
  @override
  $ProviderElement<StatisticsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatisticsApi create(Ref ref) {
    return statisticsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsApi>(value),
    );
  }
}

String _$statisticsApiHash() => r'e727de6bc20ae18098bfbb81ba3c58a6e9791740';

@ProviderFor(SelectedStatisticsView)
final selectedStatisticsViewProvider = SelectedStatisticsViewProvider._();

final class SelectedStatisticsViewProvider
    extends $NotifierProvider<SelectedStatisticsView, StatisticsViewMode> {
  SelectedStatisticsViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedStatisticsViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedStatisticsViewHash();

  @$internal
  @override
  SelectedStatisticsView create() => SelectedStatisticsView();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsViewMode>(value),
    );
  }
}

String _$selectedStatisticsViewHash() =>
    r'92439247352eee36fdff2944af1cc770f75a9da5';

abstract class _$SelectedStatisticsView extends $Notifier<StatisticsViewMode> {
  StatisticsViewMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StatisticsViewMode, StatisticsViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatisticsViewMode, StatisticsViewMode>,
              StatisticsViewMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 11.1: il selettore del periodo è comune ai tre segmenti ed è
/// conservato tra le sessioni (3.2), come la preferenza del tema.

@ProviderFor(SelectedStatisticsPeriod)
final selectedStatisticsPeriodProvider = SelectedStatisticsPeriodProvider._();

/// 11.1: il selettore del periodo è comune ai tre segmenti ed è
/// conservato tra le sessioni (3.2), come la preferenza del tema.
final class SelectedStatisticsPeriodProvider
    extends $AsyncNotifierProvider<SelectedStatisticsPeriod, StatisticsPeriod> {
  /// 11.1: il selettore del periodo è comune ai tre segmenti ed è
  /// conservato tra le sessioni (3.2), come la preferenza del tema.
  SelectedStatisticsPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedStatisticsPeriodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedStatisticsPeriodHash();

  @$internal
  @override
  SelectedStatisticsPeriod create() => SelectedStatisticsPeriod();
}

String _$selectedStatisticsPeriodHash() =>
    r'ead8b28bdb5ed06ca28eb1b83b40d6b592abcf59';

/// 11.1: il selettore del periodo è comune ai tre segmenti ed è
/// conservato tra le sessioni (3.2), come la preferenza del tema.

abstract class _$SelectedStatisticsPeriod
    extends $AsyncNotifier<StatisticsPeriod> {
  FutureOr<StatisticsPeriod> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StatisticsPeriod>, StatisticsPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatisticsPeriod>, StatisticsPeriod>,
              AsyncValue<StatisticsPeriod>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Il piano su cui riferire l'orizzonte *Piano*: quello indicato dal
/// dettaglio di un piano concluso (7.5), altrimenti assente — e il
/// backend intende allora quello in corso (PA-8).

@ProviderFor(SelectedStatisticsPlan)
final selectedStatisticsPlanProvider = SelectedStatisticsPlanProvider._();

/// Il piano su cui riferire l'orizzonte *Piano*: quello indicato dal
/// dettaglio di un piano concluso (7.5), altrimenti assente — e il
/// backend intende allora quello in corso (PA-8).
final class SelectedStatisticsPlanProvider
    extends $NotifierProvider<SelectedStatisticsPlan, String?> {
  /// Il piano su cui riferire l'orizzonte *Piano*: quello indicato dal
  /// dettaglio di un piano concluso (7.5), altrimenti assente — e il
  /// backend intende allora quello in corso (PA-8).
  SelectedStatisticsPlanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedStatisticsPlanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedStatisticsPlanHash();

  @$internal
  @override
  SelectedStatisticsPlan create() => SelectedStatisticsPlan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedStatisticsPlanHash() =>
    r'a0e4d35e2ceaadccb37ff2d59b93d07480437767';

/// Il piano su cui riferire l'orizzonte *Piano*: quello indicato dal
/// dettaglio di un piano concluso (7.5), altrimenti assente — e il
/// backend intende allora quello in corso (PA-8).

abstract class _$SelectedStatisticsPlan extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 8.2: l'aderenza dell'orizzonte richiesto.

@ProviderFor(adherenceStatistics)
final adherenceStatisticsProvider = AdherenceStatisticsFamily._();

/// 8.2: l'aderenza dell'orizzonte richiesto.

final class AdherenceStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdherenceStatistics>,
          AdherenceStatistics,
          FutureOr<AdherenceStatistics>
        >
    with
        $FutureModifier<AdherenceStatistics>,
        $FutureProvider<AdherenceStatistics> {
  /// 8.2: l'aderenza dell'orizzonte richiesto.
  AdherenceStatisticsProvider._({
    required AdherenceStatisticsFamily super.from,
    required StatisticsQuery super.argument,
  }) : super(
         retry: null,
         name: r'adherenceStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adherenceStatisticsHash();

  @override
  String toString() {
    return r'adherenceStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdherenceStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdherenceStatistics> create(Ref ref) {
    final argument = this.argument as StatisticsQuery;
    return adherenceStatistics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdherenceStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adherenceStatisticsHash() =>
    r'73d253f26799187d622bca7fd6cc843436284c75';

/// 8.2: l'aderenza dell'orizzonte richiesto.

final class AdherenceStatisticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AdherenceStatistics>,
          StatisticsQuery
        > {
  AdherenceStatisticsFamily._()
    : super(
        retry: null,
        name: r'adherenceStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 8.2: l'aderenza dell'orizzonte richiesto.

  AdherenceStatisticsProvider call(StatisticsQuery query) =>
      AdherenceStatisticsProvider._(argument: query, from: this);

  @override
  String toString() => r'adherenceStatisticsProvider';
}

/// 8.3: frequenza degli allenamenti e confronti.

@ProviderFor(workoutStatistics)
final workoutStatisticsProvider = WorkoutStatisticsFamily._();

/// 8.3: frequenza degli allenamenti e confronti.

final class WorkoutStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutStatistics>,
          WorkoutStatistics,
          FutureOr<WorkoutStatistics>
        >
    with
        $FutureModifier<WorkoutStatistics>,
        $FutureProvider<WorkoutStatistics> {
  /// 8.3: frequenza degli allenamenti e confronti.
  WorkoutStatisticsProvider._({
    required WorkoutStatisticsFamily super.from,
    required StatisticsQuery super.argument,
  }) : super(
         retry: null,
         name: r'workoutStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutStatisticsHash();

  @override
  String toString() {
    return r'workoutStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutStatistics> create(Ref ref) {
    final argument = this.argument as StatisticsQuery;
    return workoutStatistics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutStatisticsHash() => r'77130193301f2184a4fe1c8ac4ac3a80b48f4362';

/// 8.3: frequenza degli allenamenti e confronti.

final class WorkoutStatisticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<WorkoutStatistics>,
          StatisticsQuery
        > {
  WorkoutStatisticsFamily._()
    : super(
        retry: null,
        name: r'workoutStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 8.3: frequenza degli allenamenti e confronti.

  WorkoutStatisticsProvider call(StatisticsQuery query) =>
      WorkoutStatisticsProvider._(argument: query, from: this);

  @override
  String toString() => r'workoutStatisticsProvider';
}

/// 8.4: andamento di peso e misure.

@ProviderFor(measurementStatistics)
final measurementStatisticsProvider = MeasurementStatisticsFamily._();

/// 8.4: andamento di peso e misure.

final class MeasurementStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MeasurementStatistics>,
          MeasurementStatistics,
          FutureOr<MeasurementStatistics>
        >
    with
        $FutureModifier<MeasurementStatistics>,
        $FutureProvider<MeasurementStatistics> {
  /// 8.4: andamento di peso e misure.
  MeasurementStatisticsProvider._({
    required MeasurementStatisticsFamily super.from,
    required StatisticsQuery super.argument,
  }) : super(
         retry: null,
         name: r'measurementStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementStatisticsHash();

  @override
  String toString() {
    return r'measurementStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MeasurementStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MeasurementStatistics> create(Ref ref) {
    final argument = this.argument as StatisticsQuery;
    return measurementStatistics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementStatisticsHash() =>
    r'bb56666450722cd5efff0a1c3efe5dd158e6b37b';

/// 8.4: andamento di peso e misure.

final class MeasurementStatisticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<MeasurementStatistics>,
          StatisticsQuery
        > {
  MeasurementStatisticsFamily._()
    : super(
        retry: null,
        name: r'measurementStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 8.4: andamento di peso e misure.

  MeasurementStatisticsProvider call(StatisticsQuery query) =>
      MeasurementStatisticsProvider._(argument: query, from: this);

  @override
  String toString() => r'measurementStatisticsProvider';
}

/// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
/// al grafico — la medesima struttura di 10.3. Distinto da
/// `measurements`, che non è circoscritto a un intervallo.

@ProviderFor(periodMeasurements)
final periodMeasurementsProvider = PeriodMeasurementsFamily._();

/// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
/// al grafico — la medesima struttura di 10.3. Distinto da
/// `measurements`, che non è circoscritto a un intervallo.

final class PeriodMeasurementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BodyMeasurement>>,
          List<BodyMeasurement>,
          FutureOr<List<BodyMeasurement>>
        >
    with
        $FutureModifier<List<BodyMeasurement>>,
        $FutureProvider<List<BodyMeasurement>> {
  /// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
  /// al grafico — la medesima struttura di 10.3. Distinto da
  /// `measurements`, che non è circoscritto a un intervallo.
  PeriodMeasurementsProvider._({
    required PeriodMeasurementsFamily super.from,
    required ({DateTime from, DateTime to}) super.argument,
  }) : super(
         retry: null,
         name: r'periodMeasurementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$periodMeasurementsHash();

  @override
  String toString() {
    return r'periodMeasurementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BodyMeasurement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BodyMeasurement>> create(Ref ref) {
    final argument = this.argument as ({DateTime from, DateTime to});
    return periodMeasurements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodMeasurementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$periodMeasurementsHash() =>
    r'42faa3ac404349dcdcab84c5de3d9d5cf689ae92';

/// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
/// al grafico — la medesima struttura di 10.3. Distinto da
/// `measurements`, che non è circoscritto a un intervallo.

final class PeriodMeasurementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BodyMeasurement>>,
          ({DateTime from, DateTime to})
        > {
  PeriodMeasurementsFamily._()
    : super(
        retry: null,
        name: r'periodMeasurementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
  /// al grafico — la medesima struttura di 10.3. Distinto da
  /// `measurements`, che non è circoscritto a un intervallo.

  PeriodMeasurementsProvider call(({DateTime from, DateTime to}) range) =>
      PeriodMeasurementsProvider._(argument: range, from: this);

  @override
  String toString() => r'periodMeasurementsProvider';
}

/// 11.3: la grandezza corporea selezionata nel segmento *Corpo* (AN-1).
/// Il grafico ne presenta una per volta; il selettore propone le sole
/// misure con registrazioni nel periodo (AN-2).

@ProviderFor(SelectedBodyMeasure)
final selectedBodyMeasureProvider = SelectedBodyMeasureProvider._();

/// 11.3: la grandezza corporea selezionata nel segmento *Corpo* (AN-1).
/// Il grafico ne presenta una per volta; il selettore propone le sole
/// misure con registrazioni nel periodo (AN-2).
final class SelectedBodyMeasureProvider
    extends $NotifierProvider<SelectedBodyMeasure, BodyMeasure?> {
  /// 11.3: la grandezza corporea selezionata nel segmento *Corpo* (AN-1).
  /// Il grafico ne presenta una per volta; il selettore propone le sole
  /// misure con registrazioni nel periodo (AN-2).
  SelectedBodyMeasureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBodyMeasureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBodyMeasureHash();

  @$internal
  @override
  SelectedBodyMeasure create() => SelectedBodyMeasure();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyMeasure? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyMeasure?>(value),
    );
  }
}

String _$selectedBodyMeasureHash() =>
    r'4bc8c0a62da561241f2ea3ff8225c7baf8181056';

/// 11.3: la grandezza corporea selezionata nel segmento *Corpo* (AN-1).
/// Il grafico ne presenta una per volta; il selettore propone le sole
/// misure con registrazioni nel periodo (AN-2).

abstract class _$SelectedBodyMeasure extends $Notifier<BodyMeasure?> {
  BodyMeasure? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BodyMeasure?, BodyMeasure?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BodyMeasure?, BodyMeasure?>,
              BodyMeasure?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 11.1, ST-10: sul piano con più periodi di svolgimento, l'alternanza fra
/// il calcolo complessivo e quello per singolo periodo. I due dati non
/// sono omogenei e la loro somma indistinta occulterebbe l'andamento.

@ProviderFor(SelectedAdherencePeriodIndex)
final selectedAdherencePeriodIndexProvider =
    SelectedAdherencePeriodIndexProvider._();

/// 11.1, ST-10: sul piano con più periodi di svolgimento, l'alternanza fra
/// il calcolo complessivo e quello per singolo periodo. I due dati non
/// sono omogenei e la loro somma indistinta occulterebbe l'andamento.
final class SelectedAdherencePeriodIndexProvider
    extends $NotifierProvider<SelectedAdherencePeriodIndex, int?> {
  /// 11.1, ST-10: sul piano con più periodi di svolgimento, l'alternanza fra
  /// il calcolo complessivo e quello per singolo periodo. I due dati non
  /// sono omogenei e la loro somma indistinta occulterebbe l'andamento.
  SelectedAdherencePeriodIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAdherencePeriodIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAdherencePeriodIndexHash();

  @$internal
  @override
  SelectedAdherencePeriodIndex create() => SelectedAdherencePeriodIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedAdherencePeriodIndexHash() =>
    r'015915ffeff43859502fa892576cb4a268a2401e';

/// 11.1, ST-10: sul piano con più periodi di svolgimento, l'alternanza fra
/// il calcolo complessivo e quello per singolo periodo. I due dati non
/// sono omogenei e la loro somma indistinta occulterebbe l'andamento.

abstract class _$SelectedAdherencePeriodIndex extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
