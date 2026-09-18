import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../statistics/providers/statistics_providers.dart';
import '../data/hydration_api.dart';
import '../data/hydration_models.dart';

part 'hydration_providers.g.dart';

@riverpod
HydrationApi hydrationApi(Ref ref) => HydrationApi(ref.watch(apiClientProvider));

/// AQ-16: la giornata di idratazione, per la vista giornaliera.
/// `family` per data, come `planDay` e `dayWorkouts`.
///
/// AQ-19, AQ-27: la giornata priva di registrazione non è restituita dal
/// server (EP-8) e vale qui la giornata a zero — è la condizione in cui i
/// comandi servono di più.
@riverpod
Future<WaterIntakeDay> waterIntakeDay(Ref ref, DateTime date) async {
  final days = await ref.watch(hydrationApiProvider).list(date, date);
  return days.isEmpty ? WaterIntakeDay.empty(date) : days.first;
}

/// AQ-28: le giornate dell'orizzonte con le rispettive aggiunte, per
/// l'elenco da cui si rettifica (11.1 interfaccia.md). Distinto da
/// [waterStatistics], che porta i totali e non le aggiunte.
@riverpod
Future<List<WaterIntakeDay>> waterIntakeDays(
  Ref ref,
  ({DateTime from, DateTime to}) range,
) =>
    ref.watch(hydrationApiProvider).list(range.from, range.to);

/// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.
@riverpod
class DailyWaterGoal extends _$DailyWaterGoal {
  @override
  Future<int?> build() => ref.read(hydrationApiProvider).getGoal();

  /// AQ-12: impostazione, modifica e rimozione ([valueMl] nullo, DS-20).
  Future<void> save(int? valueMl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(hydrationApiProvider).setGoal(valueMl));
    if (state.hasError) return;
    // AQ-16: il totale della giornata si presenta accanto all'obiettivo,
    // che è appena mutato.
    ref.invalidate(waterIntakeDayProvider);
  }
}

/// 8.6: consumo medio e andamento giornaliero dell'orizzonte. Il criterio
/// è quello comune alle statistiche, [userId] compreso — ammesso al solo
/// Nutrizionista sul proprio Paziente (AQ-31).
@riverpod
Future<WaterStatistics> waterStatistics(Ref ref, StatisticsQuery query) =>
    ref.watch(hydrationApiProvider).statistics(query.period,
        date: query.date, planId: query.planId, userId: query.userId);

/// AQ-5, AQ-7, AQ-8: aggiunta e annullamento. Ogni esito rinnova la
/// giornata e le statistiche per invalidazione, come i controller degli
/// allenamenti.
@riverpod
class WaterIntakeController extends _$WaterIntakeController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> add(DateTime date, int amountMl) =>
      _run(() => ref.read(hydrationApiProvider).add(date, amountMl));

  Future<void> removeEntry(DateTime date, String entryId) =>
      _run(() => ref.read(hydrationApiProvider).removeEntry(date, entryId));

  Future<void> _run(Future<void> Function() operation) async {
    // I comandi rapidi registrano senza attendere (AQ-5): nessun widget
    // osserva l'esito, e il controller sarebbe smaltito a richiesta
    // ancora in corso — con essa la lettura della giornata, che resterebbe
    // al totale precedente. Il collegamento lo tiene in vita fino alla
    // fine dell'operazione, non oltre.
    final link = ref.keepAlive();
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(operation);
      if (state?.hasError ?? true) return;
      ref.invalidate(waterIntakeDayProvider);
      ref.invalidate(waterIntakeDaysProvider);
      ref.invalidate(waterStatisticsProvider);
    } finally {
      link.close();
    }
  }
}
