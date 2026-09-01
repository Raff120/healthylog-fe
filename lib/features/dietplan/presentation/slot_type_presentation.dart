import 'package:flutter/material.dart';

import '../data/slot_type.dart';

/// Presentazione dei tipi di slot (GG-1): icona e denominazione, non
/// pertinenti al livello dati.
extension SlotTypePresentation on SlotType {
  IconData get icon => switch (this) {
        SlotType.breakfast => Icons.free_breakfast,
        SlotType.lunch => Icons.restaurant,
        SlotType.dinner => Icons.dinner_dining,
        SlotType.snack => Icons.cookie,
      };

  String get displayName => switch (this) {
        SlotType.breakfast => 'Colazione',
        SlotType.lunch => 'Pranzo',
        SlotType.dinner => 'Cena',
        SlotType.snack => 'Spuntino',
      };
}
