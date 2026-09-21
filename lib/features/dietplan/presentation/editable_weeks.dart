import '../data/diet_plan.dart';
import 'editable_slot.dart';

/// Le settimane dello schema in redazione (PA-2, PA-2bis, 7.3
/// interfaccia.md), sull'elenco piatto dei giorni che la redazione tiene —
/// la medesima forma della risposta e della richiesta (OG-1bis). Comuni
/// alla redazione del piano e a quella del template, che la tecnica vuole
/// identiche (TP-4).
extension EditableWeeks on List<EditableDay> {
  /// OG-1bis: le settimane sono quelle che i giorni recano. Almeno una.
  int get weekCount => fold(DietPlanWeekDay.firstWeek, (count, day) => day.week > count ? day.week : count);

  bool get canAddWeek => weekCount < DietPlanWeekDay.maxWeeks;

  bool get canRemoveWeek => weekCount > DietPlanWeekDay.firstWeek;

  /// I sette giorni della settimana [week], nell'ordine in cui la redazione
  /// li tiene.
  List<EditableDay> daysOfWeek(int week) => where((day) => day.week == week).toList();

  bool weekHasIncompleteSlot(int week) => any((day) => day.week == week && day.hasIncompleteSlot);

  /// 7.3 interfaccia: la settimana aggiunta è una copia di [week], accodata
  /// in fondo. Restituisce il numero della nuova.
  int appendCopyOfWeek(int week) {
    final added = weekCount + 1;
    addAll(daysOfWeek(week).map((day) => EditableDay(
          week: added,
          dayOfWeek: day.dayOfWeek,
          slots: day.slots.map(EditableSlot.copyOf).toList(),
        )));
    return added;
  }

  /// 7.3 interfaccia: toglie la settimana [week] e fa scalare di un posto
  /// le successive, perché restino contigue (OG-1bis). I giorni tolti sono
  /// rilasciati.
  void removeWeek(int week) {
    final removed = daysOfWeek(week);
    removeWhere((day) => day.week == week);
    for (final day in removed) {
      day.dispose();
    }
    for (final day in this) {
      if (day.week > week) day.week -= 1;
    }
  }
}
