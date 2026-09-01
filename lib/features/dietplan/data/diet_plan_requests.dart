import 'slot_type.dart';
import 'weekday.dart';

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Corpo di `POST /diet-plans` (CD-1, CD-4; CT-1, CT-10 per la derivazione
/// da template). `sourceTemplateId` assente crea da zero, valorizzato
/// deriva da un template proprio.
class CreateDietPlanRequest {
  const CreateDietPlanRequest({
    required this.name,
    required this.startDate,
    this.endDate,
    this.sourceTemplateId,
  });

  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String? sourceTemplateId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': _isoDate(startDate),
        'endDate': endDate == null ? null : _isoDate(endDate!),
        'sourceTemplateId': sourceTemplateId,
      };
}

/// Corpo di `POST /diet-plans/{id}/save-as-template` (TP-5, CD-18).
class SaveDietPlanAsTemplateRequest {
  const SaveDietPlanAsTemplateRequest({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// Uno slot nel corpo di `PUT /diet-plans/{id}/schedule` (CD-7, CD-8).
/// `slotId` assente per uno slot appena aggiunto (CO-7).
class UpdateDietPlanSlotRequest {
  const UpdateDietPlanSlotRequest({
    this.slotId,
    required this.type,
    this.label,
    this.content,
    this.note,
    this.recipeName,
    this.recipeText,
    this.adherenceWeight,
  });

  final String? slotId;
  final SlotType type;
  final String? label;
  final String? content;
  final String? note;
  final String? recipeName;
  final String? recipeText;
  final double? adherenceWeight;

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'type': type.toJson(),
        'label': label,
        'content': content,
        'note': note,
        'recipeName': recipeName,
        'recipeText': recipeText,
        'adherenceWeight': adherenceWeight,
      };
}

class UpdateDietPlanWeekDayRequest {
  const UpdateDietPlanWeekDayRequest({required this.dayOfWeek, required this.slots});

  final Weekday dayOfWeek;
  final List<UpdateDietPlanSlotRequest> slots;

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek.toJson(),
        'slots': slots.map((e) => e.toJson()).toList(),
      };
}

/// Corpo di `PUT /diet-plans/{id}/schedule`: sostituzione integrale dello
/// schema settimanale (ML-1).
class UpdateWeeklyScheduleRequest {
  const UpdateWeeklyScheduleRequest({required this.days});

  final List<UpdateDietPlanWeekDayRequest> days;

  Map<String, dynamic> toJson() => {'days': days.map((e) => e.toJson()).toList()};
}
