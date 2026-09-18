import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../domain/water_amounts.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';
import 'water_amount_sheet.dart';

/// Pulsante mobile dell'acqua in *Piano* (AQ-16, 6.1 e 6.2
/// interfaccia.md): tondo, in colore accento, con la goccia (2.5).
///
/// **Offre l'azione, non la misura.** Non reca totale, percentuale né
/// anello di avanzamento: quanto si è bevuto e se l'obiettivo sia stato
/// raggiunto si guardano in *Statistiche* (AQ-17, 11.1). È così che la
/// giornata osserva OS-11 anziché derogarvi, come faceva la sezione che
/// questo pulsante sostituisce.
///
/// AQ-17bis: è l'unico pulsante mobile ammesso in *Piano*. L'esclusione
/// di 6.1 nasceva dall'ambiguità del «+», che in una schermata di piano
/// alimentare si leggeva come «aggiungi un piano»: la goccia nomina da sé
/// la propria azione.
///
/// Il chiamante non lo costruisce affatto sulla giornata di un altro
/// membro (AQ-20), su quella futura (AQ-9) e nella vista settimanale
/// (AQ-18).
class WaterFabMenu extends ConsumerStatefulWidget {
  const WaterFabMenu({super.key, required this.date, required this.bottomInset});

  final DateTime date;

  /// 3.2: quanto il pulsante deve alzarsi per scavalcare la barra
  /// fluttuante (`bottom_bar_insets.dart`).
  ///
  /// **Lo riceve e non lo misura.** La barra non appartiene alla
  /// schermata ma alla navicella che la contiene, e la sua misura vive
  /// nella `MediaQuery` che sta **sopra** la Scaffold: letta di qui —
  /// dentro la Scaffold, dove la spaziatura è già stata consumata —
  /// varrebbe zero, e il pulsante finirebbe dietro la barra.
  final double bottomInset;

  /// Lato del pulsante (6.2) e raggio dell'arco su cui si dispone il
  /// ventaglio.
  static const double diameter = 56;
  static const double radius = 152;

  @override
  ConsumerState<WaterFabMenu> createState() => _WaterFabMenuState();
}

class _WaterFabMenuState extends ConsumerState<WaterFabMenu> {
  bool _open = false;

  Future<void> _openFan() async {
    setState(() => _open = true);
    await showGeneralDialog<void>(
      context: context,
      // Il velo si chiude al tocco senza registrare nulla, e il tocco sul
      // pulsante stesso lo attraversa: aperto, il pulsante non ha altra
      // azione che richiudersi (6.2).
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: context.colors.scrim,
      transitionDuration: AppSpacing.motionStateTransition,
      pageBuilder: (dialogContext, animation, _) =>
          _WaterFan(date: widget.date, fabInset: widget.bottomInset, animation: animation),
    );
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      // 3.2: il pulsante mobile scavalca la barra fluttuante.
      padding: EdgeInsets.only(bottom: widget.bottomInset),
      child: FloatingActionButton(
        key: const Key('waterFab'),
        onPressed: _openFan,
        backgroundColor: colors.accent,
        foregroundColor: colors.surface,
        tooltip: context.l10n.waterAddTooltip,
        child: AnimatedSwitcher(
          duration: AppSpacing.motionStateTransition,
          child: Icon(
            _open ? Icons.close : Icons.water_drop_outlined,
            key: ValueKey(_open),
          ),
        ),
      ),
    );
  }
}

/// Il ventaglio: le quattro voci di aggiunta disposte lungo un arco di
/// quarto di cerchio attorno al pulsante, verso l'alto e verso sinistra —
/// l'unico quadrante libero, stando il pulsante nell'angolo (6.2).
///
/// Le pastiglie sono **allineate al margine destro** e si distendono verso
/// sinistra: quale ne sia la lunghezza, non escono mai dallo schermo.
class _WaterFan extends ConsumerWidget {
  const _WaterFan({required this.date, required this.fabInset, required this.animation});

  final DateTime date;
  final double fabInset;
  final Animation<double> animation;

