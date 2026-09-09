import 'package:dio/dio.dart';

import 'measurement_models.dart';
import 'measurement_requests.dart';

String _isoDate(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Chiamate HTTP delle misurazioni corporee (4.4 tecnica; 4.2 funzionale).
class MeasurementApi {
  const MeasurementApi(this._dio);

  final Dio _dio;

  /// AN-4: l'elenco in ordine cronologico decrescente. [userId] è ammesso
  /// al solo Nutrizionista sul proprio Paziente, nei limiti di CS-14.
  Future<List<BodyMeasurement>> list({DateTime? from, DateTime? to, String? userId}) async {
    final response = await _dio.get('/body-measurements', queryParameters: {
      if (from != null) 'from': _isoDate(from),
      if (to != null) 'to': _isoDate(to),
      if (userId != null) 'userId': userId,
    });
    return (response.data as List)
        .map((e) => BodyMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BodyMeasurement> create(CreateBodyMeasurementRequest request) async {
    final response = await _dio.post('/body-measurements', data: request.toJson());
    return BodyMeasurement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BodyMeasurement> update(String id, UpdateBodyMeasurementRequest request) async {
    final response = await _dio.patch('/body-measurements/$id', data: request.toJson());
    return BodyMeasurement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _dio.delete('/body-measurements/$id');
}
