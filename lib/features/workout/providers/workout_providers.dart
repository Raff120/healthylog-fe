import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/workout_api.dart';
import '../data/workout_models.dart';
import '../data/workout_requests.dart';

part 'workout_providers.g.dart';

@riverpod
WorkoutApi workoutApi(Ref ref) => WorkoutApi(ref.watch(apiClientProvider));

/// RA-12: i filtri dell'elenco — tipo di attività e periodo — presentati
/// come chip rimovibili singolarmente sotto l'intestazione.
class WorkoutFilters {
  const WorkoutFilters({this.activityType, this.from, this.to});

  final String? activityType;
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty => activityType == null && from == null && to == null;

  WorkoutFilters withoutActivityType() => WorkoutFilters(from: from, to: to);

  WorkoutFilters withoutPeriod() => WorkoutFilters(activityType: activityType);

  @override
  bool operator ==(Object other) =>
      other is WorkoutFilters &&
      other.activityType == activityType &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(activityType, from, to);
}

@riverpod
class WorkoutFilterController extends _$WorkoutFilterController {
  @override
  WorkoutFilters build() => const WorkoutFilters();

  void apply(WorkoutFilters filters) => state = filters;

  void clear() => state = const WorkoutFilters();
}

/// RA-11: l'elenco degli allenamenti registrati, nell'ordine e con i
/// filtri correnti.
@riverpod
class Workouts extends _$Workouts {
  @override
  Future<List<Workout>> build() {
    final filters = ref.watch(workoutFilterControllerProvider);
    return ref.read(workoutApiProvider).list(
          from: filters.from,
          to: filters.to,
          activityType: filters.activityType,
        );
  }
}

/// AL-2: i tipi già impiegati, per i suggerimenti del campo (10.2
/// interfaccia.md) e per le voci del filtro (RA-12).
@riverpod
Future<List<String>> workoutActivityTypes(Ref ref) => ref.watch(workoutApiProvider).activityTypes();

/// AL-9: la pianificazione vigente, che la card di 10.1 presenta.
@riverpod
class PlannedWorkouts extends _$PlannedWorkouts {
  @override
  Future<List<PlannedWorkout>> build() => ref.read(workoutApiProvider).listPlanned();
}

/// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).
@riverpod
class WeeklyWorkoutGoal extends _$WeeklyWorkoutGoal {
  @override
  Future<int?> build() => ref.read(workoutApiProvider).getWeeklyGoal();

  /// OS-5: impostazione, modifica e rimozione ([value] nullo, DS-11).
  Future<void> save(int? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(workoutApiProvider).setWeeklyGoal(value));
  }
}

/// AL-12: gli allenamenti previsti e registrati di una giornata, per la
/// vista giornaliera. `family` per data, come `planDay`.
@riverpod
Future<DayWorkouts> dayWorkouts(Ref ref, DateTime date) async {
  final days = await ref.watch(workoutApiProvider).days(date, date);
  return days.isEmpty
      ? DayWorkouts(date: date, planned: const [], recorded: const [])
      : days.first;
}

/// AL-12: le sette giornate della settimana, per la vista settimanale —
/// un'unica richiesta per l'intero intervallo, come `planDayRange`.
@riverpod
Future<List<DayWorkouts>> weekWorkouts(Ref ref, DateTime weekStart) {
  return ref.watch(workoutApiProvider).days(weekStart, weekStart.add(const Duration(days: 6)));
}

/// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
/// circoscrizione (ST-16bis) — in sola lettura (AL-17).
@riverpod
Future<List<Workout>> patientWorkouts(Ref ref, String patientId) =>
    ref.watch(workoutApiProvider).list(userId: patientId);

/// RA-4, RA-15: registrazione, modifica ed eliminazione. Ogni esito
/// rinnova elenco, giornate e tipi impiegati per invalidazione, come già
/// fanno i controller del piano.
@riverpod
class WorkoutController extends _$WorkoutController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> create(CreateWorkoutRequest request) =>
      _run(() => ref.read(workoutApiProvider).create(request));

  Future<void> update(String id, UpdateWorkoutRequest request) =>
      _run(() => ref.read(workoutApiProvider).update(id, request));

  Future<void> delete(String id) => _run(() => ref.read(workoutApiProvider).delete(id));

  Future<void> _run(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(operation);
    if (state?.hasError ?? true) return;
    _invalidateReads();
  }

  void _invalidateReads() {
    ref.invalidate(workoutsProvider);
    ref.invalidate(workoutActivityTypesProvider);
    ref.invalidate(dayWorkoutsProvider);
    ref.invalidate(weekWorkoutsProvider);
  }
}

/// AL-9, AL-16: pianificazione, modifica e cessazione. La modifica non
/// altera i giorni trascorsi (DS-14): le giornate già consultate vanno
/// comunque rilette, perché quelle future ora prevedono altro.
@riverpod
class PlannedWorkoutController extends _$PlannedWorkoutController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> create(CreatePlannedWorkoutRequest request) =>
      _run(() => ref.read(workoutApiProvider).createPlanned(request));

  Future<void> update(String id, UpdatePlannedWorkoutRequest request) =>
      _run(() => ref.read(workoutApiProvider).updatePlanned(id, request));

  Future<void> cease(String id) => _run(() => ref.read(workoutApiProvider).ceasePlanned(id));

  Future<void> _run(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(operation);
    if (state?.hasError ?? true) return;
    ref.invalidate(plannedWorkoutsProvider);
    ref.invalidate(dayWorkoutsProvider);
    ref.invalidate(weekWorkoutsProvider);
  }
}
