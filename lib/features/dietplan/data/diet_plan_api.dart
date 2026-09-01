import 'package:dio/dio.dart';

import 'diet_plan.dart';
import 'diet_plan_requests.dart';

/// Chiamate HTTP del piano alimentare (4.4 tecnica, 5.1 funzionale).
class DietPlanApi {
  const DietPlanApi(this._dio);

  final Dio _dio;

  Future<DietPlan> create(CreateDietPlanRequest request) async {
    final response = await _dio.post('/diet-plans', data: request.toJson());
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DietPlan> getPlan(String id) async {
    final response = await _dio.get('/diet-plans/$id');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DietPlan> updateSchedule(String id, UpdateWeeklyScheduleRequest request) async {
    final response = await _dio.put('/diet-plans/$id/schedule', data: request.toJson());
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
