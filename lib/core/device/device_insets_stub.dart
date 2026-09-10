import 'package:flutter/widgets.dart';

/// Piattaforme native: il motore riferisce già l'altezza della tastiera e le
/// zone riservate del dispositivo, e l'involucro non ha nulla da aggiungere.
Widget withDeviceInsets({required Widget child}) => child;
