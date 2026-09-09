import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
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

  /// 9.1: il piano è presentato con il proprio stato in minuscolo, che
  /// segue la denominazione e non la introduce.
  String _planLabel(BuildContext context, PatientPlanSummary plan) {
    final l10n = context.l10n;
    final status = switch (plan.status) {
      PlanStatus.active => l10n.planStatusLowerActive,
      PlanStatus.suspended => l10n.planStatusLowerSuspended,
      PlanStatus.scheduled => l10n.planStatusLowerScheduled,
      PlanStatus.draft => l10n.planStatusLowerDraft,
      PlanStatus.completed => l10n.planStatusLowerCompleted,
    };
    return l10n.patientPlanWithStatus(plan.name, status);
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
                            _planLabel(context, plan),
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
