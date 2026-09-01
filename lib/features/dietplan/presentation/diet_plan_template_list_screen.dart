import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/diet_plan_template.dart';
import '../data/diet_plan_template_requests.dart';
import '../providers/diet_plan_template_providers.dart';

/// Elenco dei template (7.4 interfaccia.md, CT-2, CT-3): raggiunto per ora
/// da un punto d'accesso provvisorio (nessuna schermata "Piani" esiste
/// ancora, vedi decisioni.md) e dalla scelta "Da un template" in 7.2. Il
/// tocco su una voce apre l'anteprima (CT-6).
class DietPlanTemplateListScreen extends ConsumerWidget {
  const DietPlanTemplateListScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    await ref.read(createDietPlanTemplateControllerProvider.notifier).create(
          const CreateDietPlanTemplateRequest(name: 'Nuovo template'),
        );
    final state = ref.read(createDietPlanTemplateControllerProvider);
    if (!context.mounted || state == null) return;
    state.whenOrNull(
      data: (template) => context.pushReplacement('/diet-plan-templates/${template.id}/schedule'),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final listState = ref.watch(dietPlanTemplateListProvider);
    final creating = ref.watch(createDietPlanTemplateControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Template', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: creating ? null : () => _create(context, ref),
        child: creating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add),
      ),
      body: SafeArea(
        child: listState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (templates) {
            if (templates.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Nessun template. Crealo con il pulsante in basso.',
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              itemCount: templates.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateTile(
                  template: template,
                  updatedAtLabel: _formatDate(template.updatedAt),
                  onTap: () => context.push('/diet-plan-templates/${template.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.updatedAtLabel, required this.onTap});

  final DietPlanTemplateSummary template;
  final String updatedAtLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final description = template.description;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(template.name, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(description, style: typography.caption.copyWith(color: colors.textSecondary)),
              ],
              const SizedBox(height: AppSpacing.xxs),
              Text('Ultima modifica: $updatedAtLabel', style: typography.caption.copyWith(color: colors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
