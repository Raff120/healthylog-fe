import 'package:flutter/material.dart';

import '../../../l10n/l10n_context.dart';
import '../data/slot_type.dart';

/// Icone dei tipi di pasto (2.5 interfaccia.md). Le icone Material sono
/// le più prossime alle Lucide indicate (coffee, utensils,
/// utensils-crossed, apple).
extension SlotTypePresentation on SlotType {
  IconData get icon => switch (this) {
        SlotType.breakfast => Icons.free_breakfast,
        SlotType.lunch => Icons.restaurant,
        SlotType.dinner => Icons.dinner_dining,
        SlotType.snack => Icons.cookie,
      };
}

/// Denominazione del tipo di pasto nella lingua selezionata (LO-1). Non è
/// più un getter dell'enumerativo: la traduzione richiede il contesto, e
/// l'enumerativo — che rispecchia il backend — non deve conoscerlo.
String slotTypeLabel(BuildContext context, SlotType type) => switch (type) {
      SlotType.breakfast => context.l10n.slotTypeBreakfast,
      SlotType.lunch => context.l10n.slotTypeLunch,
      SlotType.dinner => context.l10n.slotTypeDinner,
      SlotType.snack => context.l10n.slotTypeSnack,
    };
