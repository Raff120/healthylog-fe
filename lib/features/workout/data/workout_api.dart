import 'package:dio/dio.dart';

import 'workout_models.dart';
import 'workout_requests.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Chiamate HTTP degli allenamenti registrati e pianificati (4.4 tecnica;
/// 3.5 e 7 funzionale).
class WorkoutApi {
  const WorkoutApi(this._dio);

  final Dio _dio;

  /// RA-11, RA-12: l'elenco in ordine cronologico decrescente, con i
  /// filtri per tipo e per periodo.
  Future<List<Workout>> list({DateTime? from, DateTime? to, String? activityType, String? userId}) async {
    final response = await _dio.get('/workouts', queryParameters: {
      if (from != null) 'from': _isoDate(from),
      if (to != null) 'to': _isoDate(to),
      if (activityType != null) 'activityType': activityType,
      if (userId != null) 'userId': userId,
    });
    return (response.data as List).map((e) => Workout.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// RA-9: gli allenamenti già registrati per una data, che la conferma
  /// sul duplicato presenta (AL-6).
  Future<List<Workout>> listByDate(DateTime date) async {
    final response = await _dio.get('/workouts', queryParameters: {'date': _isoDate(date)});
    return (response.data as List).map((e) => Workout.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// AL-12: previsti e registrati di ciascun giorno dell'intervallo.
  Future<List<DayWorkouts>> days(DateTime from, DateTime to, {String? userId}) async {
    final response = await _dio.get('/workouts/days', queryParameters: {
      'from': _isoDate(from),
      'to': _isoDate(to),
      if (userId != null) 'userId': userId,
    });
    return (response.data as List).map((e) => DayWorkouts.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// AL-2: i tipi già impiegati, per i suggerimenti e per il filtro.
  Future<List<String>> activityTypes() async {
    final response = await _dio.get('/workouts/activity-types');
    return (response.data as List).cast<String>();
  }

  Future<Workout> create(CreateWorkoutRequest request) async {
    final response = await _dio.post('/workouts', data: request.toJson());
    return Workout.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Workout> update(String id, UpdateWorkoutRequest request) async {
    final response = await _dio.patch('/workouts/$id', data: request.toJson());
    return Workout.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _dio.delete('/workouts/$id');

  /// AL-9: la pianificazione vigente.
  Future<List<PlannedWorkout>> listPlanned() async {
    final response = await _dio.get('/planned-workouts');
    return (response.data as List).map((e) => PlannedWorkout.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PlannedWorkout> createPlanned(CreatePlannedWorkoutRequest request) async {
    final response = await _dio.post('/planned-workouts', data: request.toJson());
    return PlannedWorkout.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PlannedWorkout> updatePlanned(String id, UpdatePlannedWorkoutRequest request) async {
    final response = await _dio.patch('/planned-workouts/$id', data: request.toJson());
    return PlannedWorkout.fromJson(response.data as Map<String, dynamic>);
  }

  /// AL-16: cessazione, non eliminazione.
  Future<void> ceasePlanned(String id) => _dio.delete('/planned-workouts/$id');

  /// OS-1: l'obiettivo settimanale vigente, `null` se non impostato (OS-3).
  Future<int?> getWeeklyGoal() async {
    final response = await _dio.get('/me/workout-goal');
    return (response.data as Map<String, dynamic>)['value'] as int?;
  }

  /// OS-5, DS-11: impostazione, modifica e rimozione (con [value] nullo).
  Future<int?> setWeeklyGoal(int? value) async {
    final response = await _dio.put('/me/workout-goal', data: {'value': value});
    return (response.data as Map<String, dynamic>)['value'] as int?;
  }
}
