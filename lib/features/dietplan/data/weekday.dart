/// Giorno-modello dello schema settimanale (OG-1). Rispecchia
/// `java.time.DayOfWeek` sul backend: stessa numerazione, lunedì primo.
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

  /// Iniziale del selettore dei giorni (7.3 interfaccia.md).
  String get initial => switch (this) {
        Weekday.monday => 'L',
        Weekday.tuesday => 'M',
        Weekday.wednesday => 'M',
        Weekday.thursday => 'G',
        Weekday.friday => 'V',
        Weekday.saturday => 'S',
        Weekday.sunday => 'D',
      };

  String get label => switch (this) {
        Weekday.monday => 'Lunedì',
        Weekday.tuesday => 'Martedì',
        Weekday.wednesday => 'Mercoledì',
        Weekday.thursday => 'Giovedì',
        Weekday.friday => 'Venerdì',
        Weekday.saturday => 'Sabato',
        Weekday.sunday => 'Domenica',
      };
}
