import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/workout/data/workout_api.dart';

/// Stub di [WorkoutApi] per i banchi di prova che non riguardano gli
/// allenamenti ma attraversano schermate che li osservano (AL-12: la
/// vista giornaliera e quella settimanale li presentano sopra i pasti e
/// in coda ai pannelli): nessuna pianificazione, nessuna registrazione,
/// nessun obiettivo — la condizione in cui la sezione non compare
/// affatto (6.2 interfaccia.md).
///
/// Serve anche a non lasciare in sospeso il ritentativo che Riverpod
/// pianifica su una lettura fallita: senza stub ogni banco che monta
/// l'applicazione reale attenderebbe quel timer.
WorkoutApi stubWorkoutApi({
  List<Map<String, dynamic>> workouts = const [],
  List<Map<String, dynamic>> planned = const [],
  int? weeklyGoal,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _WorkoutStubAdapter(
      workouts: workouts,
      planned: planned,
      weeklyGoal: weeklyGoal,
    )
    ..interceptors.add(ApiErrorInterceptor());
  return WorkoutApi(dio);
}

class _WorkoutStubAdapter implements HttpClientAdapter {
  _WorkoutStubAdapter({
    required this.workouts,
    required this.planned,
    required this.weeklyGoal,
  });

  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> planned;
  final int? weeklyGoal;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/workouts') return _json(200, workouts);
    if (options.path == '/workouts/activity-types') {
      return _json(200, workouts.map((workout) => workout['activityType']).toSet().toList());
    }
    if (options.path == '/workouts/days') {
      final from = DateTime.parse(options.queryParameters['from'] as String);
      final to = DateTime.parse(options.queryParameters['to'] as String);
      final days = <Map<String, dynamic>>[];
      for (var date = from; !date.isAfter(to); date = date.add(const Duration(days: 1))) {
        final iso = date.toIso8601String().substring(0, 10);
        days.add({
          'date': iso,
          'planned': planned.where((plan) => plan['date'] == iso).toList(),
          'recorded': workouts.where((workout) => workout['date'] == iso).toList(),
        });
      }
      return _json(200, days);
    }
    if (options.path == '/planned-workouts') return _json(200, planned);
    if (options.path == '/me/workout-goal') return _json(200, {'value': weeklyGoal});
    return _json(404, {'code': 'RESOURCE_NOT_FOUND'});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
