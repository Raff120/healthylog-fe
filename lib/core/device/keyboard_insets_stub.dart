import 'package:flutter/widgets.dart';

/// Piattaforme native: il motore riferisce già l'altezza della tastiera in
/// `MediaQuery.viewInsets`, e l'involucro non ha nulla da aggiungere.
Widget withKeyboardInsets({required Widget child}) => child;
