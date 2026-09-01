import 'package:dio/dio.dart';

import '../../../core/api/api_exception.dart';
import 'diet_plan.dart';
import 'diet_plan_requests.dart';
import 'diet_plan_template.dart';

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

  /// TP-5, CD-18: salvataggio dello schema corrente come nuovo template,
  /// disponibile in ogni momento della redazione, non solo in Bozza.
  Future<DietPlanTemplate> saveAsTemplate(String id, SaveDietPlanAsTemplateRequest request) async {
    final response = await _dio.post('/diet-plans/$id/save-as-template', data: request.toJson());
    return DietPlanTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  /// CV-2: da Bozza a Programmato.
  Future<DietPlan> confirm(String id) async {
    final response = await _dio.post('/diet-plans/$id/confirm');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// PA-8: il piano "in corso" — Attivo, altrimenti Sospeso, altrimenti
  /// il prossimo Programmato. `null` se nessuno dei tre esiste
  /// (`RESOURCE_NOT_FOUND`, ER-9): non un errore da propagare, lo stato
  /// vuoto della card (7.1 interfaccia.md).
  Future<DietPlan?> getCurrent() async {
    try {
      final response = await _dio.get('/diet-plans/current');
      return DietPlan.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.asApiException?.code == 'RESOURCE_NOT_FOUND') return null;
      rethrow;
    }
  }

  /// AS-11: da Programmato a Bozza.
  Future<DietPlan> withdraw(String id) async {
    final response = await _dio.post('/diet-plans/$id/withdraw');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// CV-4: attivazione anticipata, con spostamento della data di inizio.
  Future<DietPlan> activate(String id) async {
    final response = await _dio.post('/diet-plans/$id/activate');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// CV-S1: sospensione.
  Future<DietPlan> suspend(String id) async {
    final response = await _dio.post('/diet-plans/$id/suspend');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// CV-S6: ripresa.
  Future<DietPlan> resume(String id) async {
    final response = await _dio.post('/diet-plans/$id/resume');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }

  /// CV-5: conclusione, con la data odierna (PA-7) — nessun corpo, come
  /// previsto dal backend quando la data non è indicata esplicitamente.
  Future<DietPlan> complete(String id) async {
    final response = await _dio.post('/diet-plans/$id/complete');
    return DietPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
