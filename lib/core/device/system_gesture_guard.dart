import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
/// Il rimedio sovrappone alla striscia un riconoscitore di trascinamento
/// verticale che non fa nulla. Essendo il più in alto nella pila, è il
/// primo dell'arena dei gesti e vince sullo scorrimento sottostante, che
/// perciò non parte.
///
/// **Non è un diaframma**: il riconoscitore è il solo trascinamento
/// verticale, e il tocco — che nessuno qui contende — raggiunge quanto
/// sta sotto. Un comando che ricada nella striscia resta premibile.
///
/// L'involucro sta sopra l'intera applicazione, fogli modali compresi, e
/// si dispone una volta sola: le schermate non ne sanno nulla.
Widget withSystemGestureGuard({required Widget child}) =>
    _SystemGestureGuard(child: child);

class _SystemGestureGuard extends StatelessWidget {
  const _SystemGestureGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Le piattaforme native riferiscono la zona del gesto per conto
    // proprio; il web non la riferisce affatto, e vi si sostituisce la
    // zona riservata del dispositivo, che vi coincide (`device_insets.dart`).
    // `padding` e non `viewPadding`: aperta la tastiera l'indicatore di
    // Home non c'è più, e non c'è nulla da sottrarre.
    final band = math.max(media.systemGestureInsets.bottom, media.padding.bottom);
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
          ),
        ),
      ],
    );
  }
}
