import 'package:dio/dio.dart';

import 'care_models.dart';
import 'care_requests.dart';

/// Chiamate HTTP del collegamento professionale e dei Pazienti (4.4
/// tecnica; 4.3 e 8.5 funzionale).
class CareApi {
  const CareApi(this._dio);

  final Dio _dio;

  /// CP-1, CP-2: corrispondenza esatta del nome utente. `RESOURCE_NOT_FOUND`
  /// per ogni esito negativo, senza distinguerne la causa (9.3 interfaccia.md).
  Future<UserLookup> lookup(String username) async {
    final response = await _dio.get('/users/lookup', queryParameters: {'username': username});
    return UserLookup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CareLinkRequest> sendRequest(CreateCareLinkRequest request) async {
    final response = await _dio.post('/care-link-requests', data: request.toJson());
    return CareLinkRequest.fromJson(response.data as Map<String, dynamic>);
  }

  /// CP-10, VA-9: ricevute per l'Utente, inviate per il Nutrizionista.
  Future<List<CareLinkRequest>> listRequests() async {
    final response = await _dio.get('/care-link-requests');
    return (response.data as List).map((e) => CareLinkRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CareLink> accept(String requestId) async {
    final response = await _dio.post('/care-link-requests/$requestId/accept');
    return CareLink.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> reject(String requestId) => _dio.post('/care-link-requests/$requestId/reject');

  Future<void> withdraw(String requestId) => _dio.delete('/care-link-requests/$requestId');

  /// RG-4: il collegamento vigente dell'Utente. `RESOURCE_NOT_FOUND`
  /// (404) quando non ne ha — la condizione ordinaria di RG-5, che le
  /// schermate presentano come stato vuoto, non come errore.
  Future<CareLink> getCurrentLink() async {
    final response = await _dio.get('/care-links/current');
    return CareLink.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> revoke(String careLinkId) => _dio.delete('/care-links/$careLinkId');

  /// NU-1, VA-1, VA-4: elenco dei Pazienti, ordinato secondo [sort].
  Future<List<PatientSummary>> listPatients(PatientSort sort) async {
    final response = await _dio.get('/patients', queryParameters: {'sort': sort.param});
    return (response.data as List).map((e) => PatientSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PatientDetail> getPatient(String patientId) async {
    final response = await _dio.get('/patients/$patientId');
    return PatientDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
