import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/plan_status.dart';

/// Denominazione dello stato del piano nella lingua selezionata (LO-1,
/// 3.6 funzionale).
String planStatusLabel(BuildContext context, PlanStatus status) => switch (status) {
      PlanStatus.draft => context.l10n.planStatusDraft,
      PlanStatus.scheduled => context.l10n.planStatusScheduled,
      PlanStatus.active => context.l10n.planStatusActive,
      PlanStatus.suspended => context.l10n.planStatusSuspended,
      PlanStatus.completed => context.l10n.planStatusCompleted,
    };
