/// Membro annidato del Gruppo (GE-13, GE-15): il solo nome, cognome e
/// privilegio — nessun altro dato anagrafico, peso, misure, allenamenti
/// o statistiche.
class CookingGroupMember {
  const CookingGroupMember({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.owner,
    required this.cook,
    required this.joinedAt,
  });

  factory CookingGroupMember.fromJson(Map<String, dynamic> json) => CookingGroupMember(
        userId: json['userId'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        owner: json['owner'] as bool,
        cook: json['cook'] as bool,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );

  final String userId;
  final String firstName;
  final String lastName;
  final bool owner;
  final bool cook;
  final DateTime joinedAt;
}

/// Rispecchia `CookingGroupResponse` sul backend (3.4 funzionale).
class CookingGroup {
  const CookingGroup({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  factory CookingGroup.fromJson(Map<String, dynamic> json) => CookingGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerId: json['ownerId'] as String,
        // 8.2 interfaccia.md: elenco ordinato per anzianità di appartenenza (GR-16).
        members: (json['members'] as List)
            .map((e) => CookingGroupMember.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt)),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String name;
  final String ownerId;
  final List<CookingGroupMember> members;
  final DateTime createdAt;
}