  /// Angoli dell'arco, dall'orizzontale al verticale (6.2). Distribuiti
  /// sull'intero quadrante: su un arco più stretto le voci, che sono alte
  /// quanto il bersaglio minimo, si accavallerebbero.
  static const List<double> _degrees = [4, 32, 61, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider);
    // Centro del pulsante, misurato dagli spigoli destro e inferiore
    // dello schermo: gli stessi valori che Scaffold gli assegna.
    final centreFromRight = AppSpacing.md + WaterFabMenu.diameter / 2;
    final centreFromBottom =
        MediaQuery.viewPaddingOf(context).bottom + fabInset + AppSpacing.md + WaterFabMenu.diameter / 2;

    void add(int millilitres) {
      ref.read(waterIntakeControllerProvider.notifier).add(date, millilitres);
      Navigator.of(context).pop();
    }

    final entries = <({String label, String? value, IconData? icon, VoidCallback onTap})>[
      for (final amount in WaterAmount.values)
        (
          label: waterAmountName(context, amount),
          value: formatVolume(context, amount.millilitresIn(units), units),
          icon: null,
          onTap: () => add(amount.millilitresIn(units)),
        ),
      // AQ-7: la quantità diversa da quelle previste, che non ha nome.
      (
        label: context.l10n.waterAddCustom,
        value: null,
        icon: Icons.add,
        onTap: () {
          Navigator.of(context).pop();
          showWaterAmountSheet(context, date: date);
        },
      ),
    ];

    return Stack(
      children: [
        for (var index = 0; index < entries.length; index++)
          Positioned(
            right: centreFromRight +
                WaterFabMenu.radius * math.cos(_degrees[index] * math.pi / 180) -
                AppSpacing.minInteractiveTarget / 2,
            bottom: centreFromBottom +
                WaterFabMenu.radius * math.sin(_degrees[index] * math.pi / 180) -
                AppSpacing.minInteractiveTarget / 2,
            child: ConstrainedBox(
              // La pastiglia si distende verso sinistra a partire dal
              // proprio punto d'ancoraggio: oltre quel che resta di
              // schermo non può andare, e il nome cede prima del margine.
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width -
                    AppSpacing.md -
                    (centreFromRight +
                        WaterFabMenu.radius * math.cos(_degrees[index] * math.pi / 180) -
                        AppSpacing.minInteractiveTarget / 2),
                ),
              child: _FanEntry(
              // Le voci emergono in sequenza, non tutte insieme: l'arco
              // si legge come un dispiegarsi (6.2).
                animation: CurvedAnimation(
                  parent: animation,
                  curve: Interval(index * 0.12, 1, curve: Curves.easeOutBack),
              ),
                label: entries[index].label,
                value: entries[index].value,
                icon: entries[index].icon,
                onTap: entries[index].onTap,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pastiglia del ventaglio: superficie, ombra di ciò che fluttua e
/// curvatura piena, all'altezza del bersaglio minimo (2.4). Emerge
/// scalando dall'angolo in basso a destra, che è il punto da cui il
/// pulsante la dispiega.
///
/// La superficie e non quella della barra fluttuante: nel tema chiaro
/// quest'ultima è l'accento (2.2), e le pastiglie sarebbero del colore
/// del pulsante che le ha aperte, indistinguibili da esso.
class _FanEntry extends StatelessWidget {
  const _FanEntry({
    required this.animation,
    required this.label,
    required this.onTap,
    this.value,
    this.icon,
  });

  final Animation<double> animation;
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomRight,
      child: FadeTransition(
        opacity: animation,
        child: Semantics(
          button: true,
          label: value == null ? label : '$label $value',
          excludeSemantics: true,
          child: Material(
            color: colors.surface,
            elevation: AppSpacing.elevationFloating,
            shadowColor: colors.shadowFloating,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: SizedBox(
                height: AppSpacing.minInteractiveTarget,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, size: 20, color: colors.accent)
                      else ...[
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          value!,
                          style: typography.caption.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
