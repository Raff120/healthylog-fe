import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/cooking_group_requests.dart';

const _defaultExpiryDays = 7;

/// GR-8: foglio con le due impostazioni facoltative del codice —
/// scadenza (predefinita a sette giorni, disattivabile) e numero massimo
/// di utilizzi (predefinito illimitato) — 8.3 interfaccia.md.
Future<GenerateInviteCodeRequest?> showGenerateInviteCodeSheet(BuildContext context) {
  return showModalBottomSheet<GenerateInviteCodeRequest>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _GenerateInviteCodeSheet(),
  );
}

class _GenerateInviteCodeSheet extends StatefulWidget {
  const _GenerateInviteCodeSheet();

  @override
  State<_GenerateInviteCodeSheet> createState() => _GenerateInviteCodeSheetState();
}

class _GenerateInviteCodeSheetState extends State<_GenerateInviteCodeSheet> {
  bool _hasExpiry = true;
  final _maxUsesController = TextEditingController();

  @override
  void dispose() {
    _maxUsesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final maxUsesText = _maxUsesController.text.trim();
    Navigator.of(context).pop(
      GenerateInviteCodeRequest(
        expiresAt: _hasExpiry ? DateTime.now().add(const Duration(days: _defaultExpiryDays)) : null,
        maxUses: maxUsesText.isEmpty ? null : int.tryParse(maxUsesText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;

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
          children: [
            Text(context.l10n.inviteGenerate, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _hasExpiry,
              onChanged: (value) => setState(() => _hasExpiry = value),
              title: const Text('Scadenza'),
              subtitle: Text(
                _hasExpiry ? context.l10n.inviteExpiresInDays(_defaultExpiryDays) : context.l10n.inviteNoExpiry,
                style: typography.caption.copyWith(color: colors.textSecondary),
              ),
              activeTrackColor: colors.accent,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: context.l10n.inviteMaxUses,
              controller: _maxUsesController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(label: 'Genera', onPressed: _confirm),
          ],
        ),
      ),
    );
  }
}
