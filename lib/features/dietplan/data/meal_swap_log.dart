import 'slot_type.dart';

/// Uno dei due slot coinvolti in un'inversione (CO-11).
class MealSwapReference {
  const MealSwapReference({required this.date, required this.slotId, required this.type});

  factory MealSwapReference.fromJson(Map<String, dynamic> json) => MealSwapReference(
        date: DateTime.parse(json['date'] as String),
        slotId: json['slotId'] as String,
        type: SlotType.fromJson(json['type'] as String),
      );

  final DateTime date;
  final String slotId;
  final SlotType type;
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
    required this.first,
    required this.second,
  });

  factory MealSwapLog.fromJson(Map<String, dynamic> json) => MealSwapLog(
        id: json['id'] as String,
        performedBy: json['performedBy'] as String,
        performedAt: DateTime.parse(json['performedAt'] as String),
        first: MealSwapReference.fromJson(json['first'] as Map<String, dynamic>),
        second: MealSwapReference.fromJson(json['second'] as Map<String, dynamic>),
      );

  final String id;

  /// CU-4: chi ha disposto l'inversione — l'Utente stesso o il Cuoco del
  /// suo Gruppo.
  final String performedBy;

  final DateTime performedAt;
  final MealSwapReference first;
  final MealSwapReference second;
}
