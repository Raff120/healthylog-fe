import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';

/// Segmented control dell'intestazione (6.1, 10.1 e 11.1
/// interfaccia.md): unico comando delle due granularità di *Piano* —
/// *Giorno* · *Settimana* —, dei due contenuti di *Attività* —
/// *Allenamenti* · *Misure* — e dei tre segmenti di *Statistiche* —
/// *Aderenza* · *Allenamenti* · *Corpo*. Il medesimo meccanismo per la
/// medesima ragione: contenuti affini che non meritano voci di
/// navigazione distinte.
///
/// Curvatura piena, fondo in superficie alternativa; il segmento attivo
/// scorre in 280 ms (`AppSpacing.motionScreenTransition`). La larghezza
/// preferita è di 90 per segmento e si riduce a quella disponibile
/// quando lo spazio non basta, senza mai comprimere il controllo a zero
/// (correzione segnalata dall'utente su *Piano*, vedi decisioni.md).
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  }) : assert(labels.length >= 2, 'Un segmented control ha almeno due voci');

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _segmentWidth = 90.0;
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preferred = _segmentWidth * labels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? math.min(preferred, constraints.maxWidth)
            : preferred;
        return SizedBox(
          width: width,
          height: _height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: AppSpacing.motionScreenTransition,
                  curve: AppSpacing.motionSoftCurve,
                  // -1 a sinistra, +1 a destra: la posizione del segmento
                  // attivo fra i due estremi, quale che ne sia il numero.
                  alignment: Alignment(
                    labels.length == 1 ? 0 : (selectedIndex / (labels.length - 1)) * 2 - 1,
                    0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / labels.length,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var index = 0; index < labels.length; index++)
                      _Segment(
                        label: labels[index],
                        active: index == selectedIndex,
                        onTap: () => onSelect(index),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: typography.label.copyWith(
                  color: active ? colors.textPrimary : colors.textSecondary,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
