/// Formattazione e normalizzazione della sola data (senza orario) usata
/// dalla vista giornaliera (6.1 funzionale): parametro `date` di `GET
/// /plan-days` e chiave dei provider per data.
library;

/// Formato ISO (`AAAA-MM-GG`) atteso dal backend (`@DateTimeFormat`).
String isoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Normalizza a mezzanotte locale: due date che indicano lo stesso giorno
/// devono risultare uguali (chiave dei provider `family`), indipendentemente
/// dall'orario con cui sono state costruite.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
