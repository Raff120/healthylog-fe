/// Rispecchia `InviteCodeResponse` sul backend (GR-6, GR-7, GR-8).
class InviteCode {
  const InviteCode({
    required this.id,
    required this.code,
    required this.expiresAt,
    required this.maxUses,
    required this.usedCount,
    required this.createdAt,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) => InviteCode(
        id: json['id'] as String,
        code: json['code'] as String,
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
        maxUses: json['maxUses'] as int?,
        usedCount: json['usedCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String code;
  final DateTime? expiresAt;
  final int? maxUses;
  final int usedCount;
  final DateTime createdAt;
}

/// Rispecchia `InviteCodePreviewResponse` (GR-9): mostrata prima della
/// conferma di adesione, senza consumare il codice.
class InviteCodePreview {
  const InviteCodePreview({required this.groupName, required this.memberCount});

  factory InviteCodePreview.fromJson(Map<String, dynamic> json) => InviteCodePreview(
        groupName: json['groupName'] as String,
        memberCount: json['memberCount'] as int,
      );

  final String groupName;
  final int memberCount;
}
