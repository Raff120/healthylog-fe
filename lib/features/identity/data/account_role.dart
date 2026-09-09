/// Ruolo di account (AC-2, RG-1): scelto in registrazione, non modificabile
/// in seguito. Rispecchia `it.healthylog.model.Role` sul backend.
enum AccountRole {
  user,
  nutritionist;

  String toJson() => switch (this) {
        AccountRole.user => 'USER',
        AccountRole.nutritionist => 'NUTRITIONIST',
      };

  static AccountRole fromJson(String value) => switch (value) {
        'NUTRITIONIST' => AccountRole.nutritionist,
        _ => AccountRole.user,
      };
}

/// Sesso anagrafico (PR-1). Rispecchia `it.healthylog.model.Sex`.
enum BiologicalSex {
  male,
  female;

  String toJson() => switch (this) {
        BiologicalSex.male => 'MALE',
        BiologicalSex.female => 'FEMALE',
      };

  static BiologicalSex fromJson(String value) => switch (value) {
        'FEMALE' => BiologicalSex.female,
        _ => BiologicalSex.male,
      };
}
