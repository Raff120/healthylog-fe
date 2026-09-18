import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/hydration/data/hydration_api.dart';

/// Stub di [HydrationApi] per i banchi di prova che non riguardano
/// l'idratazione ma attraversano schermate che la osservano (AQ-16: la
/// vista giornaliera la presenta fra gli allenamenti e i pasti): nessuna
/// registrazione e nessun obiettivo — la condizione in cui la sezione
/// presenta il solo totale a zero e i comandi (AQ-19).
///
/// Serve anche a non lasciare in sospeso il ritentativo che Riverpod
/// pianifica su una lettura fallita, come lo stub degli allenamenti.
HydrationApi stubHydrationApi({
  List<Map<String, dynamic>> days = const [],
  int? goalMl,
  List<Map<String, dynamic>>? statisticsDaily,
  int? averageMl,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _HydrationStubAdapter(
      days: days,
      goalMl: goalMl,
      statisticsDaily: statisticsDaily,
      averageMl: averageMl,
    )
    ..interceptors.add(ApiErrorInterceptor());
  return HydrationApi(dio);
}

class _HydrationStubAdapter implements HttpClientAdapter {
  _HydrationStubAdapter({
    required this.days,
    required this.goalMl,
    required this.statisticsDaily,
    required this.averageMl,
  });

  final List<Map<String, dynamic>> days;
  final int? goalMl;
  final List<Map<String, dynamic>>? statisticsDaily;
  final int? averageMl;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/water-intakes') {
      // EP-8: le giornate prive di registrazione non figurano — il
      // chiamante le rende a zero (AQ-27).
      final from = options.queryParameters['from'] as String?;
      final to = options.queryParameters['to'] as String?;
      final selected = days.where((day) {
        final date = day['date'] as String;
        return (from == null || date.compareTo(from) >= 0) && (to == null || date.compareTo(to) <= 0);
      }).toList();
      return _json(200, selected);
    }
    if (options.path == '/me/water-goal') return _json(200, {'valueMl': goalMl});
    if (options.path == '/statistics/water') {
      final daily = statisticsDaily ??
          days.map((day) => {'date': day['date'], 'totalMl': day['totalMl'], 'goalMl': goalMl}).toList();
      return _json(200, {
        'period': options.queryParameters['period'] ?? 'MONTH',
        'from': daily.isEmpty ? '2026-01-01' : daily.first['date'],
        'to': daily.isEmpty ? '2026-01-01' : daily.last['date'],
        'planId': null,
        'planName': null,
        'averageMl': averageMl,
        'averageFrom': daily.isEmpty ? null : daily.first['date'],
        'suspendedDays': 0,
        'uncoveredDays': 0,
        'daily': daily,
      });
    }
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
