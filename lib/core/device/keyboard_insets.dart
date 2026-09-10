import 'package:flutter/widgets.dart';

import 'keyboard_insets_stub.dart'
    if (dart.library.js_interop) 'keyboard_insets_web.dart' as impl;

/// Riferisce all'applicazione lo spazio sottratto dalla tastiera di
/// sistema, perché `Scaffold`, fogli modali e campi di testo se ne
/// discostino come fanno sulle piattaforme native (MP-2, MP-5).
///
/// Sul web il motore Flutter non lo riferisce: innestata in un elemento
/// proprio — la modalità che consente la rientranza dalle zone riservate
/// del dispositivo — `CustomElementDimensionsProvider.computeKeyboardInsets`
/// restituisce sempre zero, e `MediaQuery.viewInsets` resta vuoto qualunque
/// cosa accada. Un campo in fondo alla schermata finisce così sotto la
/// tastiera, e chi scrive non vede quel che sta scrivendo (vedi
/// decisioni.md).
///
/// Sulle piattaforme native non c'è nulla da aggiungere: il motore
/// riferisce già la misura, e l'involucro è trasparente.
Widget withKeyboardInsets({required Widget child}) =>
    impl.withKeyboardInsets(child: child);
