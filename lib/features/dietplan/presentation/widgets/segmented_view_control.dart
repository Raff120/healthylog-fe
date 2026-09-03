import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../providers/plan_day_providers.dart';

/// Segmented control *Giorno* · *Settimana* (6.1 interfaccia.md): unico
/// comando delle due granularità di *Piano*. 180×32, curvatura piena,
/// fondo in superficie alternativa; il segmento attivo scorre in 280 ms
/// (`AppSpacing.motionScreenTransition`).
class SegmentedViewControl extends StatelessWidget {
  const SegmentedViewControl({super.key, required this.value, required this.onChanged});

  final PlanViewMode value;
  final ValueChanged<PlanViewMode> onChanged;

  static const _width = 180.0;
  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDay = value == PlanViewMode.day;

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
              alignment: isDay ? Alignment.centerLeft : Alignment.centerRight,
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
                _Segment(label: 'Giorno', active: isDay, onTap: () => onChanged(PlanViewMode.day)),
                _Segment(label: 'Settimana', active: !isDay, onTap: () => onChanged(PlanViewMode.week)),
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
