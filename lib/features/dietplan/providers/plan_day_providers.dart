import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/plan_day_local_store.dart';
import '../data/plan_day.dart';
import '../data/plan_day_api.dart';
import '../data/plan_day_local_cache.dart';
import '../data/slot_status.dart';
import '../domain/plan_day_date.dart';

part 'plan_day_providers.g.dart';

@riverpod
PlanDayApi planDayApi(Ref ref) => PlanDayApi(ref.watch(apiClientProvider));

@riverpod
PlanDayLocalCache planDayLocalCache(Ref ref) =>
    PlanDayLocalCache(ref.watch(planDayLocalStoreProvider));

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime date) => state = dateOnly(date);
}

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.
@riverpod
Future<PlanDay> planDay(Ref ref, DateTime date) async {
  final cache = ref.watch(planDayLocalCacheProvider);
  try {
    final day = await ref.watch(planDayApiProvider).getDay(date);
    await cache.save(day);
    return day;
  } on DioException catch (error) {
    if (error.asApiException?.code != 'NETWORK_ERROR') rethrow;
    final cached = await cache.read(date);
    if (cached == null) rethrow;
    return cached;
  }
}

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
@riverpod
class PlanDaySlotStatusController extends _$PlanDaySlotStatusController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> updateStatus(
    DateTime date,
    String slotId,
    SlotStatus status,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(planDayApiProvider).updateSlotStatus(date, slotId, status),
    );
    ref.invalidate(planDayProvider(date));
  }
}
