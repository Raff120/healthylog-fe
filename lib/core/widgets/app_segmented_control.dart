import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';

/// Segmented control a due voci (6.1 e 10.1 interfaccia.md): unico
/// comando delle due granularità di *Piano* — *Giorno* · *Settimana* — e
/// dei due contenuti di *Attività* — *Allenamenti* · *Misure*. Il
/// medesimo meccanismo per la medesima ragione: due contenuti affini che
/// non meritano voci di navigazione distinte.
///
/// 180×32, curvatura piena, fondo in superficie alternativa; il segmento
/// attivo scorre in 280 ms (`AppSpacing.motionScreenTransition`).
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.firstSelected,
    required this.onSelectFirst,
    required this.onSelectSecond,
  });

  final String firstLabel;
  final String secondLabel;
  final bool firstSelected;
  final VoidCallback onSelectFirst;
  final VoidCallback onSelectSecond;

  static const _width = 180.0;
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: _width,
      height: _height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: AppSpacing.motionScreenTransition,
              curve: AppSpacing.motionSoftCurve,
              alignment: firstSelected ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                _Segment(label: firstLabel, active: firstSelected, onTap: onSelectFirst),
                _Segment(label: secondLabel, active: !firstSelected, onTap: onSelectSecond),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Center(
          child: Text(
            label,
            style: typography.label.copyWith(
              color: active ? colors.textPrimary : colors.textSecondary,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
