import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../data/statistics_models.dart';

/// Grafico a linea dell'andamento di una grandezza corporea (11.3
/// interfaccia.md, AN-1, AN-3).
///
/// La serie **non è interpolata** dove i dati mancano: in assenza di un
/// vincolo di frequenza (PR-14) può essere irregolare, e la spaziatura
/// orizzontale rispetta la distanza reale fra le date — i punti distanti
/// nel tempo restano collegati dalla linea, ma nessun valore inesistente
/// vi è inserito.
///
/// AN-5, PR-17: i punti registrati dal Nutrizionista sono cerchi vuoti con
/// bordo, distinti da quelli pieni dell'Utente: strumento e condizioni di
/// rilevazione possono differire.
///
/// AN-6: nel solo grafico del peso, una linea orizzontale tratteggiata in
/// colore terziario al livello dell'obiettivo. AN-9: nessun calcolo
/// derivato — non distanza residua, non percentuale di avanzamento, non
/// tempo stimato. AN-12: nessuna media mobile, nessuna proiezione.
class MeasureLineChart extends StatelessWidget {
  const MeasureLineChart({
    super.key,
    required this.points,
    required this.unit,
    this.targetValue,
  });

  final List<MeasurePoint> points;
  final String unit;

  /// AN-7, AN-8: assente per le circonferenze e per l'obiettivo non
  /// impostato — la linea semplicemente non compare.
  final double? targetValue;

  static const _height = 200.0;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      height: _height,
      child: CustomPaint(
        painter: _MeasureLinePainter(
          points: points,
          targetValue: targetValue,
          unit: unit,
          // LO-9: le etichette dell'asse sono composte qui, dove il
          // contesto c'è: il pittore non ne dispone.
          formatAxisDate: (date) => formatDayAndMonthShort(context, date),
          lineColor: colors.accent,
          surfaceColor: colors.surface,
          gridColor: colors.dividerLight,
          targetColor: colors.textTertiary,
          labelStyle: typography.caption.copyWith(color: colors.textTertiary),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _MeasureLinePainter extends CustomPainter {
  _MeasureLinePainter({
    required this.points,
    required this.targetValue,
    required this.unit,
    required this.formatAxisDate,
    required this.lineColor,
    required this.surfaceColor,
    required this.gridColor,
    required this.targetColor,
    required this.labelStyle,
  });

  final List<MeasurePoint> points;
  final double? targetValue;
  final String unit;
  final String Function(DateTime) formatAxisDate;
  final Color lineColor;
  final Color surfaceColor;
  final Color gridColor;
  final Color targetColor;
  final TextStyle labelStyle;

  static const _pointRadius = 3.0;
  static const _lineWidth = 2.0;
  static const _valueAxisWidth = 44.0;
  static const _dateAxisHeight = 20.0;
  static const _dash = 4.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _valueAxisWidth,
      _pointRadius * 2,
      size.width - _pointRadius * 2,
      size.height - _dateAxisHeight,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final values = [...points.map((point) => point.value), if (targetValue != null) targetValue!];
    var minValue = values.reduce((a, b) => a < b ? a : b);
    var maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue - minValue < 0.001) {
      // Serie costante: si apre comunque una banda, per non appiattire la
      // linea sul bordo del riquadro.
      minValue -= 1;
      maxValue += 1;
    } else {
      final padding = (maxValue - minValue) * 0.1;
      minValue -= padding;
      maxValue += padding;
    }

    final firstDay = points.first.date;
    final lastDay = points.last.date;
    final span = lastDay.difference(firstDay).inMilliseconds;

    double xOf(DateTime date) => span == 0
        ? plot.center.dx
        : plot.left + plot.width * (date.difference(firstDay).inMilliseconds / span);
    double yOf(double value) =>
        plot.bottom - plot.height * ((value - minValue) / (maxValue - minValue));

    _paintValueAxis(canvas, plot, minValue, maxValue, yOf);
    _paintDateAxis(canvas, plot, firstDay, lastDay);
    if (targetValue != null) {
      _paintTargetLine(canvas, plot, yOf(targetValue!));
    }
    _paintSeries(canvas, points.map((point) => Offset(xOf(point.date), yOf(point.value))).toList());
    _paintPoints(canvas, xOf, yOf);
  }

  /// Asse verticale con griglia leggera (11.3): tre riferimenti, il minimo,
  /// il mediano e il massimo della banda osservata.
  void _paintValueAxis(Canvas canvas, Rect plot, double minValue, double maxValue,
      double Function(double) yOf) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final value in [minValue, (minValue + maxValue) / 2, maxValue]) {
      final y = yOf(value);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
      _paintText(canvas, _formatValue(value), Offset(0, y - labelStyle.fontSize! * 0.8),
          maxWidth: _valueAxisWidth - AppSpacing.xxs);
    }
  }

  /// Asse orizzontale con le sole date, senza griglia (11.3).
  void _paintDateAxis(Canvas canvas, Rect plot, DateTime firstDay, DateTime lastDay) {
    final y = plot.bottom + AppSpacing.xxs;
    _paintText(canvas, formatAxisDate(firstDay), Offset(plot.left, y));
    if (lastDay != firstDay) {
      _paintText(canvas, formatAxisDate(lastDay), Offset(plot.right - 40, y), maxWidth: 40, alignRight: true);
    }
  }

  void _paintTargetLine(Canvas canvas, Rect plot, double y) {
    final paint = Paint()
      ..color = targetColor
      ..strokeWidth = 1;
    for (var x = plot.left; x < plot.right; x += _dash + _gap) {
      canvas.drawLine(Offset(x, y), Offset((x + _dash).clamp(plot.left, plot.right), y), paint);
    }
  }

  void _paintSeries(Canvas canvas, List<Offset> offsets) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = _lineWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// AN-5: cerchi pieni per l'Utente, cerchi vuoti con bordo per il
  /// Nutrizionista.
  void _paintPoints(Canvas canvas, double Function(DateTime) xOf, double Function(double) yOf) {
    for (final point in points) {
      final center = Offset(xOf(point.date), yOf(point.value));
      if (point.fromNutritionist) {
        canvas.drawCircle(center, _pointRadius, Paint()..color = surfaceColor);
        canvas.drawCircle(
          center,
          _pointRadius,
          Paint()
            ..color = lineColor
            ..strokeWidth = _lineWidth
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawCircle(center, _pointRadius, Paint()..color = lineColor);
      }
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset,
      {double maxWidth = 80, bool alignRight = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  String _formatValue(double value) {
    final rounded = value.abs() >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$rounded $unit';
  }


  @override
  bool shouldRepaint(_MeasureLinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.targetValue != targetValue ||
      oldDelegate.lineColor != lineColor;
}
