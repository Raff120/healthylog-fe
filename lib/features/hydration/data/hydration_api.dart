import 'package:dio/dio.dart';

import '../../statistics/data/statistics_models.dart';
import 'hydration_models.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Chiamate HTTP del consumo d'acqua (4.4 tecnica; 6.7 e 8.6 funzionale).
class HydrationApi {
  const HydrationApi(this._dio);

  final Dio _dio;

  /// AQ-5, AQ-7, EP-7: l'aggiunta restituisce la giornata aggiornata —
  /// totale compreso, che non si ricalcola qui (CO-16).
  Future<WaterIntakeDay> add(DateTime date, int amountMl) async {
    final response = await _dio.post('/water-intakes', data: {
      'date': _isoDate(date),
      'amountMl': amountMl,
    });
    return WaterIntakeDay.fromJson(response.data as Map<String, dynamic>);
  }

  /// AQ-8: l'annullamento di una singola aggiunta.
  Future<WaterIntakeDay> removeEntry(DateTime date, String entryId) async {
    final response = await _dio.delete('/water-intakes/${_isoDate(date)}/entries/$entryId');
    return WaterIntakeDay.fromJson(response.data as Map<String, dynamic>);
  }

  /// AQ-25, EP-8: le giornate registrate nell'intervallo. Quelle prive di
  /// registrazione non figurano: il chiamante le rende a zero (AQ-27).
  /// [userId] è ammesso al solo Nutrizionista sul proprio Paziente
  /// (AQ-31).
  Future<List<WaterIntakeDay>> list(DateTime from, DateTime to, {String? userId}) async {
    final response = await _dio.get('/water-intakes', queryParameters: {
      'from': _isoDate(from),
      'to': _isoDate(to),
      if (userId != null) 'userId': userId,
    });
    return (response.data as List)
        .map((e) => WaterIntakeDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// AQ-11: l'obiettivo giornaliero vigente, `null` se non impostato.
  Future<int?> getGoal() async {
    final response = await _dio.get('/me/water-goal');
    return (response.data as Map<String, dynamic>)['valueMl'] as int?;
  }

  /// AQ-12, DS-19: impostazione, modifica e rimozione ([valueMl] nullo).
  Future<int?> setGoal(int? valueMl) async {
    final response = await _dio.put('/me/water-goal', data: {'valueMl': valueMl});
    return (response.data as Map<String, dynamic>)['valueMl'] as int?;
  }

  /// 8.6: consumo medio e andamento giornaliero dell'orizzonte.
  Future<WaterStatistics> statistics(
    StatisticsPeriod period, {
    DateTime? date,
    String? planId,
    String? userId,
  }) async {
    final response = await _dio.get('/statistics/water', queryParameters: {
      'period': period.param,
      if (date != null) 'date': _isoDate(date),
      if (planId != null) 'planId': planId,
      if (userId != null) 'userId': userId,
    });
    return WaterStatistics.fromJson(response.data as Map<String, dynamic>);
  }
}
