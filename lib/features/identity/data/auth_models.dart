import 'account_role.dart';

/// Corpo di `POST /auth/register` (rispecchia `RegisterRequest` sul
/// backend, AC-2, AU-7).
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.birthPlace,
    required this.sex,
    required this.password,
    required this.role,
  });

  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String birthPlace;
  final BiologicalSex sex;
  final String password;
  final AccountRole role;

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate':
            '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
        'birthPlace': birthPlace,
        'sex': sex.toJson(),
        'password': password,
        'role': role.toJson(),
      };
}

/// Risposta di `POST /auth/register`.
class RegisterResult {
  const RegisterResult({required this.id, required this.email, required this.username});

  factory RegisterResult.fromJson(Map<String, dynamic> json) => RegisterResult(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
      );

  final String id;
  final String email;
  final String username;
}

/// Corpo di `POST /auth/login` (AC-8). `deviceLabel` identifica il
/// dispositivo nell'elenco delle sessioni attive (TK-18).
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceLabel,
  });

  final String email;
  final String password;
  final String deviceLabel;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'deviceLabel': deviceLabel,
      };
}

/// Coppia di token (TK-1).
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  final String accessToken;
  final String refreshToken;
}
