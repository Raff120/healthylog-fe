import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/preferences_store.dart';
import '../../measurement/data/measurement_models.dart';
import '../../measurement/providers/measurement_providers.dart';
import '../data/statistics_api.dart';
import '../data/statistics_models.dart';

part 'statistics_providers.g.dart';

const _periodKey = 'statistics_period';

@riverpod
StatisticsApi statisticsApi(Ref ref) => StatisticsApi(ref.watch(apiClientProvider));

/// I tre segmenti di *Statistiche* (11.1 interfaccia.md): aderenza,
/// allenamenti e andamento corporeo.
enum StatisticsViewMode { adherence, workouts, body }

@riverpod
class SelectedStatisticsView extends _$SelectedStatisticsView {
  @override
  StatisticsViewMode build() => StatisticsViewMode.adherence;

  void select(StatisticsViewMode mode) => state = mode;
}

/// 11.1: il selettore del periodo è comune ai tre segmenti ed è
/// conservato tra le sessioni (3.2), come la preferenza del tema.
@riverpod
class SelectedStatisticsPeriod extends _$SelectedStatisticsPeriod {
  @override
  Future<StatisticsPeriod> build() async {
    final stored = await ref.watch(preferencesStoreProvider).read(_periodKey);
    return stored == null ? StatisticsPeriod.week : StatisticsPeriod.fromParam(stored);
  }

  Future<void> select(StatisticsPeriod period) async {
    state = AsyncValue.data(period);
    await ref.read(preferencesStoreProvider).write(_periodKey, period.param);
  }
}

/// Il piano su cui riferire l'orizzonte *Piano*: quello indicato dal
/// dettaglio di un piano concluso (7.5), altrimenti assente — e il
/// backend intende allora quello in corso (PA-8).
@riverpod
class SelectedStatisticsPlan extends _$SelectedStatisticsPlan {
  @override
  String? build() => null;

  void select(String? planId) => state = planId;
}

/// Criterio di una richiesta di statistiche: orizzonte, piano e soggetto.
/// [userId] è ammesso al solo Nutrizionista sul proprio Paziente (EP-4,
/// ST-16bis).
class StatisticsQuery {
  const StatisticsQuery({required this.period, this.planId, this.userId});

  final StatisticsPeriod period;
  final String? planId;
  final String? userId;

  @override
  bool operator ==(Object other) =>
      other is StatisticsQuery &&
      other.period == period &&
      other.planId == planId &&
      other.userId == userId;

  @override
  int get hashCode => Object.hash(period, planId, userId);
}

/// 8.2: l'aderenza dell'orizzonte richiesto.
@riverpod
Future<AdherenceStatistics> adherenceStatistics(Ref ref, StatisticsQuery query) =>
    ref.watch(statisticsApiProvider).adherence(query.period, planId: query.planId, userId: query.userId);

/// 8.3: frequenza degli allenamenti e confronti.
@riverpod
Future<WorkoutStatistics> workoutStatistics(Ref ref, StatisticsQuery query) =>
    ref.watch(statisticsApiProvider).workouts(query.period, planId: query.planId, userId: query.userId);

/// 8.4: andamento di peso e misure.
@riverpod
Future<MeasurementStatistics> measurementStatistics(Ref ref, StatisticsQuery query) =>
    ref.watch(statisticsApiProvider).measurements(query.period, planId: query.planId, userId: query.userId);

/// AN-4, 11.3: l'elenco tabellare delle misurazioni del periodo, in coda
/// al grafico — la medesima struttura di 10.3. Distinto da
/// `measurements`, che non è circoscritto a un intervallo.
@riverpod
Future<List<BodyMeasurement>> periodMeasurements(
  Ref ref,
  ({DateTime from, DateTime to}) range,
) =>
    ref.watch(measurementApiProvider).list(from: range.from, to: range.to);

/// 11.3: la grandezza corporea selezionata nel segmento *Corpo* (AN-1).
/// Il grafico ne presenta una per volta; il selettore propone le sole
/// misure con registrazioni nel periodo (AN-2).
@riverpod
class SelectedBodyMeasure extends _$SelectedBodyMeasure {
  @override
  BodyMeasure? build() => null;

  void select(BodyMeasure measure) => state = measure;
}

/// 11.1, ST-10: sul piano con più periodi di svolgimento, l'alternanza fra
/// il calcolo complessivo e quello per singolo periodo. I due dati non
/// sono omogenei e la loro somma indistinta occulterebbe l'andamento.
@riverpod
class SelectedAdherencePeriodIndex extends _$SelectedAdherencePeriodIndex {
  /// `null` è il calcolo complessivo.
  @override
  int? build() => null;

  void select(int? index) => state = index;
}
