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
}
