import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Quanto la barra di navigazione fluttuante copre in fondo alla
/// schermata, area sicura del dispositivo compresa (3.2 interfaccia.md).
///
/// Le destinazioni principali lasciano scorrere il contenuto **sotto** la
/// barra — `SafeArea(bottom: false)` — perché una pillola che fluttua sopra
/// una schermata che finisce esattamente dove lei comincia non fluttua: si
/// vede il taglio. Il contenuto scorrevole riceve allora questa misura come
/// spaziatura in coda, così che scorrendo fino in fondo nulla resti coperto.
///
/// È `Scaffold` a riferirla: con `extendBody` il corpo riceve in
/// `MediaQuery.padding` la maggiore fra la zona riservata del dispositivo e
/// l'ingombro della barra. Dove la barra non c'è — schermo ampio, dove al
/// suo posto sta la barra laterale — resta la sola zona riservata, che è
/// esattamente ciò che serve: la stessa schermata vale per entrambe le
/// disposizioni senza saperlo.
double bottomBarInset(BuildContext context) => MediaQuery.paddingOf(context).bottom;

/// Lo scostamento che il pulsante mobile deve aggiungere per restare sopra
/// la barra fluttuante (3.2 interfaccia.md).
///
/// `Scaffold` colloca il pulsante mobile al di sopra della sola zona
/// riservata del dispositivo (`minViewPadding`), che non comprende
/// l'ingombro della barra: la differenza fra le due misure è quanto gli
/// manca per scavalcarla.
double bottomBarFabInset(BuildContext context) {
  final media = MediaQuery.of(context);
  return math.max(0, media.padding.bottom - media.viewPadding.bottom);
}
