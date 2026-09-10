import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../app/theme/app_spacing.dart';

/// Elemento ospite dichiarato in `web/index.html`, dentro il quale il
/// motore innesta l'applicazione. È rientrato dalle zone riservate del
/// dispositivo, sicché il suo lato inferiore — e non quello dello schermo
/// — è il fondo di ciò che l'applicazione occupa.
const _hostElementSelector = '#healthylog';

/// Oltre questa scala la finestra visibile è rimpicciolita
/// dall'ingrandimento con due dita, non dalla tastiera: le due cose sono
/// indistinguibili nella misura e si separano soltanto qui.
const _noZoomScale = 1.01;

/// Sotto un pixel la variazione è rumore di misura: rifarne la
/// disposizione costerebbe senza spostare nulla.
const _measurementNoise = 1.0;

Widget withKeyboardInsets({required Widget child}) =>
    _KeyboardInsets(child: child);

class _KeyboardInsets extends StatefulWidget {
  const _KeyboardInsets({required this.child});

  final Widget child;

  @override
  State<_KeyboardInsets> createState() => _KeyboardInsetsState();
}

class _KeyboardInsetsState extends State<_KeyboardInsets> {
  double _keyboardHeight = 0;
  JSFunction? _listener;

  @override
  void initState() {
    super.initState();
    final viewport = web.window.visualViewport;
    if (viewport == null) return;
    // `resize` riferisce l'apparire e lo scomparire della tastiera;
    // `scroll` il caso in cui il browser sposti la finestra visibile per
    // conto proprio, che altera la stessa misura.
    final listener = ((web.Event _) => _measure()).toJS;
    _listener = listener;
    viewport.addEventListener('resize', listener);
    viewport.addEventListener('scroll', listener);
  }

  @override
  void dispose() {
    final listener = _listener;
    if (listener != null) {
      web.window.visualViewport
        ?..removeEventListener('resize', listener)
        ..removeEventListener('scroll', listener);
    }
    super.dispose();
  }

  /// Quanto della superficie dell'applicazione resta coperto: la distanza
  /// fra il fondo dell'elemento ospite e il fondo della finestra visibile.
  /// Presa così, la misura è già al netto della rientranza dalle zone
  /// riservate del dispositivo, che non è coperta dalla tastiera ma non è
  /// nemmeno dell'applicazione.
  void _measure() {
    final viewport = web.window.visualViewport;
    final host = web.document.querySelector(_hostElementSelector);
    if (viewport == null || host == null) return;

    final double covered;
    if (viewport.scale > _noZoomScale) {
      covered = 0;
    } else {
      final visibleBottom = viewport.offsetTop + viewport.height;
      covered = host.getBoundingClientRect().bottom - visibleBottom;
    }
    final keyboardHeight = covered.clamp(0.0, double.infinity);
    if ((keyboardHeight - _keyboardHeight).abs() < _measurementNoise) return;

    final grown = keyboardHeight > _keyboardHeight;
    setState(() => _keyboardHeight = keyboardHeight);
    if (grown) _revealFocusedField();
  }

  /// Riporta in vista il campo che ha il fuoco.
  ///
  /// Non basta riferire la misura: `EditableText` si riporta in vista da sé
  /// solo quando è il motore a mutare `viewInsets`, che sul web non muta
  /// mai. Senza questo, il campo resterebbe dov'era — fuori dalla porzione
  /// rimasta scoperta — pur essendosi la schermata ristretta attorno.
  ///
  /// Lo spostamento è il minimo che serve a scoprirlo (`showOnScreen`), non
  /// un riposizionamento: un campo già visibile resta dov'è.
  void _revealFocusedField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focused = FocusManager.instance.primaryFocus?.context;
      focused?.findRenderObject()?.showOnScreen(
        duration: AppSpacing.motionStateTransition,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        viewInsets: media.viewInsets.copyWith(bottom: _keyboardHeight),
      ),
      child: widget.child,
    );
  }
}
