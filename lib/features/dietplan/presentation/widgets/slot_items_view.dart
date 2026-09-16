import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/slot_item.dart';
import '../../domain/slot_item_format.dart';

/// Elementi di uno slot, come li presentano la card del pasto (4.1), la
/// modalità affiancata (6.3), la vista settimanale (6.4) e l'anteprima del
/// template (7.4): un solo widget, perché non divergano.
///
/// Chiuso presenta i primi [maxItems] elementi, uno per riga troncata,
/// l'indicatore delle alternative in coda e l'eccedenza in fondo. Aperto
/// presenta gli elementi integrali, e sotto ciascuno le sue alternative,
/// rientrate e precedute da «oppure» (GG-25).
///
/// Le alternative sono solo informative (GG-26): non sono toccabili né
/// spuntabili, e nulla registra quale sia stata consumata. È toccabile la
/// sola riga di una ricetta che rechi un testo, che apre il foglio della
/// ricetta.
class SlotItemsView extends StatelessWidget {
  const SlotItemsView({
    super.key,
    required this.items,
    this.expanded = false,
    this.maxItems = 4,
    this.onRecipeTap,
    this.dense = false,
  });

  final List<SlotItem> items;

  /// Card aperta: elementi integrali e alternative visibili (4.1).
  final bool expanded;

  /// Quanti elementi presentare da chiusa, prima dell'eccedenza.
  final int maxItems;

  /// Apre il foglio della ricetta. Assente dove la ricetta non si consulta.
  final void Function(String name, String recipeText)? onRecipeTap;

  /// Composizione più fitta, per le celle affiancate e la settimanale.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (items.isEmpty) {
      // GG-13: uno slot previsto ma non ancora specificato.
      return Text(
        context.l10n.mealItemsNone,
        style: (dense ? typography.bodyMedium : typography.bodyLarge)
            .copyWith(color: colors.textTertiary),
      );
    }

    final shown = expanded ? items : items.take(maxItems).toList();
    final hidden = items.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in shown) ...[
          _ItemRow(item: item, expanded: expanded, dense: dense, onRecipeTap: onRecipeTap),
          if (expanded)
            for (final alternative in item.alternatives)
              _AlternativeRow(alternative: alternative, dense: dense, onRecipeTap: onRecipeTap),
        ],
        if (hidden > 0) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.mealItemsMore(hidden),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.expanded,
    required this.dense,
    this.onRecipeTap,
  });

  final SlotItem item;
  final bool expanded;
  final bool dense;
  final void Function(String name, String recipeText)? onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final quantity = formatSlotItemQuantity(context, item.quantity, item.unitCode);
    final recipeText = item.recipeText?.trim();
    final hasRecipeSheet =
        item.isRecipe && recipeText != null && recipeText.isNotEmpty && onRecipeTap != null;
    final alternatives = item.alternatives.length;

    final row = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isRecipe) ...[
            Icon(Icons.soup_kitchen_outlined, size: 16, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.name,
                    style: (dense ? typography.bodyMedium : typography.bodyLarge)
                        .copyWith(color: colors.textPrimary),
                  ),
                  // GG-24: la quantità come scritta, in secondo piano rispetto
                  // alla denominazione.
                  if (quantity != null)
                    TextSpan(
                      text: '  $quantity',
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  // 4.1: a card chiusa le alternative sono annunciate, non
                  // elencate (GG-25).
                  if (!expanded && alternatives > 0)
                    TextSpan(
                      text: '  ${context.l10n.mealItemAlternativesCount(alternatives)}',
                      style: typography.caption.copyWith(color: colors.textTertiary),
                    ),
                ],
              ),
              maxLines: expanded ? null : 1,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          if (hasRecipeSheet) ...[
            const SizedBox(width: AppSpacing.xxs),
            Icon(Icons.chevron_right, size: 16, color: colors.textSecondary),
          ],
        ],
      ),
    );

    if (!hasRecipeSheet) return row;
    return InkWell(onTap: () => onRecipeTap!(item.name, recipeText), child: row);
  }
}

/// GG-25, 4.1: rientrata sotto il proprio elemento e preceduta da «oppure».
class _AlternativeRow extends StatelessWidget {
  const _AlternativeRow({required this.alternative, required this.dense, this.onRecipeTap});

  final SlotItemAlternative alternative;
  final bool dense;
  final void Function(String name, String recipeText)? onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final quantity = formatSlotItemQuantity(context, alternative.quantity, alternative.unitCode);
    final recipeText = alternative.recipeText?.trim();
    final hasRecipeSheet =
        alternative.isRecipe && recipeText != null && recipeText.isNotEmpty && onRecipeTap != null;

    final row = Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (alternative.isRecipe) ...[
            Icon(Icons.soup_kitchen_outlined, size: 16, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Expanded(
            child: Text(
              '${context.l10n.mealItemAlternativePrefix} '
              '${alternative.name}${quantity == null ? '' : '  $quantity'}',
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          if (hasRecipeSheet) ...[
            const SizedBox(width: AppSpacing.xxs),
            Icon(Icons.chevron_right, size: 16, color: colors.textSecondary),
          ],
        ],
      ),
    );

    if (!hasRecipeSheet) return row;
    return InkWell(onTap: () => onRecipeTap!(alternative.name, recipeText), child: row);
  }
}
