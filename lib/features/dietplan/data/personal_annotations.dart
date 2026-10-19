import 'weekday.dart';

/// Il nome personale di un giorno dello schema (NP-4).
class PersonalDayName {
  const PersonalDayName({required this.week, required this.dayOfWeek, required this.name});

  factory PersonalDayName.fromJson(Map<String, dynamic> json) => PersonalDayName(
    week: (json['week'] as num).toInt(),
    dayOfWeek: Weekday.fromJson(json['dayOfWeek'] as String),
    name: json['name'] as String,
  );

  final int week;
  final Weekday dayOfWeek;
  final String name;
}

/// La nota personale di uno slot dello schema (NP-4).
class PersonalSlotNote {
  const PersonalSlotNote({required this.slotId, required this.note});

  factory PersonalSlotNote.fromJson(Map<String, dynamic> json) =>
      PersonalSlotNote(slotId: json['slotId'] as String, note: json['note'] as String);

  final String slotId;
  final String note;
}

/// Rispecchia `PersonalAnnotationsResponse` sul backend (CO-19, EP-12):
/// le annotazioni personali del piano, riferite allo schema e non alle
/// date, limitate a quel che lo schema ancora contiene (NP-6).
class PersonalAnnotations {
  const PersonalAnnotations({this.planNote, this.dayNames = const [], this.slotNotes = const []});

  factory PersonalAnnotations.fromJson(Map<String, dynamic> json) => PersonalAnnotations(
    planNote: json['planNote'] as String?,
    dayNames: [
      for (final item in json['dayNames'] as List? ?? const [])
        if (Weekday.tryFromJson((item as Map<String, dynamic>)['dayOfWeek'] as String) != null)
          PersonalDayName.fromJson(item),
    ],
    slotNotes: [
      for (final item in json['slotNotes'] as List? ?? const [])
        PersonalSlotNote.fromJson(item as Map<String, dynamic>),
    ],
  );

  final String? planNote;
  final List<PersonalDayName> dayNames;
  final List<PersonalSlotNote> slotNotes;

  bool get isEmpty => planNote == null && slotNotes.isEmpty;

  String? dayName(int week, Weekday dayOfWeek) {
    for (final dayName in dayNames) {
      if (dayName.week == week && dayName.dayOfWeek == dayOfWeek) return dayName.name;
    }
    return null;
  }

  String? slotNote(String slotId) {
    for (final slotNote in slotNotes) {
      if (slotNote.slotId == slotId) return slotNote.note;
    }
    return null;
  }
}
