import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Una barra dell'andamento settimanale: etichetta dell'asse, valore e
/// testo con cui il valore si presenta al tocco. [value] assente è
/// assenza di dati (AD-4): la barra non è disegnata, l'etichetta resta.
class BarDatum {
  const BarDatum({required this.label, required this.value, required this.valueLabel});

  final String label;
  final double? value;
  final String valueLabel;
}

/// Grafico a barre dell'andamento settimanale (AD-14, SA-11; 11.1, 11.2
/// interfaccia.md): una barra per settimana, altezza proporzionale,
/// colore accento.
///
/// Asse con le sole etichette delle settimane, senza griglia. I valori
/// compaiono **al tocco** su una barra, non stabilmente.
///
/// Nessuna linea di tendenza, nessuna media mobile, nessuna proiezione
/// (AN-12, 11.1). La barra non muta colore in alcuna circostanza: non
/// esprime un giudizio (AD-15, SA-16).
///
/// [referenceValue] disegna la linea orizzontale di riferimento
/// dell'obiettivo (11.2), con le stesse modalità della linea del peso
/// obiettivo (AN-6).
class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({
    super.key,
    required this.bars,
    this.referenceValue,
    this.referenceLabel,
  });

  final List<BarDatum> bars;
  final double? referenceValue;
  final String? referenceLabel;

  static const _plotHeight = 120.0;
  static const _minBarWidth = 28.0;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    if (widget.bars.isEmpty) return const SizedBox.shrink();

    final maxValue = [
      ...widget.bars.map((bar) => bar.value ?? 0),
      widget.referenceValue ?? 0,
    ].reduce((a, b) => a > b ? a : b);
    // Con tutti i valori a zero le barre restano invisibili, ma le
    // etichette dell'asse no: la settimana senza dati resta in elenco.
    final scale = maxValue <= 0 ? 1.0 : maxValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final needed = WeeklyBarChart._minBarWidth * widget.bars.length;
        final scrollable = constraints.hasBoundedWidth && needed > constraints.maxWidth;
        final content = SizedBox(
          width: scrollable ? needed : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: WeeklyBarChart._plotHeight,
                child: Stack(
                  children: [
                    if (widget.referenceValue != null && widget.referenceValue! > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: WeeklyBarChart._plotHeight * (widget.referenceValue! / scale).clamp(0.0, 1.0),
                        child: _ReferenceLine(label: widget.referenceLabel),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var index = 0; index < widget.bars.length; index++)
                          Expanded(
                            child: _Bar(
                              datum: widget.bars[index],
                              scale: scale,
                              selected: _selected == index,
                              onTap: () => setState(
                                () => _selected = _selected == index ? null : index,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  for (final bar in widget.bars)
                    Expanded(
                      child: Center(
                        child: Text(
                          bar.label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: typography.caption.copyWith(color: colors.textTertiary),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
        return scrollable
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: content)
            : content;
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.datum,
    required this.scale,
    required this.selected,
    required this.onTap,
  });

  final BarDatum datum;
  final double scale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final fraction = datum.value == null ? 0.0 : (datum.value! / scale).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: datum.value == null ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: Text(
                  datum.valueLabel,
                  maxLines: 1,
                  style: typography.caption.copyWith(color: colors.textPrimary),
                ),
              ),
            Flexible(
              child: FractionallySizedBox(
                heightFactor: fraction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  child: const SizedBox(width: double.infinity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 11.2: la linea orizzontale che indica l'obiettivo, con le medesime
/// modalità della linea del peso obiettivo (AN-6) — tratteggiata, colore
/// terziario, priva di qualsiasi calcolo derivato (AN-9).
class _ReferenceLine extends StatelessWidget {
  const _ReferenceLine({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: DashedLinePainter(color: colors.textTertiary),
            size: const Size(double.infinity, 1),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(label!, style: typography.caption.copyWith(color: colors.textTertiary)),
        ],
      ],
    );
  }
}

/// Linea orizzontale tratteggiata, comune alla linea dell'obiettivo
/// settimanale (11.2) e a quella del peso obiettivo (AN-6, 11.3).
class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({required this.color});

  final Color color;

  static const _dash = 4.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(Offset(x, 0), Offset((x + _dash).clamp(0, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
