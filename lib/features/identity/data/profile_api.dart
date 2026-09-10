import 'package:dio/dio.dart';

import 'profile_models.dart';

/// Chiamate HTTP del profilo (4.4 tecnica, PR-1, PR-4, PR-6). A
/// differenza di [IdentityApi] richiede autenticazione: costruito sul
/// client che allega il token di accesso (`apiClientProvider`).
class ProfileApi {
  const ProfileApi(this._dio);

  final Dio _dio;

  Future<Profile> getProfile() async {
    final response = await _dio.get('/me');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Profile> updateProfile(UpdateProfileRequest request) async {
    final response = await _dio.patch('/me', data: request.toJson());
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// LO-2, LO-4: lingua e sistema di unità di misura (12.2 interfaccia.md).
  Future<Profile> updatePreferences(UpdatePreferencesRequest request) async {
    final response = await _dio.patch('/me/preferences', data: request.toJson());
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// AC-19, AU-20: modifica della password previa indicazione di
  /// quella corrente. Non restituisce il profilo — nulla di quanto esso
  /// espone cambia — né chiude le sessioni attive.
  Future<void> changePassword(String currentPassword, String newPassword) {
    return _dio.patch(
      '/me/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  /// PV-7, PV-8: accettazione dell'informativa vigente.
  Future<Profile> acceptPrivacyPolicy() async {
    final response = await _dio.post('/me/privacy-acceptance');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// PV-16, PV-17: richiesta di eliminazione e sua revoca.
  Future<Profile> requestDeletion() async {
    final response = await _dio.post('/me/deletion');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Profile> cancelDeletion() async {
    final response = await _dio.delete('/me/deletion');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Profile> updateTimezone(UpdateTimezoneRequest request) async {
    final response = await _dio.patch('/me/timezone', data: request.toJson());
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }
}
