import 'package:flutter/widgets.dart';

/// Punti di rottura condivisi (3.3 interfaccia.md; FE-11, FE-12).
/// L'adattamento dipende dalla larghezza della finestra, mai dalla
/// piattaforma di esecuzione. Definiti una sola volta e impiegati
/// uniformemente: nessuna schermata introduce soglie proprie.
enum AppBreakpoint {
  /// < 600: telefono, finestra desktop stretta.
  compact,

  /// 600 – 899: tablet in verticale, finestra desktop media.
  medium,

  /// 900 – 1279: tablet in orizzontale, laptop.
  expanded,

  /// ≥ 1280: desktop, monitor esterno.
  large;

  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 900;
  static const double largeMinWidth = 1280;

  static AppBreakpoint fromWidth(double width) {
    if (width >= largeMinWidth) return AppBreakpoint.large;
    if (width >= expandedMinWidth) return AppBreakpoint.expanded;
    if (width >= mediumMinWidth) return AppBreakpoint.medium;
    return AppBreakpoint.compact;
  }

  bool get isCompact => this == AppBreakpoint.compact;

  /// `expanded` e `large`: da qui in su vale la disposizione estesa (3.3).
  bool get isAtLeastExpanded =>
      this == AppBreakpoint.expanded || this == AppBreakpoint.large;
}

extension AppBreakpointContext on BuildContext {
  AppBreakpoint get breakpoint =>
      AppBreakpoint.fromWidth(MediaQuery.sizeOf(this).width);
}
