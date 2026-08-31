import 'package:dio/dio.dart';

import 'device_session.dart';

const _currentDeviceHeader = 'X-Refresh-Token';

/// Elenco e revoca dei dispositivi attivi (AC-14, TK-18, 12.2
/// interfaccia.md) e disconnessione del dispositivo corrente (AC-13,
/// TK-19). Autenticato: costruito su `apiClientProvider`, non
/// `publicApiClientProvider` — vale anche per `/auth/logout`, che
/// richiede il token di accesso per stabilire di quale Utente si stia
/// revocando la sessione (AZ-12).
class SessionsApi {
  const SessionsApi(this._dio);

  final Dio _dio;

  /// [currentRefreshToken] non autentica la richiesta (già stabilita dal
  /// token di accesso): serve solo al backend per segnalare quale voce
  /// dell'elenco sia il dispositivo corrente.
  Future<List<DeviceSession>> getSessions(String? currentRefreshToken) async {
    final response = await _dio.get<List<dynamic>>(
      '/sessions',
      options: _withCurrentDeviceHeader(currentRefreshToken),
    );
    return response.data!.map((json) => DeviceSession.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> revokeSession(String id) {
    return _dio.delete('/sessions/$id');
  }

  /// "Disconnetti tutti gli altri dispositivi" (12.2 interfaccia.md).
  Future<void> revokeAllExceptCurrent(String? currentRefreshToken) {
    return _dio.delete('/sessions', options: _withCurrentDeviceHeader(currentRefreshToken));
  }

  /// AC-13, TK-19: disconnessione esplicita dal dispositivo in uso.
  Future<void> logoutCurrentDevice(String refreshToken) {
    return _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Options? _withCurrentDeviceHeader(String? currentRefreshToken) {
    if (currentRefreshToken == null) return null;
    return Options(headers: {_currentDeviceHeader: currentRefreshToken});
  }
}
