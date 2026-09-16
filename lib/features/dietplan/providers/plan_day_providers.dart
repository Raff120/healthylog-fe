import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/plan_day_local_store.dart';
import '../../group/providers/cooking_group_providers.dart';
import '../../identity/providers/profile_providers.dart';
import '../data/group_plan_day.dart';
import '../data/plan_day.dart';
import '../data/diet_plan_requests.dart';
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
///
/// VS-14: è anche il riferimento temporale condiviso con la vista
/// settimanale, che ne deriva la settimana da mostrare
/// (`startOfWeek`) — un solo stato "che giorno stiamo guardando",
/// invece di uno per vista, così passare dall'una all'altra conserva il
/// riferimento senza alcun sincronismo esplicito.
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime date) => state = dateOnly(date);
}

/// Le due granularità di *Piano* (6.1 interfaccia.md). Il segmented
/// control ne è l'unico comando.
enum PlanViewMode { day, week }

@riverpod
class SelectedPlanView extends _$SelectedPlanView {
  @override
  PlanViewMode build() => PlanViewMode.day;

  void select(PlanViewMode mode) => state = mode;
}

/// VG-7, VG-11: il membro del Gruppo di cui si consulta la giornata,
/// `null` per il proprio piano — il selettore dell'intestazione (4.2
/// interfaccia.md) è l'unico comando. Condiviso fra vista giornaliera e
/// settimanale, sullo stesso criterio di [SelectedDay].
@riverpod
class SelectedGroupMember extends _$SelectedGroupMember {
  @override
  String? build() => null;

  void select(String? userId) => state = userId;
}

/// VG-12: la modalità affiancata, indipendente da [SelectedGroupMember]
/// — disattivandola si torna esattamente al membro che era selezionato
/// prima (4.2 interfaccia.md: "il ritorno al membro singolo ripristina
/// l'ultimo selezionato"), senza alcuno stato aggiuntivo: la selezione
/// del singolo membro non viene mai toccata da questo notifier.
@riverpod
class SideBySideMode extends _$SideBySideMode {
  @override
  bool build() => false;

  /// VS-16: la modalità affiancata non è disponibile nella vista
  /// settimanale — l'attivazione forza il passaggio a quella
  /// giornaliera.
  void toggle() {
    state = !state;
    if (state) {
      ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.day);
    }
  }

  void disable() => state = false;
}

/// CU-2, CU-3: se l'Utente autenticato è Cuoco del proprio Gruppo —
/// `false` in assenza di Gruppo o finché profilo e Gruppo non sono
/// ancora caricati, mai un errore da propagare qui.
@riverpod
bool isCook(Ref ref) {
  final group = ref.watch(currentCookingGroupProvider).value;
  final currentUserId = ref.watch(profileControllerProvider).value?.id;
  if (group == null || currentUserId == null) return false;
  for (final member in group.members) {
    if (member.userId == currentUserId) return member.cook;
  }
  return false;
}

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data e, VG-7, per membro: ogni giorno
/// visitato ha una propria cache, così tornare a un giorno già
/// consultato non richiede una nuova richiesta.
///
/// Popola la cache locale di sola lettura a ogni lettura online riuscita
/// (PL-11, F14) e vi ricorre in sua assenza (OF-19): solo per un errore
/// di rete genuino (`NETWORK_ERROR`, [ApiErrorInterceptor]), mai per un
/// errore applicativo, che l'Utente deve continuare a vedere come tale.
/// Un errore di rete senza copia locale per quella data si propaga
/// invariato: non c'è nulla da mostrare, offline o online.
///
/// [userId]: PL-6 riserva la cache al proprio piano — la giornata di un
/// altro membro del Gruppo (F20) non vi transita mai, né in scrittura né
/// in lettura, e un errore di rete si propaga senza alcun ripiego.
@riverpod
Future<PlanDay> planDay(Ref ref, DateTime date, {String? userId}) async {
  if (userId != null) {
    return ref.watch(planDayApiProvider).getDay(date, userId: userId);
  }
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

/// Le sette giornate della settimana richiesta (6.2, VS-1), un'unica
/// richiesta per l'intero intervallo. A differenza di [planDay], nessuna
/// lettura dalla cache locale: l'offline della v1 copre la sola
/// consultazione della vista giornaliera già scaricata (4.6, 6.1
/// interfaccia.md), non quella settimanale — vedi decisioni.md.
///
/// [userId]: come in [planDay] (VG-7, VS-17).
@riverpod
Future<List<PlanDay>> planDayRange(Ref ref, DateTime from, DateTime to, {String? userId}) {
  return ref.watch(planDayApiProvider).getRange(from, to, userId: userId);
}

/// VG-12, VG-14: la giornata affiancata di tutti i membri del Gruppo.
@riverpod
Future<GroupPlanDay> groupPlanDay(Ref ref, DateTime date) {
  return ref.watch(planDayApiProvider).getGroupDay(date);
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

  /// CU-3, EP-2: [userId] facoltativo, per la spunta del Cuoco sul piano
  /// di un membro del proprio Gruppo (F20).
  Future<void> updateStatus(
    DateTime date,
    String slotId,
    SlotStatus status, {
    String? replacementNote,
    String? userId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(planDayApiProvider)
          .updateSlotStatus(date, slotId, status, replacementNote: replacementNote, userId: userId),
    );
    ref.invalidate(planDayProvider(date, userId: userId));
    // VG-12: la modalità affiancata deve rinnovarsi con qualunque
    // spunta, propria o di un membro disposta dal Cuoco (CU-3).
    ref.invalidate(groupPlanDayProvider(date));
  }
}

/// MD-8: modifica della singola occorrenza. A salvataggio riuscito la
/// giornata in cache è sostituita per intero con quella restituita —
/// stesso criterio della spunta — così la vista giornaliera la riflette
/// senza una nuova lettura.
@riverpod
class UpdatePlanDayController extends _$UpdatePlanDayController {
  @override
  AsyncValue<PlanDay>? build() => null;

  Future<void> save(DateTime date, UpdatePlanDayRequest request, {String? userId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(planDayApiProvider).updateOccurrence(date, request, userId: userId),
    );
    if (state?.hasError == false) ref.invalidate(planDayProvider(dateOnly(date), userId: userId));
  }
}
