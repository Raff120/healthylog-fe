import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';

/// Dialogo delle annotazioni personali (5.4bis funzionale, 4.1, 6.2 e 7.5
/// interfaccia.md): un solo campo — riga singola per il nome della
/// giornata, area di testo per le note — e sotto la constatazione che
/// l'annotazione è visibile a sé soltanto (NP-2).
///
/// Restituisce il testo confermato, vuoto se si vuole togliere
/// l'annotazione (NP-1), ovvero `null` se si rinuncia.
Future<String?> showPersonalTextDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String initialText,
  required int maxLength,
  bool multiline = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _PersonalTextDialog(
      title: title,
      label: label,
      initialText: initialText,
      maxLength: maxLength,
      multiline: multiline,
    ),
  );
}

class _PersonalTextDialog extends StatefulWidget {
  const _PersonalTextDialog({
    required this.title,
    required this.label,
    required this.initialText,
    required this.maxLength,
    required this.multiline,
  });

  final String title;
  final String label;
  final String initialText;
  final int maxLength;
  final bool multiline;

  @override
  State<_PersonalTextDialog> createState() => _PersonalTextDialogState();
}

class _PersonalTextDialogState extends State<_PersonalTextDialog> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: widget.label,
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            minLines: widget.multiline ? 3 : 1,
            maxLines: widget.multiline ? 6 : 1,
            inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(context.l10n.personalTextPrivacy, style: typography.caption.copyWith(color: colors.textSecondary)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}
