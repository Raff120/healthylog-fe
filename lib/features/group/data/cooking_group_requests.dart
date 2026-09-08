/// Corpo di `POST /cooking-groups` (GE-1) e di `PATCH /cooking-groups/{id}`
/// (GE-12, GR-1): un solo campo in entrambi i casi, stessa forma.
class CookingGroupNameRequest {
  const CookingGroupNameRequest(this.name);

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}

/// Corpo di `POST /invite-codes/preview` e di `POST /cooking-groups/join`
/// (GR-9): il solo codice inserito dall'Utente.
class InviteCodeRequest {
  const InviteCodeRequest(this.code);

  final String code;

  Map<String, dynamic> toJson() => {'code': code};
}

/// Corpo di `POST /cooking-groups/{id}/invite-codes` (GR-8): entrambi i
/// campi facoltativi, la loro assenza significa nessun limite.
class GenerateInviteCodeRequest {
  const GenerateInviteCodeRequest({this.expiresAt, this.maxUses});

  final DateTime? expiresAt;
  final int? maxUses;

  Map<String, dynamic> toJson() => {
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
        'maxUses': maxUses,
      };
}

/// Corpo di `PATCH /cooking-groups/{id}/members/{userId}` (GE-7).
class UpdateGroupMemberRequest {
  const UpdateGroupMemberRequest({required this.cook});

  final bool cook;

  Map<String, dynamic> toJson() => {'cook': cook};
}

/// Corpo di `POST /cooking-groups/{id}/transfer-ownership` (GE-9).
class TransferGroupOwnershipRequest {
  const TransferGroupOwnershipRequest(this.newOwnerId);

  final String newOwnerId;

  Map<String, dynamic> toJson() => {'newOwnerId': newOwnerId};
}
