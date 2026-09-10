import 'package:flutter/widgets.dart';

import 'device_insets_stub.dart'
    if (dart.library.js_interop) 'device_insets_web.dart' as impl;

/// Riferisce all'applicazione le misure del dispositivo che il motore
/// Flutter, sul web, non riferisce: lo spazio sottratto dalla tastiera di
/// sistema e la zona riservata al bordo inferiore dello schermo.
///
/// Innestata in un elemento proprio — la modalità che consente la
/// rientranza dalle zone riservate — l'applicazione riceve
/// `MediaQuery.viewInsets` e `MediaQuery.padding` sempre vuoti:
/// `CustomElementDimensionsProvider.computeKeyboardInsets` restituisce zero
/// incondizionatamente, e il motore non legge `env(safe-area-inset-*)`.
/// Sicché `Scaffold`, fogli modali e `SafeArea` non hanno di che
/// discostarsi: un campo in fondo alla schermata finisce sotto la tastiera,
/// e il contenuto sotto l'indicatore di Home (MP-2, MP-5, MP-9).
///
/// Le due misure si compongono come sulle piattaforme native: la tastiera
/// copre la zona riservata, e finché è aperta la spaziatura si annulla.
///
/// Sulle piattaforme native non c'è nulla da aggiungere — il motore
/// riferisce già entrambe — e l'involucro è trasparente.
Widget withDeviceInsets({required Widget child}) =>
    impl.withDeviceInsets(child: child);
