/// Sessione corrente: la sola coppia di token (TK-1). Il token di accesso
/// non è mai persistito (TK-9); la conservazione sicura del token di
/// rinnovo (TK-8) è predisposta in questo stesso oggetto, non ancora
/// collegata all'archivio del dispositivo.
class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  AuthSession copyWith({String? accessToken, String? refreshToken}) => AuthSession(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
      );
}
