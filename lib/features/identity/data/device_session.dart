/// Rispecchia `SessionResponse` sul backend (AC-14, TK-18). `current`: il
/// dispositivo da cui parte la richiesta (12.2 interfaccia.md), non
/// revocabile da qui — per esso si usa la disconnessione.
class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.deviceLabel,
    required this.lastUsedAt,
    required this.current,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) => DeviceSession(
        id: json['id'] as String,
        deviceLabel: json['deviceLabel'] as String,
        lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
        current: json['current'] as bool,
      );

  final String id;
  final String deviceLabel;
  final DateTime lastUsedAt;
  final bool current;
}
