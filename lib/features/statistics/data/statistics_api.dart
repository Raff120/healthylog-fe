import 'package:dio/dio.dart';

import 'statistics_models.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> _query(StatisticsPeriod period, DateTime? date, String? planId, String? userId) => {
      'period': period.param,
      if (date != null) 'date': _isoDate(date),
      if (planId != null) 'planId': planId,
      if (userId != null) 'userId': userId,
    };

/// Chiamate HTTP delle statistiche (4.4 tecnica; 8 funzionale).
///
/// EP-4: gli endpoint accettano l'orizzonte, la data o il piano, e
/// [userId] nei limiti di ST-16bis — ammesso al solo Nutrizionista sul
/// proprio Paziente.
class StatisticsApi {
  const StatisticsApi(this._dio);

  final Dio _dio;

  /// 8.2: aderenza dell'orizzonte, con le disaggregazioni di AD-13 e AD-14.
  Future<AdherenceStatistics> adherence(
    StatisticsPeriod period, {
    DateTime? date,
    String? planId,
    String? userId,
  }) async {
    final response = await _dio.get(
      '/statistics/adherence',
      queryParameters: _query(period, date, planId, userId),
    );
    return AdherenceStatistics.fromJson(response.data as Map<String, dynamic>);
  }

  /// 8.3: frequenza degli allenamenti e confronti con obiettivo e pianificazione.
  Future<WorkoutStatistics> workouts(
    StatisticsPeriod period, {
    DateTime? date,
    String? planId,
    String? userId,
  }) async {
    final response = await _dio.get(
      '/statistics/workouts',
      queryParameters: _query(period, date, planId, userId),
    );
    return WorkoutStatistics.fromJson(response.data as Map<String, dynamic>);
  }

  /// 8.4: andamento di peso e misure, con la variazione nel periodo.
  Future<MeasurementStatistics> measurements(
    StatisticsPeriod period, {
    DateTime? date,
    String? planId,
    String? userId,
  }) async {
    final response = await _dio.get(
      '/statistics/measurements',
      queryParameters: _query(period, date, planId, userId),
    );
    return MeasurementStatistics.fromJson(response.data as Map<String, dynamic>);
  }
}
