import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../data/diet_plan.dart';
import '../data/diet_plan_template.dart';
import '../data/diet_plan_template_requests.dart';
import '../providers/diet_plan_template_providers.dart';
import 'slot_type_presentation.dart';
import 'widgets/name_description_dialog.dart';

/// Anteprima del template (7.4 interfaccia.md, CT-4, CT-5): schema
/// settimanale integrale, di sola lettura. In attesa di F16 (vista
/// settimanale), la disposizione è provvisoria — un elenco scorrevole dei
/// sette giorni anziché la griglia prevista da 7.4, che riuserà quella di
/// F16 quando esisterà (deciso con l'utente, vedi decisioni.md): anticipare
/// qui la griglia avrebbe anticipato quella feature.
class DietPlanTemplatePreviewScreen extends ConsumerWidget {
  const DietPlanTemplatePreviewScreen({super.key, required this.templateId});

  final String templateId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, DietPlanTemplate template) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Eliminare il template?'),
        content: Text('I piani già creati da "${template.name}" non ne risentono.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Elimina', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(deleteDietPlanTemplateControllerProvider.notifier).delete(templateId);
    final state = ref.read(deleteDietPlanTemplateControllerProvider);
    if (!context.mounted) return;
    if (state?.hasError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(state?.error?.asApiException?.code ?? ''))),
      );
      return;
    }
    context.pop();
  }

  /// TP-12: rinomina e modifica della descrizione, senza toccare lo
  /// schema (`updateSchedule`, azione distinta di "Modifica").
  Future<void> _rename(BuildContext context, WidgetRef ref, DietPlanTemplate template) async {
    final input = await showNameDescriptionDialog(
      context,
      title: 'Rinomina template',
      confirmLabel: 'Salva',
      initialName: template.name,
      initialDescription: template.description ?? '',
    );
    if (input == null) return;
    if (!context.mounted) return;
    await ref.read(updateDietPlanTemplateControllerProvider.notifier).update(
          templateId,
          UpdateDietPlanTemplateRequest(name: input.name, description: input.description),
        );
    final state = ref.read(updateDietPlanTemplateControllerProvider);
    if (!context.mounted) return;
    state?.whenOrNull(
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final previewState = ref.watch(dietPlanTemplatePreviewProvider(templateId));
    final deleting = ref.watch(deleteDietPlanTemplateControllerProvider)?.isLoading ?? false;
    // Tiene vivo il provider per la durata dell'operazione asincrona
    // (autoDispose lo eliminerebbe altrimenti fra un `ref.read` e
    // l'altro, dato che nessun altro punto lo osserva).
    final renaming = ref.watch(updateDietPlanTemplateControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          previewState.value?.name ?? 'Anteprima template',
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: [
          if (previewState.value != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _rename(context, ref, previewState.value!);
                if (value == 'delete') _confirmDelete(context, ref, previewState.value!);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', enabled: !renaming, child: const Text('Rinomina')),
                PopupMenuItem(
                  value: 'delete',
                  enabled: !deleting,
                  child: Text('Elimina', style: TextStyle(color: colors.error)),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: previewState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (template) => Column(
            children: [
              if (template.description != null && template.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      template.description!,
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    for (final day in template.weeklySchedule) _DayPreview(day: day),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/diet-plan-templates/$templateId/schedule'),
                          child: const Text('Modifica'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: AppPrimaryButton(
                          label: 'Usa questo template',
                          onPressed: () => context.pushReplacement('/diet-plans/new', extra: template),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayPreview extends StatelessWidget {
  const _DayPreview({required this.day});

  final DietPlanWeekDay day;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.dayOfWeek.label, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          if (day.slots.isEmpty)
            Text('Nessuno slot', style: typography.caption.copyWith(color: colors.textTertiary))
          else
            for (final slot in day.slots)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(slot.type.icon, size: 18, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.label?.isNotEmpty == true ? slot.label! : slot.type.displayName,
                            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                          ),
                          if (slot.content != null && slot.content!.isNotEmpty)
                            Text(
                              slot.content!,
                              style: typography.caption.copyWith(color: colors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
