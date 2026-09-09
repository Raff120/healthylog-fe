import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formati di data e numero (LO-9, LO-10).
///
/// LO-9: le date sono presentate nel formato proprio della lingua
/// selezionata — 9/9/2026 in italiano, 9/9/2026 in inglese per questa
/// data, ma 1/9/2026 e 9/1/2026 per il primo settembre. LO-10: i numeri
/// decimali seguono il separatore proprio della lingua — 72,5 in
/// italiano, 72.5 in inglese.
///
/// Le funzioni ricevono il contesto e ne leggono la lingua corrente: il
/// cambio di lingua dalle Impostazioni si riflette per ciò stesso su ogni
/// data e ogni numero già a schermo, senza che nulla sia ricaricato.
///
/// Non vi passano le date destinate al **server**, che viaggiano nel
/// formato di FR-8 (`isoDate`) e non dipendono dalla lingua.
String _locale(BuildContext context) => Localizations.localeOf(context).toLanguageTag();

/// Data in forma breve: quella d'uso corrente nell'applicazione.
String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMd(_locale(context)).format(date);

/// Data e ora, per gli elenchi che le presentano insieme (12.3, 12.2).
String formatDateAndTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final locale = _locale(context);
  return '${DateFormat.yMd(locale).format(local)}, ${DateFormat.Hm(locale).format(local)}';
}

/// Giorno e mese senza anno, per le didascalie di periodo (11.1).
String formatDayAndMonth(BuildContext context, DateTime date) =>
    DateFormat.MMMd(_locale(context)).format(date);

/// Giorno e mese in forma compatta, per le etichette degli assi (AD-14).
String formatDayAndMonthShort(BuildContext context, DateTime date) =>
    DateFormat.Md(_locale(context)).format(date);

/// Mese e anno per esteso (11.1: "Mese di …").
String formatMonthAndYear(BuildContext context, DateTime date) =>
    DateFormat.yMMMM(_locale(context)).format(date);

/// Il giorno del mese, per le celle del selettore della data (4.3).
String formatDayOfMonth(BuildContext context, DateTime date) =>
    DateFormat.d(_locale(context)).format(date);

/// LO-10: numero decimale con il separatore proprio della lingua, senza
/// decimali superflui — 72 anziché 72,0.
String formatDecimal(BuildContext context, double value, {int decimals = 1}) {
  final rounded = double.parse(value.toStringAsFixed(decimals));
  final format = rounded == rounded.roundToDouble()
      ? NumberFormat.decimalPattern(_locale(context))
      : (NumberFormat.decimalPattern(_locale(context))..maximumFractionDigits = decimals);
  return format.format(rounded);
}

/// LO-10: numero intero con il separatore delle migliaia proprio della
/// lingua.
String formatInteger(BuildContext context, int value) =>
    NumberFormat.decimalPattern(_locale(context)).format(value);
