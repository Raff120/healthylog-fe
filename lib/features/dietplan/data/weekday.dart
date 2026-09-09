/// Giorno-modello dello schema settimanale (OG-1). Rispecchia
/// `java.time.DayOfWeek` sul backend: stessa numerazione, lunedì primo.
///
/// Le denominazioni e le iniziali non sono qui ma in
/// `presentation/weekday_presentation.dart`: dipendono dalla lingua
/// selezionata (LO-1) e l'enumerativo non deve conoscerla.
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String toJson() => switch (this) {
        Weekday.monday => 'MONDAY',
        Weekday.tuesday => 'TUESDAY',
        Weekday.wednesday => 'WEDNESDAY',
        Weekday.thursday => 'THURSDAY',
        Weekday.friday => 'FRIDAY',
        Weekday.saturday => 'SATURDAY',
        Weekday.sunday => 'SUNDAY',
      };

  static Weekday fromJson(String value) => switch (value) {
        'TUESDAY' => Weekday.tuesday,
        'WEDNESDAY' => Weekday.wednesday,
        'THURSDAY' => Weekday.thursday,
        'FRIDAY' => Weekday.friday,
        'SATURDAY' => Weekday.saturday,
        'SUNDAY' => Weekday.sunday,
        _ => Weekday.monday,
      };
}
