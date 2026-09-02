import 'package:dio/dio.dart';

import 'plan_day.dart';
import '../domain/plan_day_date.dart';

/// Chiamate HTTP della vista giornaliera (4.4 tecnica, 6.1 funzionale).
class PlanDayApi {
  const PlanDayApi(this._dio);

  final Dio _dio;

  /// EP-3: la lettura non materializza mai la giornata.
  Future<PlanDay> getDay(DateTime date) async {
    final response = await _dio.get('/plan-days', queryParameters: {'date': isoDate(date)});
    return PlanDay.fromJson(response.data as Map<String, dynamic>);
  }
}
