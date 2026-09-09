import 'package:flutter/material.dart';

import '../../../../core/widgets/app_segmented_control.dart';
import '../../providers/plan_day_providers.dart';

/// Segmented control *Giorno* · *Settimana* (6.1 interfaccia.md): unico
/// comando delle due granularità di *Piano*. La forma è quella comune di
/// [AppSegmentedControl], condivisa con *Attività* (10.1).
class SegmentedViewControl extends StatelessWidget {
  const SegmentedViewControl({super.key, required this.value, required this.onChanged});

  final PlanViewMode value;
  final ValueChanged<PlanViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSegmentedControl(
      firstLabel: 'Giorno',
      secondLabel: 'Settimana',
      firstSelected: value == PlanViewMode.day,
      onSelectFirst: () => onChanged(PlanViewMode.day),
      onSelectSecond: () => onChanged(PlanViewMode.week),
    );
  }
}
