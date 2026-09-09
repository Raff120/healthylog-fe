/// Natura della pianificazione (rispecchia
/// `it.healthylog.model.WorkoutRecurrence`).
enum WorkoutRecurrence {
  weekly,
  oneOff;

  static WorkoutRecurrence fromJson(String value) =>
      value == 'ONE_OFF' ? WorkoutRecurrence.oneOff : WorkoutRecurrence.weekly;

  String get param => this == WorkoutRecurrence.oneOff ? 'ONE_OFF' : 'WEEKLY';
}

/// Giorno della settimana come lo scrive il backend (`java.time.DayOfWeek`),
/// con l'ordinamento da lunedì di LO-11.
///
/// Le denominazioni e le iniziali non sono qui ma in
/// `presentation/weekday_presentation.dart`: dipendono dalla lingua
/// selezionata (LO-1) e l'enumerativo non deve conoscerla.
enum Weekday {
  monday('MONDAY'),
  tuesday('TUESDAY'),
  wednesday('WEDNESDAY'),
  thursday('THURSDAY'),
  friday('FRIDAY'),
  saturday('SATURDAY'),
  sunday('SUNDAY');

  const Weekday(this.param);

  final String param;

  static Weekday fromJson(String value) => Weekday.values.firstWhere((day) => day.param == value);

  /// `DateTime.weekday` va da 1 (lunedì) a 7 (domenica).
  static Weekday fromDateTime(DateTime date) => Weekday.values[date.weekday - 1];
}

/// Rispecchia `WorkoutResponse` sul backend (AL-1..AL-4).
class Workout {
  const Workout({
    required this.id,
    required this.userId,
    required this.date,
    required this.activityType,
    required this.caloriesBurned,
    required this.note,
    required this.plannedWorkoutId,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        activityType: json['activityType'] as String,
        caloriesBurned: json['caloriesBurned'] as int?,
        note: json['note'] as String?,
        plannedWorkoutId: json['plannedWorkoutId'] as String?,
      );

  final String id;
  final String userId;
  final DateTime date;
  final String activityType;

  /// AL-3, CB-1: facoltativo, in chilocalorie (CB-3).
  final int? caloriesBurned;

  final String? note;

  /// RA-13: valorizzato se svolto a fronte di una pianificazione.
  final String? plannedWorkoutId;

  bool get fromPlanning => plannedWorkoutId != null;
}

/// Rispecchia `PlannedWorkoutResponse` sul backend (AL-9, CO-12).
class PlannedWorkout {
  const PlannedWorkout({
    required this.id,
    required this.recurrence,
    required this.daysOfWeek,
    required this.date,
    required this.activityType,
    required this.activeFrom,
    required this.activeTo,
  });

  factory PlannedWorkout.fromJson(Map<String, dynamic> json) => PlannedWorkout(
        id: json['id'] as String,
        recurrence: WorkoutRecurrence.fromJson(json['recurrence'] as String),
        daysOfWeek: (json['daysOfWeek'] as List? ?? const [])
            .map((day) => Weekday.fromJson(day as String))
            .toList(),
        date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
        activityType: json['activityType'] as String,
        activeFrom: DateTime.parse(json['activeFrom'] as String),
        activeTo: json['activeTo'] == null ? null : DateTime.parse(json['activeTo'] as String),
      );

  final String id;
  final WorkoutRecurrence recurrence;

  /// AL-10: i giorni previsti, da lunedì a domenica; vuoto se occasionale.
  final List<Weekday> daysOfWeek;

  /// AL-11: la data della previsione occasionale; assente se ricorrente.
  final DateTime? date;

  final String activityType;
  final DateTime activeFrom;
  final DateTime? activeTo;

  bool get isWeekly => recurrence == WorkoutRecurrence.weekly;
}

/// Rispecchia `DayWorkoutsResponse` sul backend (AL-12): quanto una
/// giornata prevede e quanto vi è stato registrato.
class DayWorkouts {
  const DayWorkouts({required this.date, required this.planned, required this.recorded});

  factory DayWorkouts.fromJson(Map<String, dynamic> json) => DayWorkouts(
        date: DateTime.parse(json['date'] as String),
        planned: (json['planned'] as List)
            .map((e) => PlannedWorkout.fromJson(e as Map<String, dynamic>))
            .toList(),
        recorded:
            (json['recorded'] as List).map((e) => Workout.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final DateTime date;
  final List<PlannedWorkout> planned;
  final List<Workout> recorded;

  /// 6.2 interfaccia.md: in assenza di previsti e registrati la sezione non compare.
  bool get isEmpty => planned.isEmpty && recorded.isEmpty;

  /// AL-13: le pianificazioni non ancora spuntate — quelle già svolte
  /// figurano tra i registrati, che le riportano in [Workout.plannedWorkoutId].
  List<PlannedWorkout> get pendingPlanned {
    final done = recorded.map((workout) => workout.plannedWorkoutId).whereType<String>().toSet();
    return planned.where((plan) => !done.contains(plan.id)).toList();
  }
}
