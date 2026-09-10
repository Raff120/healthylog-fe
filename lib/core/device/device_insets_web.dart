import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../app/theme/app_spacing.dart';

/// Elemento ospite dichiarato in `web/index.html`, dentro il quale il
/// motore innesta l'applicazione. Al bordo inferiore arriva fino allo
/// schermo: il suo lato basso è quello dello schermo.
const _hostElementSelector = '#healthylog';

/// Sonda dichiarata in `web/index.html`, alta quanto la zona riservata al
/// bordo inferiore. `env(safe-area-inset-*)` si risolve solo dove è usato,
/// e non c'è altro modo di leggerne la misura.
const _safeAreaProbeSelector = '#healthylog-safe-area-bottom';

/// Oltre questa scala la finestra visibile è rimpicciolita
/// dall'ingrandimento con due dita, non dalla tastiera: le due cose sono
/// indistinguibili nella misura e si separano soltanto qui.
const _noZoomScale = 1.01;

/// Sotto un pixel la variazione è rumore di misura: rifarne la
/// disposizione costerebbe senza spostare nulla.
const _measurementNoise = 1.0;

Widget withDeviceInsets({required Widget child}) => _DeviceInsets(child: child);

class _DeviceInsets extends StatefulWidget {
  const _DeviceInsets({required this.child});

  final Widget child;

  @override
  State<_DeviceInsets> createState() => _DeviceInsetsState();
}

class _DeviceInsetsState extends State<_DeviceInsets> {
  double _keyboardHeight = 0;
  double _safeAreaBottom = 0;
  JSFunction? _listener;

  @override
  void initState() {
    super.initState();
    final measured = _measure();
    if (measured != null) {
      _keyboardHeight = measured.keyboardHeight;
      _safeAreaBottom = measured.safeAreaBottom;
    }

    final viewport = web.window.visualViewport;
    if (viewport == null) return;
    // `resize` riferisce l'apparire e lo scomparire della tastiera e la
    // rotazione del dispositivo, che muta le zone riservate; `scroll` il
    // caso in cui il browser sposti la finestra visibile per conto proprio,
    // che altera la misura della tastiera.
    final listener = ((web.Event _) => _remeasure()).toJS;
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

  void _remeasure() {
    final measured = _measure();
    if (measured == null) return;
    if ((measured.keyboardHeight - _keyboardHeight).abs() < _measurementNoise &&
        (measured.safeAreaBottom - _safeAreaBottom).abs() < _measurementNoise) {
      return;
    }

    final grown = measured.keyboardHeight > _keyboardHeight;
    setState(() {
      _keyboardHeight = measured.keyboardHeight;
      _safeAreaBottom = measured.safeAreaBottom;
    });
    if (grown) _revealFocusedField();
  }

  /// La tastiera è quanto della superficie dell'applicazione resta coperto:
  /// la distanza fra il fondo dell'elemento ospite e il fondo della finestra
  /// visibile. La zona riservata si legge dalla sonda.
  _Measurement? _measure() {
    final viewport = web.window.visualViewport;
    final host = web.document.querySelector(_hostElementSelector);
    if (viewport == null || host == null) return null;

    final double keyboardHeight;
    if (viewport.scale > _noZoomScale) {
      keyboardHeight = 0;
    } else {
      final visibleBottom = viewport.offsetTop + viewport.height;
      final covered = host.getBoundingClientRect().bottom - visibleBottom;
      keyboardHeight = covered.clamp(0.0, double.infinity);
    }

    final probe = web.document.querySelector(_safeAreaProbeSelector);
    final safeAreaBottom = probe?.getBoundingClientRect().height ?? 0;

    return _Measurement(
      keyboardHeight: keyboardHeight,
      safeAreaBottom: safeAreaBottom.toDouble(),
    );
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
    // `padding` è quel che resta della zona riservata una volta tolto ciò
    // che la tastiera copre, come il motore calcola sulle piattaforme
    // native: aperta la tastiera, l'indicatore di Home non c'è più e la
    // spaziatura si annulla. `viewPadding` la conserva per intero, che è
    // la distinzione fra le due.
    final padding = (_safeAreaBottom - _keyboardHeight).clamp(
      0.0,
      double.infinity,
    );
    return MediaQuery(
      data: media.copyWith(
        viewInsets: media.viewInsets.copyWith(bottom: _keyboardHeight),
        viewPadding: media.viewPadding.copyWith(bottom: _safeAreaBottom),
        padding: media.padding.copyWith(bottom: padding),
      ),
      child: widget.child,
    );
  }
}

class _Measurement {
  const _Measurement({required this.keyboardHeight, required this.safeAreaBottom});

  final double keyboardHeight;
  final double safeAreaBottom;
}
