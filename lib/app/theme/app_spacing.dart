import 'package:flutter/animation.dart';

/// Spaziature, forme e densità (2.4 interfaccia.md). Primitiva del tema
/// (FE-16): nessuna spaziatura arbitraria nei widget (FE-15).
class AppSpacing {
  const AppSpacing._();

  // Scala delle spaziature, sistema a base 4.
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Margini di schermata.
  static const double screenMarginPhone = 16;
  static const double screenMarginTablet = 24;
  static const double screenMarginDesktop = 32;

  // Raggi di curvatura.
  static const double radiusNone = 0;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusFull = 999;

  // Bersagli di interazione.
  static const double minInteractiveTarget = 44;
  static const double minTargetGap = xs;

  // Densità — altezze indicative.
  static const double heightListItemOneLine = 52;
  static const double heightListItemTwoLines = 68;
  static const double heightMealCardCompact = 72;
  static const double heightTextField = 52;
  static const double heightButton = 48;
  static const double heightBottomNav = 56;
  static const double heightScreenHeader = 56;

  // Larghezza massima del contenuto.
  static const double maxWidthSingleColumn = 720;
  static const double maxWidthWide = 1280;

  // Movimento.
  static const Duration motionImmediate = Duration(milliseconds: 120);
  static const Duration motionStateTransition = Duration(milliseconds: 200);
  static const Duration motionScreenTransition = Duration(milliseconds: 280);
  static const Duration motionModalSheet = Duration(milliseconds: 320);

  static const Curve motionImmediateCurve = Curves.easeOut;
  static const Curve motionSoftCurve = Curves.easeInOut;
  static const Curve motionDecelerateCurve = Curves.decelerate;
}
