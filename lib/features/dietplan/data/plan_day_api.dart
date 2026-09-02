import 'package:dio/dio.dart';

import 'plan_day.dart';
import 'slot_status.dart';
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

  /// 6.3 funzionale, SP-1, SP-5: transizione di stato dello slot. La
  /// risposta è la giornata intera aggiornata, sullo stesso formato di
  /// [getDay] (comodo per sostituire per intero la cache del provider).
  Future<PlanDay> updateSlotStatus(DateTime date, String slotId, SlotStatus status) async {
    final response = await _dio.patch(
      '/plan-days/${isoDate(date)}/slots/$slotId',
      data: {'status': status.toJson()},
    );
    return PlanDay.fromJson(response.data as Map<String, dynamic>);
  }
}
