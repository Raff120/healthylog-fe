import 'plan_day_coverage.dart';
import 'slot_item.dart';
import 'slot_status.dart';
import 'slot_type.dart';

/// Rispecchia `PlanDaySlotResponse` sul backend (OG-2).
class PlanDaySlot {
  const PlanDaySlot({
    required this.slotId,
    required this.type,
    required this.label,
    required this.order,
    required this.items,
    required this.note,
    required this.status,
    required this.replacementNote,
    this.statusChangedBy,
    this.personalNote,
  });

  factory PlanDaySlot.fromJson(Map<String, dynamic> json) => PlanDaySlot(
    slotId: json['slotId'] as String,
    type: SlotType.fromJson(json['type'] as String),
    label: json['label'] as String?,
    order: json['order'] as int,
    items: slotItemsFromJson(json['items']),
    note: json['note'] as String?,
    status: SlotStatus.fromJson(json['status'] as String),
    replacementNote: json['replacementNote'] as String?,
    statusChangedBy: json['statusChangedBy'] as String?,
    personalNote: json['personalNote'] as String?,
  );

  /// VR-10: `null` se tipo o stato non sono noti a questa versione del
  /// client — la giornata che lo contiene ne omette lo slot.
  static PlanDaySlot? tryFromJson(Map<String, dynamic> json) =>
      SlotType.tryFromJson(json['type'] as String) == null ||
              SlotStatus.tryFromJson(json['status'] as String) == null
          ? null
          : PlanDaySlot.fromJson(json);

  final String slotId;
  final SlotType type;
  final String? label;
  final int order;
  /// Elementi copiati dallo schema alla materializzazione (GG-19, OG-8).
  final List<SlotItem> items;
  final String? note;
  final SlotStatus status;

  /// Valorizzata solo se [status] è [SlotStatus.skipped] (SC-4). Assente
  /// dal JSON quando questo modello rispecchia la proiezione riservata a
  /// Cuoco e Nutrizionista (SC-12, SC-13, `PlanDaySlotForOthersResponse`
  /// sul backend) — [PlanDaySlot.fromJson] legge in tal caso il campo
  /// assente come `null`, la stessa forma di uno slot mai in Saltato.
  final String? replacementNote;

  /// CU-4 (F20): l'autore dell'ultima spunta, `null` finché nessuno ha
  /// ancora agito sullo slot. Presente solo nella vista del proprietario
  /// (non nella proiezione riservata ad altri).
  final String? statusChangedBy;

  /// NP-1, CO-19: la nota personale del proprietario sul contenuto dello
  /// slot, già risolta dal server sull'origine del contenuto. Presente
  /// solo nella vista del proprietario (NP-2).
  final String? personalNote;

  /// Per la cache locale di sola lettura (PL-6, F14): mai inviato al
  /// backend, che ha le proprie rappresentazioni dedicate in scrittura
  /// (`UpdatePlanDaySlotStatusRequest`).
  Map<String, dynamic> toJson() => {
    'slotId': slotId,
    'type': type.toJson(),
    'label': label,
    'order': order,
    'items': items.map((e) => e.toJson()).toList(),
    'note': note,
    'status': status.toJson(),
    'replacementNote': replacementNote,
    'statusChangedBy': statusChangedBy,
    'personalNote': personalNote,
  };
}

/// Rispecchia `PlanDayResponse` sul backend (6.1 funzionale, EP-3).
/// `planId`/`planName`/`planStartDate`/`planEndDate` sono `null` quando
/// `coverage` è [PlanDayCoverage.none] (PA-10).
class PlanDay {
  const PlanDay({
    required this.date,
    required this.coverage,
    required this.planId,
    required this.planName,
    required this.planStartDate,
    required this.planEndDate,
    required this.slots,
    this.dayName,
  });

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
    date: DateTime.parse(json['date'] as String),
    coverage: PlanDayCoverage.fromJson(json['coverage'] as String),
    planId: json['planId'] as String?,
    planName: json['planName'] as String?,
    planStartDate: json['planStartDate'] == null
        ? null
        : DateTime.parse(json['planStartDate'] as String),
    planEndDate: json['planEndDate'] == null
        ? null
        : DateTime.parse(json['planEndDate'] as String),
    slots: (json['slots'] as List)
        .map((e) => PlanDaySlot.tryFromJson(e as Map<String, dynamic>))
        .nonNulls
        .toList(),
    dayName: json['dayName'] as String?,
  );

  final DateTime date;
  final PlanDayCoverage coverage;
  final String? planId;
  final String? planName;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final List<PlanDaySlot> slots;

  /// NP-1, CO-19: il nome personale della giornata, risolto dal server sul
  /// giorno dello schema da cui viene il contenuto. Solo nella vista del
  /// proprietario (NP-2), e non conservato dalla cache locale.
  final String? dayName;
}
