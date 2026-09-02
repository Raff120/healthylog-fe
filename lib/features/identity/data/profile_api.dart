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

  Future<Profile> updateTimezone(UpdateTimezoneRequest request) async {
    final response = await _dio.patch('/me/timezone', data: request.toJson());
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }
}
