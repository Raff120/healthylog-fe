import 'package:flutter/widgets.dart';

import '../data/diet_plan.dart';
import '../data/diet_plan_requests.dart';
import '../data/plan_day.dart';
import '../data/slot_item.dart';
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
    String note = '',
    List<EditableItem>? items,
    required this.adherenceWeight,
    this.expanded = false,
  })  : labelController = TextEditingController(text: label),
        noteController = TextEditingController(text: note),
        items = items ?? [];

  factory EditableSlot.fromSlot(DietPlanSlot slot) => EditableSlot(
        slotId: slot.slotId,
        type: slot.type,
        label: slot.label ?? '',
        note: slot.note ?? '',
        items: slot.items.map(EditableItem.fromModel).toList(),
        adherenceWeight: slot.adherenceWeight,
      );

  /// MD-8: lo slot di un'occorrenza giornaliera, per la modifica della
  /// sola giornata — stessi campi dello schema, più lo stato di consumo
  /// che la modifica non tocca (MD-3, MD-4).
  factory EditableSlot.fromPlanDaySlot(PlanDaySlot slot) => EditableSlot(
        slotId: slot.slotId,
        type: slot.type,
        label: slot.label ?? '',
        note: slot.note ?? '',
        items: slot.items.map(EditableItem.fromModel).toList(),
        // AD-5: il peso dell'occorrenza non transita nella risposta della
        // giornata e la modifica della sola giornata non lo tocca: il
        // backend conserva quello dello slot esistente e applica il
        // predefinito a uno nuovo — il valore inviato qui è ignorato per
        // gli slot esistenti.
        adherenceWeight: slot.type == SlotType.snack ? 0.5 : 1.0,
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
  final TextEditingController noteController;

  /// GG-11, GG-21: gli elementi nell'ordine in cui vanno presentati.
  final List<EditableItem> items;
  double adherenceWeight;
  bool expanded;

  /// CD-14: uno slot privo di elementi è previsto ma non specificato —
  /// concorre alla segnalazione di incompletezza del giorno (CD-15, GG-13).
  bool get isEmpty => items.isEmpty;

  void dispose() {
    labelController.dispose();
    noteController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }

  UpdateDietPlanSlotRequest toRequest() => UpdateDietPlanSlotRequest(
        slotId: slotId,
        type: type,
        label: type == SlotType.snack && labelController.text.trim().isNotEmpty
            ? labelController.text.trim()
            : null,
        items: items.map((item) => item.toModel()).toList(),
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        adherenceWeight: adherenceWeight,
      );
}

/// Redazione di un elemento e delle sue alternative (7.3 interfaccia.md,
/// GG-12, GG-22, GG-25). Come [EditableSlot] sono oggetti mutabili che
/// possiedono i controller dei propri campi di testo.
///
/// La quantità non è un controller ma un dato: il campo che la raccoglie la
/// presenta col separatore della lingua (LO-10) e la riscrive qui appena
/// cambia, cosicché il modello resti indipendente dalla lingua in cui è
/// scritta.
class EditableAlternative {
  EditableAlternative({
    this.kindCode = 'FOOD',
    String name = '',
    this.quantity,
    this.unitCode,
    String recipeText = '',
  })  : nameController = TextEditingController(text: name),
        recipeTextController = TextEditingController(text: recipeText);

  factory EditableAlternative.fromModel(SlotItemAlternative alternative) => EditableAlternative(
        kindCode: alternative.kindCode,
        name: alternative.name,
        quantity: alternative.quantity,
        unitCode: alternative.unitCode,
        recipeText: alternative.recipeText ?? '',
      );

  String kindCode;
  final TextEditingController nameController;
  num? quantity;
  String? unitCode;
  final TextEditingController recipeTextController;

  /// Errori riportati dall'ultimo salvataggio, per campo (ER-14).
  final Map<String, String> errors = {};

  bool get isRecipe => kindCode == SlotItemKind.recipe.toJson();

