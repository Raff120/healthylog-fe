/// Formattazione e normalizzazione della sola data (senza orario) usata
/// dalla vista giornaliera e settimanale (6.1, 6.2 funzionale): parametro
/// `date`/`from`/`to` di `GET /plan-days` e chiave dei provider per data.
library;

import '../data/weekday.dart';

/// La localizzazione vera (LO-1, formati per lingua) è compito di F29:
/// qui, come nel resto del client prima di quella feature, i nomi sono
/// cablati in italiano. Condiviso fra il selettore giornaliero e quello
/// settimanale (4.3 interfaccia.md), invece di due elenchi identici.
const italianMonths = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

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

/// [DateTime.weekday] (1 = lunedì .. 7 = domenica) coincide con
/// l'ordinamento di [Weekday] (LO-11): stessa numerazione ISO impiegata
/// dal backend.
Weekday weekdayOf(DateTime date) => Weekday.values[date.weekday - 1];

/// Lunedì della settimana che contiene `date` (LO-11).
DateTime startOfWeek(DateTime date) =>
    dateOnly(date).subtract(Duration(days: date.weekday - 1));
