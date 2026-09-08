import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/care/data/care_api.dart';

/// Stub di [CareApi] per i banchi di prova che non riguardano il
/// collegamento professionale ma attraversano schermate che lo
/// osservano (UT-8: *Piano*, gestione dei piani, home per ruolo):
/// nessun collegamento (404 su `/care-links/current`, RG-5), nessuna
/// richiesta e nessun Paziente. [currentLink] valorizzato simula
/// invece un Paziente collegato.
CareApi stubCareApi({Map<String, dynamic>? currentLink, List<Map<String, dynamic>> patients = const []}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _CareStubAdapter(currentLink: currentLink, patients: patients)
    ..interceptors.add(ApiErrorInterceptor());
  return CareApi(dio);
}

class _CareStubAdapter implements HttpClientAdapter {
  _CareStubAdapter({required this.currentLink, required this.patients});

  final Map<String, dynamic>? currentLink;
  final List<Map<String, dynamic>> patients;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/care-links/current') {
      return currentLink == null
          ? _json(404, {'code': 'RESOURCE_NOT_FOUND'})
          : _json(200, currentLink!);
    }
    if (options.path == '/patients') return _json(200, patients);
    if (options.path == '/care-link-requests') return _json(200, const <Object>[]);
    return _json(404, {'code': 'RESOURCE_NOT_FOUND'});
  }

  ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}
