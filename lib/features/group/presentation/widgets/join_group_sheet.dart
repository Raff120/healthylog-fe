import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/invite_code.dart';
import '../../providers/cooking_group_providers.dart';

/// GR-9, GR-10: foglio modale con il campo del codice di invito (8.1
/// interfaccia.md). Un codice valido presenta, nello stesso foglio, la
/// schermata di conferma che espone denominazione e numero di membri del
/// Gruppo prima dell'adesione effettiva — nessun'adesione senza un atto
/// esplicito successivo alla sola digitazione del codice.
///
/// Restituisce `true` se l'adesione è avvenuta.
Future<bool> showJoinGroupSheet(BuildContext context) async {
  final joined = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _JoinGroupSheet(),
  );
  return joined ?? false;
}

class _JoinGroupSheet extends ConsumerStatefulWidget {
  const _JoinGroupSheet();

  @override
  ConsumerState<_JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends ConsumerState<_JoinGroupSheet> {
  final _codeController = TextEditingController();
  InviteCodePreview? _preview;
  bool _loadingPreview = false;
  String? _codeError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _lookUpCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loadingPreview = true;
      _codeError = null;
    });
    try {
      final preview = await ref.read(inviteCodePreviewProvider(code).future);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _loadingPreview = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPreview = false;
        _codeError = describeApiError(context, error.asApiException?.code ?? '');
      });
    }
  }

  Future<void> _confirmJoin() async {
    final code = _codeController.text.trim();
    await ref.read(joinCookingGroupControllerProvider.notifier).join(code);
    if (!mounted) return;
    final state = ref.read(joinCookingGroupControllerProvider);
    state?.whenOrNull(
      data: (_) => Navigator.of(context).pop(true),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final joining = ref.watch(joinCookingGroupControllerProvider)?.isLoading ?? false;
    final preview = _preview;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: preview == null
              ? [
                  Text('Entra con un codice', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Codice di invito',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    errorText: _codeError,
                    onChanged: (_) => setState(() => _codeError = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppPrimaryButton(
                    label: 'Continua',
                    loading: _loadingPreview,
                    onPressed: _codeController.text.trim().isEmpty ? null : _lookUpCode,
                  ),
                ]
              : [
                  Text(preview.groupName, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${preview.memberCount} ${preview.memberCount == 1 ? 'membro' : 'membri'}',
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'I tuoi pasti diventeranno visibili agli altri membri, e i Cuochi potranno operare '
                    'inversioni e spunte sul tuo piano.',
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(label: 'Conferma adesione', loading: joining, onPressed: _confirmJoin),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextButton(
                      onPressed: joining ? null : () => setState(() => _preview = null),
                      child: const Text('Indietro'),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
