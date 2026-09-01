import 'package:flutter/widgets.dart';

import '../data/diet_plan.dart';
import '../data/diet_plan_requests.dart';
import '../data/slot_type.dart';
import '../data/weekday.dart';

/// Stato di redazione di uno slot (7.3 interfaccia.md, CD-7, CD-8), non
/// persistito finché non arriva il salvataggio esplicito (CD-10). Un
/// oggetto mutabile, non un modello immutabile: possiede i controller di
/// testo dei propri campi, sul modello già seguito dalle schermate di
/// modulo della feature identity (un controller per campo, non un `Form`).
class EditableSlot {
  EditableSlot({
    this.slotId,
    required this.type,
    String label = '',
    String content = '',
    String note = '',
    String recipeName = '',
    String recipeText = '',
    required this.adherenceWeight,
    this.expanded = false,
  })  : labelController = TextEditingController(text: label),
        contentController = TextEditingController(text: content),
        noteController = TextEditingController(text: note),
        recipeNameController = TextEditingController(text: recipeName),
        recipeTextController = TextEditingController(text: recipeText);

  factory EditableSlot.fromSlot(DietPlanSlot slot) => EditableSlot(
        slotId: slot.slotId,
        type: slot.type,
        label: slot.label ?? '',
        content: slot.content ?? '',
        note: slot.note ?? '',
        recipeName: slot.recipeName ?? '',
        recipeText: slot.recipeText ?? '',
        adherenceWeight: slot.adherenceWeight,
      );

  /// GG-3, AD-5bis: un nuovo spuntino/pasto riceve lo stesso peso
  /// predefinito applicato dal backend alla composizione iniziale — non
  /// duplicato per un valore diverso, in attesa del salvataggio.
  factory EditableSlot.newSlot(SlotType type) => EditableSlot(
        type: type,
        adherenceWeight: type == SlotType.snack ? 0.5 : 1.0,
        expanded: true,
      );

  /// `null`: slot appena aggiunto, non ancora salvato (CO-7). Un
  /// identificativo esistente è conservato attraverso i salvataggi
  /// successivi.
  final String? slotId;
  final SlotType type;
  final TextEditingController labelController;
  final TextEditingController contentController;
  final TextEditingController noteController;
  final TextEditingController recipeNameController;
  final TextEditingController recipeTextController;
  double adherenceWeight;
  bool expanded;

  /// Errore di campo riportato dall'ultimo salvataggio (GG-15), se
  /// presente: un testo di ricetta senza denominazione.
  String? recipeNameError;

  /// CD-14: uno slot privo di contenuto è previsto ma non specificato —
  /// concorre alla segnalazione di incompletezza del giorno (CD-15).
  bool get isEmpty => contentController.text.trim().isEmpty;

  void dispose() {
    labelController.dispose();
    contentController.dispose();
    noteController.dispose();
    recipeNameController.dispose();
    recipeTextController.dispose();
  }

  UpdateDietPlanSlotRequest toRequest() => UpdateDietPlanSlotRequest(
        slotId: slotId,
        type: type,
        label: type == SlotType.snack && labelController.text.trim().isNotEmpty
            ? labelController.text.trim()
            : null,
        content: contentController.text.trim().isEmpty ? null : contentController.text.trim(),
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        recipeName: recipeNameController.text.trim().isEmpty ? null : recipeNameController.text.trim(),
        recipeText: recipeTextController.text.trim().isEmpty ? null : recipeTextController.text.trim(),
        adherenceWeight: adherenceWeight,
      );
}

/// Giorno-modello in redazione (OG-1): il proprio giorno della settimana e
/// gli slot che lo compongono in quel momento.
class EditableDay {
  EditableDay({required this.dayOfWeek, required this.slots});

  factory EditableDay.fromWeekDay(DietPlanWeekDay day) => EditableDay(
        dayOfWeek: day.dayOfWeek,
        slots: day.slots.map(EditableSlot.fromSlot).toList(),
      );

  final Weekday dayOfWeek;
  final List<EditableSlot> slots;

  /// CD-15: l'unica segnalazione di incompletezza ammessa (7.3
  /// interfaccia.md) — un giorno privo di slot non è incompleto (GG-7).
  bool get hasIncompleteSlot => slots.any((slot) => slot.isEmpty);

  bool hasType(SlotType type) => slots.any((slot) => slot.type == type);

  UpdateDietPlanWeekDayRequest toRequest() =>
      UpdateDietPlanWeekDayRequest(dayOfWeek: dayOfWeek, slots: slots.map((slot) => slot.toRequest()).toList());

  void dispose() {
    for (final slot in slots) {
      slot.dispose();
    }
  }
}
