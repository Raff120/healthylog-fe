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
///
/// Ristretto, il testo rimpicciolisce di un fattore solo, calcolato
/// sull'etichetta più lunga e applicato a tutte: rimpicciolendo ciascuna
/// per conto proprio, le voci del medesimo comando finirebbero di corpo
/// diverso — visibile in *Statistiche*, dove i tre segmenti dividono con
/// il selettore del periodo l'intestazione.
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

  /// Rientranza orizzontale di ciascuna voce, che sottrae larghezza al
  /// testo: entra perciò nel calcolo del fattore di riduzione.
  static const _segmentPadding = AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final preferred = _segmentWidth * labels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? math.min(preferred, constraints.maxWidth)
            : preferred;
        final style = typography.label.copyWith(
          fontSize: (typography.label.fontSize ?? 14) * _scale(context, width),
        );
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
                        style: style,
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

extension on AppSegmentedControl {
  /// Il fattore che fa stare l'etichetta più lunga nella voce: uno quando
  /// lo spazio basta, altrimenti quanto serve. Uno solo per tutte, perché
  /// le voci restino di corpo uguale.
  double _scale(BuildContext context, double width) {
    final typography = context.typography;
    final available =
        width / labels.length - AppSegmentedControl._segmentPadding * 2;
    if (available <= 0) return 1;

    final textScaler = MediaQuery.textScalerOf(context);
    var longest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: typography.label),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
      )..layout();
      longest = math.max(longest, painter.width);
      painter.dispose();
    }
    if (longest <= available) return 1;
    return available / longest;
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.style,
    required this.active,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSegmentedControl._segmentPadding,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: style.copyWith(
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
