import 'account_role.dart';

/// Rispecchia `MeResponse` sul backend (PR-1, PR-6). Il ruolo è di sola
/// presentazione (RG-1): non compare in [UpdateProfileRequest].
class Profile {
  const Profile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.birthPlace,
    required this.sex,
    required this.role,
    required this.height,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        birthPlace: json['birthPlace'] as String,
        sex: BiologicalSex.fromJson(json['sex'] as String),
        role: AccountRole.fromJson(json['role'] as String),
        height: json['height'] as int?,
      );

  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String birthPlace;
  final BiologicalSex sex;
  final AccountRole role;
  final int? height;
}

/// Corpo di `PATCH /me` (PR-1, PR-4, PR-6): rispecchia `UpdateProfileRequest`.
class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.birthPlace,
    required this.sex,
    required this.height,
  });

  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String birthPlace;
  final BiologicalSex sex;
  final int? height;

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate':
            '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
        'birthPlace': birthPlace,
        'sex': sex.toJson(),
        'height': height,
      };
}
