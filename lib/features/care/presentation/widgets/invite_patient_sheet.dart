import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../data/care_models.dart';
import '../../providers/care_providers.dart';

/// 9.3 interfaccia.md, "Invito": foglio modale con il solo campo del
/// nome utente, a corrispondenza esatta (CP-1, CP-2) — nessun elenco di
/// risultati, nessuna ricerca parziale. Trovato: card con nome e
/// cognome e campo per il messaggio (CP-3); non trovato: stato vuoto
/// che non distingue tra utente inesistente e nome errato.
///
/// Restituisce `true` se la richiesta è stata inviata.
Future<bool> showInvitePatientSheet(BuildContext context) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _InvitePatientSheet(),
  );
  return sent ?? false;
}

class _InvitePatientSheet extends ConsumerStatefulWidget {
  const _InvitePatientSheet();

  @override
  ConsumerState<_InvitePatientSheet> createState() => _InvitePatientSheetState();
}

class _InvitePatientSheetState extends ConsumerState<_InvitePatientSheet> {
  final _username = TextEditingController();
  final _message = TextEditingController();
  UserLookup? _found;
  bool _searching = false;
  bool _notFound = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final username = _username.text.trim();
    if (username.isEmpty) return;
    setState(() {
      _searching = true;
      _notFound = false;
      _error = null;
    });
    try {
      final found = await ref.read(userLookupProvider(username).future);
      if (!mounted) return;
      setState(() {
        _found = found;
        _searching = false;
      });
    } catch (error) {
      if (!mounted) return;
      final code = error.asApiException?.code;
      setState(() {
        _searching = false;
        if (code == 'RESOURCE_NOT_FOUND') {
          _notFound = true;
        } else {
          _error = describeApiError(code ?? '');
        }
      });
    }
  }

  Future<void> _send() async {
    final found = _found;
    if (found == null) return;
    final message = _message.text.trim();
    await ref.read(sendCareLinkRequestControllerProvider.notifier).send(found.id, message.isEmpty ? null : message);
    if (!mounted) return;
    ref.read(sendCareLinkRequestControllerProvider)?.whenOrNull(
          data: (_) => Navigator.of(context).pop(true),
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final sending = ref.watch(sendCareLinkRequestControllerProvider)?.isLoading ?? false;
    final found = _found;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: found == null
              ? [
                  Text('Invita un paziente', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Nome utente',
                    controller: _username,
                    errorText: _error,
                    autofillHints: const [AutofillHints.username],
                    onChanged: (_) => setState(() {
                      _notFound = false;
                      _error = null;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Inserisci il nome utente esatto della persona',
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  if (_notFound) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const EmptyStateView(
                      icon: Icons.search_off,
                      title: 'Nessun utente con questo nome',
                      text: 'Verifica il nome utente e riprova',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppPrimaryButton(
                    label: 'Cerca',
                    loading: _searching,
                    onPressed: _username.text.trim().isEmpty ? null : _search,
                  ),
                ]
              : [
                  Row(
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
                            Text(found.fullName, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                            Text('@${found.username}', style: typography.caption.copyWith(color: colors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(label: 'Messaggio di presentazione', controller: _message, minLines: 2, maxLines: 4),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('Aiuta la persona a riconoscerti', style: typography.caption.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(label: 'Invia richiesta', loading: sending, onPressed: _send),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextButton(
                      onPressed: sending ? null : () => setState(() => _found = null),
                      child: const Text('Indietro'),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
