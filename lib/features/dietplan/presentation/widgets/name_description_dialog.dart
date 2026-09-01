import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Denominazione e descrizione raccolte da [showNameDescriptionDialog].
class NameDescriptionInput {
  const NameDescriptionInput({required this.name, this.description});

  final String name;
  final String? description;
}

/// Dialogo di denominazione e descrizione (TP-3), condiviso dalla
/// creazione del template, dalla sua rinomina (TP-12) e dal salvataggio
/// di un piano come template (TP-5, CD-18): stesso modulo in tutti e tre
/// i casi, un'unica attuazione.
Future<NameDescriptionInput?> showNameDescriptionDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialName = '',
  String initialDescription = '',
}) {
  return showDialog<NameDescriptionInput>(
    context: context,
    builder: (dialogContext) => _NameDescriptionDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
      initialDescription: initialDescription,
    ),
  );
}

/// I controller vivono e muoiono con questo widget (non con la funzione
/// che apre il dialogo): `dispose()` è chiamato da Flutter al momento
/// giusto, dopo l'animazione di chiusura — disporli a mano nella
/// funzione correrebbe con quell'animazione (il `TextField` la usa
/// ancora mentre esce di scena).
class _NameDescriptionDialog extends StatefulWidget {
  const _NameDescriptionDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.initialDescription,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final String initialDescription;

  @override
  State<_NameDescriptionDialog> createState() => _NameDescriptionDialogState();
}

class _NameDescriptionDialogState extends State<_NameDescriptionDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _descriptionController = TextEditingController(text: widget.initialDescription);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_nameController.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      NameDescriptionInput(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(label: 'Denominazione', controller: _nameController),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(label: 'Descrizione', controller: _descriptionController, maxLines: 3),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
        TextButton(onPressed: _confirm, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
