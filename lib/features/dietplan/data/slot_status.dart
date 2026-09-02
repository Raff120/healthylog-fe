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
}
