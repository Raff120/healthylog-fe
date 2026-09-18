// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutApi)
final workoutApiProvider = WorkoutApiProvider._();

final class WorkoutApiProvider
    extends $FunctionalProvider<WorkoutApi, WorkoutApi, WorkoutApi>
    with $Provider<WorkoutApi> {
  WorkoutApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutApiHash();

  @$internal
  @override
  $ProviderElement<WorkoutApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkoutApi create(Ref ref) {
    return workoutApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutApi>(value),
    );
  }
}

String _$workoutApiHash() => r'96a73893de7d0dc3b7067615c1e1edfa844f3613';

@ProviderFor(WorkoutFilterController)
final workoutFilterControllerProvider = WorkoutFilterControllerProvider._();

final class WorkoutFilterControllerProvider
    extends $NotifierProvider<WorkoutFilterController, WorkoutFilters> {
  WorkoutFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutFilterControllerHash();

  @$internal
  @override
  WorkoutFilterController create() => WorkoutFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutFilters>(value),
    );
  }
}

String _$workoutFilterControllerHash() =>
    r'4bd0a9dc5f9665fc03e8daadc78e4f76858f5a7b';

abstract class _$WorkoutFilterController extends $Notifier<WorkoutFilters> {
  WorkoutFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkoutFilters, WorkoutFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutFilters, WorkoutFilters>,
              WorkoutFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// RA-11: l'elenco degli allenamenti registrati, nell'ordine e con i
/// filtri correnti.

@ProviderFor(Workouts)
final workoutsProvider = WorkoutsProvider._();

/// RA-11: l'elenco degli allenamenti registrati, nell'ordine e con i
/// filtri correnti.
final class WorkoutsProvider
    extends $AsyncNotifierProvider<Workouts, List<Workout>> {
  /// RA-11: l'elenco degli allenamenti registrati, nell'ordine e con i
  /// filtri correnti.
  WorkoutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutsHash();

  @$internal
  @override
  Workouts create() => Workouts();
}

String _$workoutsHash() => r'6e82f3ddf0d8d57a8d71331509d222981c597fa1';

/// RA-11: l'elenco degli allenamenti registrati, nell'ordine e con i
/// filtri correnti.

abstract class _$Workouts extends $AsyncNotifier<List<Workout>> {
  FutureOr<List<Workout>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Workout>>, List<Workout>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Workout>>, List<Workout>>,
              AsyncValue<List<Workout>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// AL-2: gli sport già impiegati, che il selettore porta in cima (10.2
/// interfaccia.md) e da cui il filtro ricava le voci (RA-12).

@ProviderFor(workoutActivities)
final workoutActivitiesProvider = WorkoutActivitiesProvider._();

/// AL-2: gli sport già impiegati, che il selettore porta in cima (10.2
/// interfaccia.md) e da cui il filtro ricava le voci (RA-12).

final class WorkoutActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutActivityUsage>>,
          List<WorkoutActivityUsage>,
          FutureOr<List<WorkoutActivityUsage>>
        >
    with
        $FutureModifier<List<WorkoutActivityUsage>>,
        $FutureProvider<List<WorkoutActivityUsage>> {
  /// AL-2: gli sport già impiegati, che il selettore porta in cima (10.2
  /// interfaccia.md) e da cui il filtro ricava le voci (RA-12).
  WorkoutActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutActivitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutActivitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutActivityUsage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutActivityUsage>> create(Ref ref) {
    return workoutActivities(ref);
  }
}

String _$workoutActivitiesHash() => r'47e297291959dd62ab303a7e675482ac155a9b65';

/// AL-9: la pianificazione vigente, che la card di 10.1 presenta.

@ProviderFor(PlannedWorkouts)
final plannedWorkoutsProvider = PlannedWorkoutsProvider._();

/// AL-9: la pianificazione vigente, che la card di 10.1 presenta.
final class PlannedWorkoutsProvider
    extends $AsyncNotifierProvider<PlannedWorkouts, List<PlannedWorkout>> {
  /// AL-9: la pianificazione vigente, che la card di 10.1 presenta.
  PlannedWorkoutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plannedWorkoutsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plannedWorkoutsHash();

  @$internal
  @override
  PlannedWorkouts create() => PlannedWorkouts();
}

String _$plannedWorkoutsHash() => r'7c38ea0afbdc4a2eef8b089e4fcc0ca618d5a948';

/// AL-9: la pianificazione vigente, che la card di 10.1 presenta.

abstract class _$PlannedWorkouts extends $AsyncNotifier<List<PlannedWorkout>> {
  FutureOr<List<PlannedWorkout>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PlannedWorkout>>, List<PlannedWorkout>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PlannedWorkout>>,
                List<PlannedWorkout>
              >,
              AsyncValue<List<PlannedWorkout>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).

@ProviderFor(WeeklyWorkoutGoal)
final weeklyWorkoutGoalProvider = WeeklyWorkoutGoalProvider._();

/// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).
final class WeeklyWorkoutGoalProvider
    extends $AsyncNotifierProvider<WeeklyWorkoutGoal, int?> {
  /// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).
  WeeklyWorkoutGoalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyWorkoutGoalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyWorkoutGoalHash();

  @$internal
  @override
  WeeklyWorkoutGoal create() => WeeklyWorkoutGoal();
}

String _$weeklyWorkoutGoalHash() => r'f79ad73ebfe73f9bc32e6d7a6b86b11f8dcbe6e5';

/// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).

abstract class _$WeeklyWorkoutGoal extends $AsyncNotifier<int?> {
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

/// AL-12: gli allenamenti previsti e registrati di una giornata, per la
/// vista giornaliera. `family` per data, come `planDay`.

@ProviderFor(dayWorkouts)
final dayWorkoutsProvider = DayWorkoutsFamily._();

/// AL-12: gli allenamenti previsti e registrati di una giornata, per la
/// vista giornaliera. `family` per data, come `planDay`.

final class DayWorkoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayWorkouts>,
          DayWorkouts,
          FutureOr<DayWorkouts>
        >
    with $FutureModifier<DayWorkouts>, $FutureProvider<DayWorkouts> {
  /// AL-12: gli allenamenti previsti e registrati di una giornata, per la
  /// vista giornaliera. `family` per data, come `planDay`.
  DayWorkoutsProvider._({
    required DayWorkoutsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'dayWorkoutsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayWorkoutsHash();

  @override
  String toString() {
    return r'dayWorkoutsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DayWorkouts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DayWorkouts> create(Ref ref) {
    final argument = this.argument as DateTime;
    return dayWorkouts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayWorkoutsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayWorkoutsHash() => r'823e4697ed3801ae48c1e0754e2afd8594708794';

/// AL-12: gli allenamenti previsti e registrati di una giornata, per la
/// vista giornaliera. `family` per data, come `planDay`.

final class DayWorkoutsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DayWorkouts>, DateTime> {
  DayWorkoutsFamily._()
    : super(
        retry: null,
        name: r'dayWorkoutsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AL-12: gli allenamenti previsti e registrati di una giornata, per la
  /// vista giornaliera. `family` per data, come `planDay`.

  DayWorkoutsProvider call(DateTime date) =>
      DayWorkoutsProvider._(argument: date, from: this);

  @override
  String toString() => r'dayWorkoutsProvider';
}

/// AL-12: le sette giornate della settimana, per la vista settimanale —
/// un'unica richiesta per l'intero intervallo, come `planDayRange`.

@ProviderFor(weekWorkouts)
final weekWorkoutsProvider = WeekWorkoutsFamily._();

/// AL-12: le sette giornate della settimana, per la vista settimanale —
/// un'unica richiesta per l'intero intervallo, come `planDayRange`.

final class WeekWorkoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayWorkouts>>,
          List<DayWorkouts>,
          FutureOr<List<DayWorkouts>>
        >
    with
        $FutureModifier<List<DayWorkouts>>,
        $FutureProvider<List<DayWorkouts>> {
  /// AL-12: le sette giornate della settimana, per la vista settimanale —
  /// un'unica richiesta per l'intero intervallo, come `planDayRange`.
  WeekWorkoutsProvider._({
    required WeekWorkoutsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'weekWorkoutsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weekWorkoutsHash();

  @override
  String toString() {
    return r'weekWorkoutsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DayWorkouts>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DayWorkouts>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return weekWorkouts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekWorkoutsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weekWorkoutsHash() => r'a1da9f42c7c6b701348480d6f014d779bad51b29';

/// AL-12: le sette giornate della settimana, per la vista settimanale —
/// un'unica richiesta per l'intero intervallo, come `planDayRange`.

final class WeekWorkoutsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DayWorkouts>>, DateTime> {
  WeekWorkoutsFamily._()
    : super(
        retry: null,
        name: r'weekWorkoutsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AL-12: le sette giornate della settimana, per la vista settimanale —
  /// un'unica richiesta per l'intero intervallo, come `planDayRange`.

  WeekWorkoutsProvider call(DateTime weekStart) =>
      WeekWorkoutsProvider._(argument: weekStart, from: this);

  @override
  String toString() => r'weekWorkoutsProvider';
}

/// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
/// circoscrizione (ST-16bis) — in sola lettura (AL-17).

@ProviderFor(patientWorkouts)
final patientWorkoutsProvider = PatientWorkoutsFamily._();

/// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
/// circoscrizione (ST-16bis) — in sola lettura (AL-17).

final class PatientWorkoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workout>>,
          List<Workout>,
          FutureOr<List<Workout>>
        >
    with $FutureModifier<List<Workout>>, $FutureProvider<List<Workout>> {
  /// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
  /// circoscrizione (ST-16bis) — in sola lettura (AL-17).
  PatientWorkoutsProvider._({
    required PatientWorkoutsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patientWorkoutsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patientWorkoutsHash();

  @override
  String toString() {
    return r'patientWorkoutsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Workout>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Workout>> create(Ref ref) {
    final argument = this.argument as String;
    return patientWorkouts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PatientWorkoutsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patientWorkoutsHash() => r'eeca02435bc51342cc497e1db9fc0ea9695ff81f';

/// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
/// circoscrizione (ST-16bis) — in sola lettura (AL-17).

final class PatientWorkoutsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Workout>>, String> {
  PatientWorkoutsFamily._()
    : super(
        retry: null,
        name: r'patientWorkoutsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AL-18, NU-4: gli allenamenti di un Paziente, nei limiti della
  /// circoscrizione (ST-16bis) — in sola lettura (AL-17).

  PatientWorkoutsProvider call(String patientId) =>
      PatientWorkoutsProvider._(argument: patientId, from: this);

  @override
  String toString() => r'patientWorkoutsProvider';
}

/// RA-4, RA-15: registrazione, modifica ed eliminazione. Ogni esito
/// rinnova elenco, giornate e tipi impiegati per invalidazione, come già
/// fanno i controller del piano.

@ProviderFor(WorkoutController)
final workoutControllerProvider = WorkoutControllerProvider._();

/// RA-4, RA-15: registrazione, modifica ed eliminazione. Ogni esito
/// rinnova elenco, giornate e tipi impiegati per invalidazione, come già
/// fanno i controller del piano.
final class WorkoutControllerProvider
    extends $NotifierProvider<WorkoutController, AsyncValue<void>?> {
  /// RA-4, RA-15: registrazione, modifica ed eliminazione. Ogni esito
  /// rinnova elenco, giornate e tipi impiegati per invalidazione, come già
  /// fanno i controller del piano.
  WorkoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutControllerHash();

  @$internal
  @override
  WorkoutController create() => WorkoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$workoutControllerHash() => r'b8164457cb5a43d5ef8bb58b1ea0e1955c5d46dc';

/// RA-4, RA-15: registrazione, modifica ed eliminazione. Ogni esito
/// rinnova elenco, giornate e tipi impiegati per invalidazione, come già
/// fanno i controller del piano.

abstract class _$WorkoutController extends $Notifier<AsyncValue<void>?> {
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

/// AL-9, AL-16: pianificazione, modifica e cessazione. La modifica non
/// altera i giorni trascorsi (DS-14): le giornate già consultate vanno
/// comunque rilette, perché quelle future ora prevedono altro.

@ProviderFor(PlannedWorkoutController)
final plannedWorkoutControllerProvider = PlannedWorkoutControllerProvider._();

/// AL-9, AL-16: pianificazione, modifica e cessazione. La modifica non
/// altera i giorni trascorsi (DS-14): le giornate già consultate vanno
/// comunque rilette, perché quelle future ora prevedono altro.
final class PlannedWorkoutControllerProvider
    extends $NotifierProvider<PlannedWorkoutController, AsyncValue<void>?> {
  /// AL-9, AL-16: pianificazione, modifica e cessazione. La modifica non
  /// altera i giorni trascorsi (DS-14): le giornate già consultate vanno
  /// comunque rilette, perché quelle future ora prevedono altro.
  PlannedWorkoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plannedWorkoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plannedWorkoutControllerHash();

  @$internal
  @override
  PlannedWorkoutController create() => PlannedWorkoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$plannedWorkoutControllerHash() =>
    r'afbe524d1110d9b1da5f76d2bc0b85101dd3e58f';

/// AL-9, AL-16: pianificazione, modifica e cessazione. La modifica non
/// altera i giorni trascorsi (DS-14): le giornate già consultate vanno
/// comunque rilette, perché quelle future ora prevedono altro.

abstract class _$PlannedWorkoutController extends $Notifier<AsyncValue<void>?> {
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
