import 'package:dio/dio.dart';

import 'diet_plan_requests.dart';
import 'diet_plan_template.dart';
import 'diet_plan_template_requests.dart';

/// Chiamate HTTP del template di piano (4.4 tecnica, 3.3 funzionale).
class DietPlanTemplateApi {
  const DietPlanTemplateApi(this._dio);

  final Dio _dio;

  Future<DietPlanTemplate> create(CreateDietPlanTemplateRequest request) async {
    final response = await _dio.post('/diet-plan-templates', data: request.toJson());
    return DietPlanTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  /// CT-2, CT-3: solo i template di proprietà di chi opera, ordinati
  /// alfabeticamente dal backend (PG-3).
  Future<List<DietPlanTemplateSummary>> list() async {
    final response = await _dio.get('/diet-plan-templates');
    return (response.data as List)
        .map((e) => DietPlanTemplateSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// CT-4, CT-5: anteprima di sola lettura, schema settimanale integrale.
  Future<DietPlanTemplate> get(String id) async {
    final response = await _dio.get('/diet-plan-templates/$id');
    return DietPlanTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DietPlanTemplate> update(String id, UpdateDietPlanTemplateRequest request) async {
    final response = await _dio.patch('/diet-plan-templates/$id', data: request.toJson());
    return DietPlanTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DietPlanTemplate> updateSchedule(String id, UpdateWeeklyScheduleRequest request) async {
    final response = await _dio.put('/diet-plan-templates/$id/schedule', data: request.toJson());
    return DietPlanTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  /// TP-12: nessun effetto sui piani già derivati (CT-16).
  Future<void> delete(String id) => _dio.delete('/diet-plan-templates/$id');
}
