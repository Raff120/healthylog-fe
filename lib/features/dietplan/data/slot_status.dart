/// Stato di consumo di uno slot di un'occorrenza giornaliera (SP-1).
/// Rispecchia `it.healthylog.model.SlotStatus` sul backend. Le
/// transizioni sono compito di F13; qui se ne rispecchiano solo i valori.
enum SlotStatus {
  toConsume,
  consumed,
  skipped;

  static SlotStatus fromJson(String value) => switch (value) {
        'CONSUMED' => SlotStatus.consumed,
        'SKIPPED' => SlotStatus.skipped,
        _ => SlotStatus.toConsume,
      };

  /// VR-10: `null` per uno stato che questa versione del client non
  /// conosce. Presentarlo come da consumare inviterebbe a spuntare uno
  /// slot il cui stato effettivo è ignoto: l'elemento è omesso.
  static SlotStatus? tryFromJson(String value) => switch (value) {
        'TO_CONSUME' => SlotStatus.toConsume,
        'CONSUMED' => SlotStatus.consumed,
        'SKIPPED' => SlotStatus.skipped,
        _ => null,
      };

  /// Corpo di `PATCH /plan-days/{date}/slots/{slotId}` (F13, SP-1).
  String toJson() => switch (this) {
        SlotStatus.toConsume => 'TO_CONSUME',
        SlotStatus.consumed => 'CONSUMED',
        SlotStatus.skipped => 'SKIPPED',
      };
}
