/// Una singola aggiunta d'acqua entro una giornata (AQ-1). Rispecchia
/// `WaterIntakeEntryResponse` sul backend.
///
/// L'istante dell'aggiunta non vi compare: AQ-10 esclude che l'ora sia
/// richiesta o presentata, e l'ordine dell'elenco è già quello di
/// registrazione.
class WaterIntakeEntry {
  const WaterIntakeEntry({required this.entryId, required this.amountMl});

  final String entryId;

  /// Millilitri, unità di conservazione (CO-17). La conversione al
  /// sistema scelto è della presentazione (LO-7).
  final int amountMl;

  static WaterIntakeEntry fromJson(Map<String, dynamic> json) => WaterIntakeEntry(
        entryId: json['entryId'] as String,
        amountMl: json['amountMl'] as int,
      );
}

/// La giornata di idratazione (AQ-16). Rispecchia `WaterIntakeDayResponse`.
///
/// Il totale è quello che il server ha sommato (CO-16, EP-7): il client
/// non somma per conto proprio ciò che gli è già stato sommato.
class WaterIntakeDay {
  const WaterIntakeDay({
    required this.date,
    required this.totalMl,
    required this.entries,
  });

  final DateTime date;
  final int totalMl;
  final List<WaterIntakeEntry> entries;

  /// AQ-19, AQ-27: la giornata priva di registrazione non esiste come
  /// documento e non è restituita (EP-8) — esiste però come giornata, e
  /// la vista giornaliera vi presenta il totale a zero e i comandi.
  factory WaterIntakeDay.empty(DateTime date) =>
      WaterIntakeDay(date: date, totalMl: 0, entries: const []);

  static WaterIntakeDay fromJson(Map<String, dynamic> json) => WaterIntakeDay(
        date: DateTime.parse(json['date'] as String),
        totalMl: json['totalMl'] as int,
        entries: (json['entries'] as List)
            .map((e) => WaterIntakeEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Un punto del grafico dell'idratazione (AQ-25). Rispecchia
/// `WaterDayResponse`.
///
/// [goalMl] nullo significa che in quella giornata nessun obiettivo era
/// impostato: la linea di riferimento non si presenta, e nulla segnala
/// che manchi (AQ-11, AQ-26).
class WaterDay {
  const WaterDay({required this.date, required this.totalMl, required this.goalMl});

  final DateTime date;
  final int totalMl;
  final int? goalMl;

  /// AQ-23, EP-11: il raggiungimento non è un campo della risposta ma il
  /// confronto fra i due valori, che si compie qui — nel dominio non
  /// esiste, perché il dominio non giudica.
  bool get goalReached => goalMl != null && totalMl >= goalMl!;

  static WaterDay fromJson(Map<String, dynamic> json) => WaterDay(
        date: DateTime.parse(json['date'] as String),
        totalMl: json['totalMl'] as int,
        goalMl: json['goalMl'] as int?,
      );
}

/// Statistiche dell'idratazione (8.6 funzionale). Rispecchia
/// `WaterStatisticsResponse`.
///
/// **Nessun valore aggregato** (EP-10): quanta acqua in ciascuna giornata
/// e quale obiettivo vi fosse in vigore, e nient'altro. La media
/// giornaliera della prima stesura è soppressa.
class WaterStatistics {
  const WaterStatistics({required this.from, required this.to, required this.daily});

  final DateTime from;
  final DateTime to;
  final List<WaterDay> daily;

  /// AQ-26: l'obiettivo da rappresentare come linea di riferimento è
  /// quello dell'ultima giornata che ne reca uno — le giornate
  /// precedenti conservano il proprio, che il grafico non ridisegna.
  int? get referenceGoalMl {
    for (final day in daily.reversed) {
      if (day.goalMl != null) return day.goalMl;
    }
    return null;
  }

  /// AQ-27, AD-4: nessuna registrazione nell'orizzonte. Le giornate
  /// figurano comunque, a zero: è la presentazione a sostituirvi la
  /// constatazione neutra, non uno zero.
  bool get isEmpty => daily.every((day) => day.totalMl == 0);

  static WaterStatistics fromJson(Map<String, dynamic> json) => WaterStatistics(
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        daily: (json['daily'] as List)
            .map((e) => WaterDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
