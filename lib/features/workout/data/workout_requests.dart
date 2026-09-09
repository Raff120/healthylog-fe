import 'workout_models.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Corpo di `POST /workouts` (RA-4). [activityType] è assente quando la
/// registrazione nasce dalla spunta di un allenamento previsto: il tipo è
/// ereditato dalla pianificazione (AL-13, RA-3).
class CreateWorkoutRequest {
  const CreateWorkoutRequest({
    required this.date,
    this.activityType,
    this.caloriesBurned,
    this.note,
    this.plannedWorkoutId,
  });

  final DateTime date;
  final String? activityType;
  final int? caloriesBurned;
  final String? note;
  final String? plannedWorkoutId;

  Map<String, dynamic> toJson() => {
        'date': _isoDate(date),
        'activityType': activityType,
        'caloriesBurned': caloriesBurned,
        'note': note,
        'plannedWorkoutId': plannedWorkoutId,
      };
}

/// Corpo di `PATCH /workouts/{id}` (RA-15): l'intero modulo — un valore
/// assente azzera quello registrato (CB-4).
class UpdateWorkoutRequest {
  const UpdateWorkoutRequest({
    required this.date,
    required this.activityType,
    this.caloriesBurned,
    this.note,
  });

  final DateTime date;
  final String activityType;
  final int? caloriesBurned;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': _isoDate(date),
        'activityType': activityType,
        'caloriesBurned': caloriesBurned,
        'note': note,
      };
}

/// Corpo di `POST /planned-workouts` (AL-10, AL-11).
class CreatePlannedWorkoutRequest {
  const CreatePlannedWorkoutRequest.weekly({
    required this.daysOfWeek,
    required this.activityType,
  })  : recurrence = WorkoutRecurrence.weekly,
        date = null;

  const CreatePlannedWorkoutRequest.oneOff({required this.date, required this.activityType})
      : recurrence = WorkoutRecurrence.oneOff,
        daysOfWeek = const [];

  final WorkoutRecurrence recurrence;
  final List<Weekday> daysOfWeek;
  final DateTime? date;
  final String activityType;

  Map<String, dynamic> toJson() => {
        'recurrence': recurrence.param,
        'daysOfWeek': daysOfWeek.map((day) => day.param).toList(),
        'date': date == null ? null : _isoDate(date!),
        'activityType': activityType,
      };
}

/// Corpo di `PATCH /planned-workouts/{id}` (AL-16, DS-14).
class UpdatePlannedWorkoutRequest {
  const UpdatePlannedWorkoutRequest({
    required this.activityType,
    this.daysOfWeek = const [],
    this.date,
  });

  final String activityType;
  final List<Weekday> daysOfWeek;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
        'activityType': activityType,
        'daysOfWeek': daysOfWeek.map((day) => day.param).toList(),
        'date': date == null ? null : _isoDate(date!),
      };
}
