import '../../../l10n/app_locale.dart';
import '../../../l10n/unit_system.dart';
import 'account_role.dart';

/// Rispecchia `MeResponse` sul backend (PR-1, PR-6). Il ruolo è di sola
/// presentazione (RG-1): non compare in [UpdateProfileRequest].
/// `timezone` non vi compare neppure (LO-13, F11, deroga: vedi
/// decisioni.md): si modifica dall'endpoint dedicato, come la password.
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
    required this.targetWeightKg,
    required this.timezone,
    required this.locale,
    required this.unitSystem,
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
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
        timezone: json['timezone'] as String?,
        locale: AppLocale.fromJson(json['locale'] as String?),
        unitSystem: UnitSystem.fromJson(json['unitSystem'] as String?),
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

  /// PR-8: peso obiettivo, facoltativo. Serve unicamente come
  /// riferimento nei grafici di andamento (AN-6): nessun calcolo di
  /// distanza residua né di tempo stimato (AN-9, PR-9).
  final double? targetWeightKg;

  final String? timezone;

  /// LO-1, LO-2: lingua dell'interfaccia. Il server la conserva per le
  /// comunicazioni per posta (AU-27); la presentazione attinge alla copia
  /// locale di `LocaleController`, disponibile anche prima dell'accesso.
  final AppLocale locale;

  /// LO-4: sistema di unità di misura. Non ne esiste copia locale: serve
  /// solo dopo l'accesso, dove il profilo è comunque caricato.
  final UnitSystem unitSystem;
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
    this.targetWeightKg,
  });

  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String birthPlace;
  final BiologicalSex sex;
  final int? height;

  /// PR-10: assente, rimuove il peso obiettivo.
  final double? targetWeightKg;

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
        'targetWeightKg': targetWeightKg,
      };
}

/// Corpo di `PATCH /me/preferences` (LO-2, LO-4, F29, deroga: vedi
/// decisioni.md). I due campi sono indipendenti: quello assente non è
/// modificato.
class UpdatePreferencesRequest {
  const UpdatePreferencesRequest({this.locale, this.unitSystem});

  final AppLocale? locale;
  final UnitSystem? unitSystem;

  Map<String, dynamic> toJson() => {
        if (locale != null) 'locale': locale!.toJson(),
        if (unitSystem != null) 'unitSystem': unitSystem!.toJson(),
      };
}

/// Corpo di `PATCH /me/timezone` (LO-13, F11, deroga: vedi decisioni.md).
class UpdateTimezoneRequest {
  const UpdateTimezoneRequest(this.timezone);

  final String timezone;

  Map<String, dynamic> toJson() => {'timezone': timezone};
}
