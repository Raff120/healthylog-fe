import 'package:dio/dio.dart';

import 'auth_models.dart';

/// Chiamate HTTP della feature identity (4.4 tecnica): nessuna logica di
/// dominio qui, solo la corrispondenza con gli endpoint.
class IdentityApi {
  const IdentityApi(this._dio);

  final Dio _dio;

  Future<RegisterResult> register(RegisterRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return RegisterResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final response = await _dio.get(
      '/auth/username-availability',
      queryParameters: {'username': username},
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
  }

  Future<TokenPair> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());
    return TokenPair.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> verifyEmail(String token) {
    return _dio.post('/auth/verify-email', data: {'token': token});
  }

  Future<void> resendVerification(String email) {
    return _dio.post('/auth/verify-email/resend', data: {'email': email});
  }

  Future<void> requestPasswordReset(String email) {
    return _dio.post('/auth/password-reset/request', data: {'email': email});
  }

  Future<void> confirmPasswordReset(String token, String newPassword) {
    return _dio.post(
      '/auth/password-reset/confirm',
      data: {'token': token, 'newPassword': newPassword},
    );
  }
}
