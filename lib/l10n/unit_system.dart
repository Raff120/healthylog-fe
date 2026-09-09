/// Sistema di unità di misura scelto dall'Utente (LO-4). Rispecchia
/// `it.healthylog.model.UnitSystem` sul backend.
///
/// LO-7: la scelta riguarda la sola presentazione. I valori sono
/// conservati e trasmessi in un'unica unità interna — chilogrammi e
/// centimetri — e la conversione avviene qui, al momento della
/// visualizzazione e dell'inserimento, così che il cambio di sistema non
/// comporti perdita di precisione né alterazione dei dati registrati.
///
/// LO-8: ne consegue che il cambio si applica retroattivamente a tutti i
/// dati, storico e grafici compresi, senza che nulla sia riscritto.
enum UnitSystem {
  metric,
  imperial;

  /// LO-6: il sistema predefinito è quello metrico.
  static const UnitSystem fallback = UnitSystem.metric;

  String toJson() => name.toUpperCase();

  static UnitSystem fromJson(String? value) => switch (value) {
        'IMPERIAL' => UnitSystem.imperial,
        _ => UnitSystem.metric,
      };
}
