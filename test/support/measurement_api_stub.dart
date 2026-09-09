import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/measurement/data/measurement_api.dart';

/// Stub di [MeasurementApi] per i banchi che attraversano schermate che
/// le osservano senza esserne l'oggetto — *Attività* le ospita nel
/// secondo segmento (10.1), il dettaglio del Paziente le elenca (9.2).
MeasurementApi stubMeasurementApi({List<Map<String, dynamic>> measurements = const []}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _MeasurementStubAdapter(measurements)
    ..interceptors.add(ApiErrorInterceptor());
  return MeasurementApi(dio);
}

class _MeasurementStubAdapter implements HttpClientAdapter {
  _MeasurementStubAdapter(this.measurements);

  final List<Map<String, dynamic>> measurements;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(options.path == '/body-measurements' ? measurements : const <Object>[]),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
