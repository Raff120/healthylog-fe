import 'slot_type.dart';

/// Genere della voce di storico (CO-11bis): inversione di due slot o di
/// due giornate intere (IN-28).
enum MealSwapKind {
  slot,
  day;

  /// VR-10: `null` per un genere che questa versione non conosce. Assente,
  /// come nelle voci anteriori alle giornate intere, vale [slot].
  static MealSwapKind? tryFromJson(String? value) => switch (value) {
        null || 'SLOT' => MealSwapKind.slot,
        'DAY' => MealSwapKind.day,
        _ => null,
      };
}

/// Uno dei due slot coinvolti in un'inversione (CO-11), ovvero una delle
/// due giornate: [slotId] e [type] sono allora assenti (CO-11bis).
class MealSwapReference {
  const MealSwapReference({required this.date, this.slotId, this.type});

  factory MealSwapReference.fromJson(Map<String, dynamic> json) => MealSwapReference(
        date: DateTime.parse(json['date'] as String),
        slotId: json['slotId'] as String?,
        type: json['type'] == null ? null : SlotType.fromJson(json['type'] as String),
      );

  final DateTime date;
  final String? slotId;
  final SlotType? type;
}

/// Voce dello storico delle inversioni (IN-23, IN-24). Rispecchia
/// `MealSwapLogResponse` sul backend.
///
/// IN-25: di sola lettura — lo storico non si modifica né si annulla.
class MealSwapLog {
  const MealSwapLog({
    required this.id,
    required this.performedBy,
    required this.performedAt,
    this.kind = MealSwapKind.slot,
    required this.first,
    required this.second,
  });

  factory MealSwapLog.fromJson(Map<String, dynamic> json) => MealSwapLog(
        id: json['id'] as String,
        performedBy: json['performedBy'] as String,
        performedAt: DateTime.parse(json['performedAt'] as String),
        kind: MealSwapKind.tryFromJson(json['kind'] as String?)!,
        first: MealSwapReference.fromJson(json['first'] as Map<String, dynamic>),
        second: MealSwapReference.fromJson(json['second'] as Map<String, dynamic>),
      );

  /// VR-10: `null` se la voce è di un genere sconosciuto, ovvero se uno
  /// dei due slot reca un tipo sconosciuto — lo storico ne omette la voce.
  /// La voce di giornate non reca tipi (CO-11bis).
  static MealSwapLog? tryFromJson(Map<String, dynamic> json) {
    final kind = MealSwapKind.tryFromJson(json['kind'] as String?);
    if (kind == null) return null;
    if (kind == MealSwapKind.slot && (!_knownType(json['first']) || !_knownType(json['second']))) return null;
    return MealSwapLog.fromJson(json);
  }

  static bool _knownType(Object? reference) =>
      SlotType.tryFromJson((reference as Map<String, dynamic>)['type'] as String? ?? '') != null;

  final String id;

  /// CU-4: chi ha disposto l'inversione — l'Utente stesso o il Cuoco del
  /// suo Gruppo.
  final String performedBy;

  final DateTime performedAt;
  final MealSwapKind kind;
  final MealSwapReference first;
  final MealSwapReference second;
}
