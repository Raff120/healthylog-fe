import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// Marchio dell'applicazione (2.5 interfaccia.md): forchetta e coltello in
/// tratto lineare su riquadro arrotondato in accento.
///
/// 2.5: compare unicamente nelle schermate antecedenti l'accesso (5.2) e
/// nella schermata iniziale di caricamento. Non figura nell'intestazione
/// delle schermate interne.
///
/// È disegnato e non un'immagine: resta nitido a ogni dimensione e non
/// richiede una risorsa per densità. I due colori sono attinti dal livello
/// semantico del tema (FE-17) e sono i medesimi nel chiaro e nello scuro:
/// l'identità è una, e questo marchio dev'essere lo stesso segno
/// dell'icona sulla schermata iniziale del dispositivo (MP-9).
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AppMarkPainter(background: colors.markBackground, stroke: colors.markForeground),
      ),
    );
  }
}

class _AppMarkPainter extends CustomPainter {
  const _AppMarkPainter({required this.background, required this.stroke});

  final Color background;
  final Color stroke;

  /// Le stesse proporzioni delle icone di piattaforma, così che il
  /// marchio dentro l'applicazione e quello sulla schermata iniziale del
  /// dispositivo siano lo stesso segno (MP-9).
  static const double _cornerRatio = 0.225;
  static const double _glyphRatio = 0.52;
  static const double _strokeRatio = 0.085;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, side, side),
        Radius.circular(side * _cornerRatio),
      ),
      Paint()..color = background,
    );

    final glyph = side * _glyphRatio;
    final origin = Offset((side - glyph) / 2, (side - glyph) / 2);
    Offset p(double x, double y) => origin + Offset(x * glyph, y * glyph);

    final pen = Paint()
      ..color = stroke
      ..strokeWidth = glyph * _strokeRatio
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Forchetta: tre rebbi raccolti da una traversa, e il manico.
    for (final x in const [0.06, 0.22, 0.38]) {
      canvas.drawLine(p(x, 0), p(x, 0.30), pen);
    }
    canvas.drawLine(p(0.06, 0.30), p(0.38, 0.30), pen);
    canvas.drawLine(p(0.22, 0.30), p(0.22, 1), pen);

    // Coltello: il dorso che prosegue nel manico, e il filo della lama.
    canvas.drawLine(p(0.80, 0), p(0.80, 1), pen);
    canvas.drawPath(
      Path()
        ..moveTo(p(0.80, 0.02).dx, p(0.80, 0.02).dy)
        ..quadraticBezierTo(p(1.14, 0.26).dx, p(1.14, 0.26).dy, p(0.80, 0.52).dx, p(0.80, 0.52).dy),
      pen,
    );
  }

  @override
  bool shouldRepaint(_AppMarkPainter oldDelegate) =>
      oldDelegate.background != background || oldDelegate.stroke != stroke;
}

/// Il marchio con la denominazione sotto, come lo presentano la schermata
/// di caricamento e quella di accesso (2.5, 5.2).
class AppMarkWithName extends StatelessWidget {
  const AppMarkWithName({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppMark(size: size),
        const SizedBox(height: AppSpacing.sm),
        // LO-3: la denominazione del prodotto non si traduce.
        Text('HealthyLog', style: typography.titleLarge.copyWith(color: colors.textPrimary)),
      ],
    );
  }
}
