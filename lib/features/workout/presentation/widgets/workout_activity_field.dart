import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_activity.dart';
import '../workout_activity_presentation.dart';

/// AL-2, 10.2 interfaccia.md: lo sport si sceglie da un elenco, non si
/// scrive. Il campo ne presenta icona e denominazione e apre il selettore
/// al tocco; l'attività che l'elenco non prevede vi figura col nome che
/// l'Utente le ha dato.
class WorkoutActivityField extends StatelessWidget {
  const WorkoutActivityField({
    super.key,
    required this.activity,
    required this.customName,
    required this.errorText,
    required this.onTap,
  });

  final WorkoutActivity? activity;
  final String? customName;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final chosen = activity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: AppSpacing.heightTextField,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: hasError ? colors.error : colors.dividerStrong),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  chosen == null ? Icons.sports_outlined : workoutActivityIcon(chosen),
                  size: 18,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    chosen == null
                        ? context.l10n.workoutActivityType
                        : workoutActivityName(context, chosen, customName),
                    style: typography.bodyMedium.copyWith(
                      color: chosen == null ? colors.textTertiary : colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.expand_more, size: 18, color: colors.textSecondary),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(errorText!, style: typography.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}
