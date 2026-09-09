import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/statistics/data/statistics_api.dart';

/// Stub di [StatisticsApi] per i banchi di prova che attraversano
/// *Statistiche* senza riguardarne il contenuto.
///
/// Predefinito: nessun dato valutabile (AD-4), nessun allenamento,
/// nessuna misurazione — la condizione in cui la sezione presenta le sole
/// constatazioni, mai uno zero.
StatisticsApi stubStatisticsApi({
  Map<String, dynamic>? adherence,
  Map<String, dynamic>? workouts,
  Map<String, dynamic>? measurements,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatisticsStubAdapter(
      adherence: adherence ?? emptyAdherenceJson(),
      workouts: workouts ?? emptyWorkoutStatisticsJson(),
      measurements: measurements ?? emptyMeasurementStatisticsJson(),
    )
    ..interceptors.add(ApiErrorInterceptor());
  return StatisticsApi(dio);
}

/// AD-4: nessuno slot valutabile — il valore è assente, non zero.
Map<String, dynamic> emptyAdherenceJson() => {
      'period': 'WEEK',
      'from': '2026-03-02',
      'to': '2026-03-08',
      'planId': null,
      'planName': null,
      'value': null,
      'suspendedDays': 0,
      'uncoveredDays': 0,
      'bySlotType': <Map<String, dynamic>>[],
      'byWeekday': [
        for (final day in [
          'MONDAY',
          'TUESDAY',
          'WEDNESDAY',
          'THURSDAY',
          'FRIDAY',
          'SATURDAY',
          'SUNDAY',
        ])
          {'key': day, 'value': null},
      ],
      'weekly': [
        {'weekStart': '2026-03-02', 'value': null},
      ],
      'periods': <Map<String, dynamic>>[],
    };

Map<String, dynamic> emptyWorkoutStatisticsJson() => {
      'period': 'WEEK',
      'from': '2026-03-02',
      'to': '2026-03-08',
      'planId': null,
      'planName': null,
      'total': 0,
      'byActivityType': <Map<String, dynamic>>[],
      'goal': null,
      'goalDone': null,
      'goalWeeks': 0,
      'planned': 0,
      'plannedDone': 0,
      'suspendedDays': 0,
      'uncoveredDays': 0,
      'weekly': [
        {'weekStart': '2026-03-02', 'count': 0, 'goal': null},
      ],
    };

Map<String, dynamic> emptyMeasurementStatisticsJson() => {
      'period': 'WEEK',
      'from': '2026-03-02',
      'to': '2026-03-08',
      'planId': null,
      'planName': null,
      'targetWeightKg': null,
      'series': <Map<String, dynamic>>[],
    };

class _StatisticsStubAdapter implements HttpClientAdapter {
  _StatisticsStubAdapter({
    required this.adherence,
    required this.workouts,
    required this.measurements,
  });

  final Map<String, dynamic> adherence;
  final Map<String, dynamic> workouts;
  final Map<String, dynamic> measurements;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return switch (options.path) {
      '/statistics/adherence' => _json(200, adherence),
      '/statistics/workouts' => _json(200, workouts),
      '/statistics/measurements' => _json(200, measurements),
      _ => _json(404, {'code': 'RESOURCE_NOT_FOUND'}),
    };
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
