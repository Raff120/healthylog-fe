/// Tipo di slot di una giornata (GG-1). Rispecchia
/// `it.healthylog.model.SlotType` sul backend.
enum SlotType {
  breakfast,
  lunch,
  dinner,
  snack;

  String toJson() => switch (this) {
        SlotType.breakfast => 'BREAKFAST',
        SlotType.lunch => 'LUNCH',
        SlotType.dinner => 'DINNER',
        SlotType.snack => 'SNACK',
      };

  static SlotType fromJson(String value) => switch (value) {
        'LUNCH' => SlotType.lunch,
        'DINNER' => SlotType.dinner,
        'SNACK' => SlotType.snack,
        _ => SlotType.breakfast,
      };

  /// VR-10: `null` per un tipo che questa versione del client non conosce.
  /// Chi legge una risposta ne omette l'elemento anziché ricondurlo a un
  /// tipo esistente, che ne falserebbe il senso.
  static SlotType? tryFromJson(String value) => switch (value) {
        'BREAKFAST' => SlotType.breakfast,
        'LUNCH' => SlotType.lunch,
        'DINNER' => SlotType.dinner,
        'SNACK' => SlotType.snack,
        _ => null,
      };
}
