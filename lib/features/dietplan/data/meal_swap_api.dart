import 'package:dio/dio.dart';

import '../domain/plan_day_date.dart';
import 'meal_swap_log.dart';

/// Chiamate HTTP dell'inversione (6.4 funzionale, AP-11).
class MealSwapApi {
  const MealSwapApi(this._dio);

  final Dio _dio;

  /// La risposta (la voce di storico appena creata) non è usata dal
  /// client: la giornata aggiornata si ottiene invalidando la cache di
  /// lettura ([planDayRangeProvider]), sullo stesso criterio già seguito
  /// da [PlanDaySlotStatusController].
  Future<void> swap({
    required String planId,
    required DateTime firstDate,
    required String firstSlotId,
    required DateTime secondDate,
    required String secondSlotId,
  }) {
    return _dio.post(
      '/diet-plans/$planId/swaps',
      data: {
        'first': {'date': isoDate(firstDate), 'slotId': firstSlotId},
        'second': {'date': isoDate(secondDate), 'slotId': secondSlotId},
      },
    );
  }

  /// IN-24, ST-5: lo storico delle inversioni operate sul piano, in ordine
  /// cronologico decrescente e di sola lettura (IN-25).
  Future<List<MealSwapLog>> history(String planId) async {
    final response = await _dio.get('/diet-plans/$planId/swaps');
    return (response.data as List)
        .map((e) => MealSwapLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