  SlotItemAlternative toModel() => SlotItemAlternative(
        kindCode: kindCode,
        name: nameController.text.trim(),
        quantity: isRecipe ? null : quantity,
        unitCode: isRecipe ? null : unitCode,
        recipeText: isRecipe && recipeTextController.text.trim().isNotEmpty
            ? recipeTextController.text.trim()
            : null,
      );

  void dispose() {
    nameController.dispose();
    recipeTextController.dispose();
  }
}

class EditableItem {
  EditableItem({
    this.itemId,
    this.kindCode = 'FOOD',
    String name = '',
    this.quantity,
    this.unitCode,
    String recipeText = '',
    List<EditableAlternative>? alternatives,
    this.expanded = false,
  })  : nameController = TextEditingController(text: name),
        recipeTextController = TextEditingController(text: recipeText),
        alternatives = alternatives ?? [];

  factory EditableItem.fromModel(SlotItem item) => EditableItem(
        itemId: item.itemId,
        kindCode: item.kindCode,
        name: item.name,
        quantity: item.quantity,
        unitCode: item.unitCode,
        recipeText: item.recipeText ?? '',
        alternatives: item.alternatives.map(EditableAlternative.fromModel).toList(),
      );

  /// CO-7bis: `null` per un elemento appena aggiunto, cui l'identificativo lo
  /// assegna il sistema al salvataggio.
  final String? itemId;
  String kindCode;
  final TextEditingController nameController;
  num? quantity;
  String? unitCode;
  final TextEditingController recipeTextController;
  final List<EditableAlternative> alternatives;
  bool expanded;

  final Map<String, String> errors = {};

  bool get isRecipe => kindCode == SlotItemKind.recipe.toJson();

  /// Un elemento appena aggiunto e non ancora compilato: si rimuove senza
  /// chiedere conferma (7.3).
  bool get isBlank =>
      nameController.text.trim().isEmpty &&
      quantity == null &&
      recipeTextController.text.trim().isEmpty &&
      alternatives.isEmpty;

  SlotItem toModel() => SlotItem(
        itemId: itemId,
        kindCode: kindCode,
        name: nameController.text.trim(),
        quantity: isRecipe ? null : quantity,
        unitCode: isRecipe ? null : unitCode,
        recipeText: isRecipe && recipeTextController.text.trim().isNotEmpty
            ? recipeTextController.text.trim()
            : null,
        alternatives: alternatives.map((alternative) => alternative.toModel()).toList(),
      );

  void dispose() {
    nameController.dispose();
    recipeTextController.dispose();
    for (final alternative in alternatives) {
      alternative.dispose();
    }
  }
}

/// Giorno-modello in redazione (OG-1): la settimana del ciclo e il giorno
/// della settimana cui appartiene, e gli slot che lo compongono in quel
/// momento.
class EditableDay {
  EditableDay({this.week = DietPlanWeekDay.firstWeek, required this.dayOfWeek, required this.slots});

  factory EditableDay.fromWeekDay(DietPlanWeekDay day) => EditableDay(
        week: day.week,
        dayOfWeek: day.dayOfWeek,
        slots: day.slots.map(EditableSlot.fromSlot).toList(),
      );

  /// Settimana del ciclo (OG-1bis). Mutabile: la rimozione di una
  /// settimana fa scalare di un posto le successive (7.3 interfaccia).
  int week;
  final Weekday dayOfWeek;
  final List<EditableSlot> slots;

  /// CD-15: l'unica segnalazione di incompletezza ammessa (7.3
  /// interfaccia.md) — un giorno privo di slot non è incompleto (GG-7).
  bool get hasIncompleteSlot => slots.any((slot) => slot.isEmpty);

  bool hasType(SlotType type) => slots.any((slot) => slot.type == type);

  UpdateDietPlanWeekDayRequest toRequest() =>
      UpdateDietPlanWeekDayRequest(
          week: week, dayOfWeek: dayOfWeek, slots: slots.map((slot) => slot.toRequest()).toList());

  void dispose() {
    for (final slot in slots) {
      slot.dispose();
    }
  }
}
