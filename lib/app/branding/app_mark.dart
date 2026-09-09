import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// Marchio dell'applicazione (2.5 interfaccia.md).
///
/// 2.5: compare unicamente nelle schermate antecedenti l'accesso (5.2) e
/// nella schermata iniziale di caricamento. Non figura nell'intestazione
/// delle schermate interne.
///
/// È la stessa risorsa da cui sono generate le icone di piattaforma, non
/// un disegno che le somigli: il marchio dentro l'applicazione e quello
/// sulla schermata iniziale del dispositivo sono lo stesso segno (MP-9).
/// Per la medesima ragione non muta con il tema — l'identità è una.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 72});

  static const String asset = 'assets/brand/app_mark.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Lo stesso raggio delle icone di piattaforma che si presentano da
      // sé (web, macOS): la risorsa è quadrata, l'arrotondamento è reso.
      borderRadius: BorderRadius.circular(size * 0.225),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // 2.6: l'immagine non è testo — nessuna descrizione da leggere,
        // la denominazione le sta accanto.
        excludeFromSemantics: true,
      ),
    );
  }
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
