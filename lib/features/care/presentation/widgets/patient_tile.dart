import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../dietplan/data/plan_status.dart';
import '../../data/care_models.dart';

/// Voce dell'elenco dei Pazienti (9.1 interfaccia.md): avatar, nome e
/// cognome, piano in corso e stato, aderenza e ultima attività. VA-3: il
/// Paziente che segue un piano non redatto dal Nutrizionista compare
/// privo di indicatori — un tratto in colore terziario al posto dei
/// valori, senza spiegarne la ragione. VA-5: l'aderenza è un numero
/// neutro, senza colorazione o soglia.
class PatientTile extends StatelessWidget {
  const PatientTile({super.key, required this.patient, required this.onTap, this.selected = false});

  final PatientSummary patient;
  final VoidCallback onTap;
  final bool selected;

  String _planLabel(PatientPlanSummary plan) {
    final status = switch (plan.status) {
      PlanStatus.active => 'in corso',
      PlanStatus.suspended => 'sospeso',
      PlanStatus.scheduled => 'programmato',
      PlanStatus.draft => 'bozza',
      PlanStatus.completed => 'concluso',
    };
    return '${plan.name} · $status';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final plan = patient.currentPlan;
    final dash = Text('—', style: typography.caption.copyWith(color: colors.textTertiary));

    return Material(
      color: selected ? colors.accentSubtle : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.surfaceAlt,
                child: Icon(Icons.person_outline, color: colors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                    plan == null
                        ? dash
                        : Text(
                            _planLabel(plan),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(color: colors.textSecondary),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  patient.adherence == null
                      ? dash
                      : Text(
                          '${patient.adherence!.round()}%',
                          style: typography.label.copyWith(color: colors.textPrimary),
                        ),
                  patient.lastActivityAt == null
                      ? dash
                      : Text(
                          _formatDate(patient.lastActivityAt!),
                          style: typography.caption.copyWith(color: colors.textTertiary),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
