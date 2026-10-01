import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../app/theme/app_spacing.dart';

/// Sottrae allo scorrimento la striscia riservata al **gesto di sistema**
/// del bordo inferiore — la risalita dall'indicatore di Home che chiude
/// l'applicazione o ne apre il commutatore (3.2 interfaccia.md).
///
/// Il sistema consegna all'applicazione i tocchi di quella zona mentre
/// ancora riconosce il proprio gesto: chi risale per uscire vede la
/// schermata scorrere mentre esce, e al ritorno la ritrova spostata
/// (segnalato dall'utente in esercizio). Non è un difetto di una
/// schermata in particolare — vi ricade ogni contenuto scorrevole.
///
/// Il rimedio sovrappone alla striscia due riconoscitori di trascinamento,
/// verticale e orizzontale, che non fanno nulla. Essendo i più in alto
/// nella pila, sono i primi dell'arena dei gesti e vincono sugli
/// scorrimenti sottostanti, che perciò non partono. L'orizzontale serve
/// perché la risalita è di rado perfettamente verticale: obliqua, superava
/// prima la soglia orizzontale e faceva cambiare giornata alla vista
/// giornaliera (segnalato dall'utente, vedi decisioni.md).
///
/// **Non è un diaframma**: i riconoscitori sono i soli trascinamenti, e il
/// tocco — che nessuno qui contende — raggiunge quanto sta sotto. Un
/// comando che ricada nella striscia resta premibile.
///
/// L'involucro sta sopra l'intera applicazione, fogli modali compresi, e
/// si dispone una volta sola: le schermate non ne sanno nulla.
///
/// [minimumBand] è l'altezza sotto la quale la striscia non scende. Sul
/// web vale `lg`: là la zona riservata può risultare nulla — sulle PWA di
/// Android accade spesso — benché il gesto di sistema esista, e la
/// striscia sparirebbe proprio dove serve. Le piattaforme native
/// riferiscono la zona del gesto per conto proprio, e non ne hanno
/// bisogno.
Widget withSystemGestureGuard({
  required Widget child,
  double minimumBand = kIsWeb ? AppSpacing.lg : 0,
}) =>
    _SystemGestureGuard(minimumBand: minimumBand, child: child);

class _SystemGestureGuard extends StatelessWidget {
  const _SystemGestureGuard({required this.minimumBand, required this.child});

  final double minimumBand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Le piattaforme native riferiscono la zona del gesto per conto
    // proprio; il web non la riferisce affatto, e vi si sostituisce la
    // zona riservata del dispositivo, che vi coincide (`device_insets.dart`).
    // `padding` e non `viewPadding`: aperta la tastiera l'indicatore di
    // Home non c'è più, e non c'è nulla da sottrarre.
    // Aperta la tastiera non c'è nemmeno la striscia minima: il bordo
    // inferiore è il suo.
    final keyboardOpen = media.viewInsets.bottom > 0;
    final band = math.max(
      math.max(media.systemGestureInsets.bottom, media.padding.bottom),
      keyboardOpen ? 0.0 : minimumBand,
    );
    if (band <= 0) return child;

    return Stack(
      // Allineamento non direzionale: l'involucro sta sopra
      // `Localizations` e non ha di che risolvere `start` ed `end`.
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: band,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            onVerticalDragStart: (_) {},
            onVerticalDragUpdate: (_) {},
            onVerticalDragEnd: (_) {},
            onVerticalDragCancel: () {},
            onHorizontalDragStart: (_) {},
            onHorizontalDragUpdate: (_) {},
            onHorizontalDragEnd: (_) {},
            onHorizontalDragCancel: () {},
          ),
        ),
      ],
    );
  }
}
