import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dietplan/providers/plan_day_providers.dart';
import '../../features/identity/providers/profile_providers.dart';
import '../app_breakpoints.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import 'app_destination.dart';

/// Involucro delle destinazioni principali (3.2 interfaccia.md): barra
/// inferiore su `compact`, barra laterale compatta su `medium`, barra
/// laterale estesa da `expanded` in su — le stesse soglie condivise
/// dell'intera applicazione (`app_breakpoints.dart`), non una soglia
/// propria.
///
/// Le sole voci *Piano*/*Pazienti* e *Profilo* sono avvolte da questo
/// involucro: le altre destinazioni abilitate (*Template* per il
/// Nutrizionista) si raggiungono con una normale navigazione in avanti
/// (schermo pieno, freccia di ritorno), non ancora integrate nella
/// stessa barra persistente — un'integrazione completa (`StatefulShellRoute`
/// di go_router, con conservazione dello stato di ciascuna destinazione,
/// 3.2) è rinviata a quando le destinazioni avranno un contenuto reale
/// da conservare (F23+, F25+), vedi decisioni.md.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(profileControllerProvider).value?.role;
    if (role == null) return child;

    final destinations = destinationsFor(role);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final selectedIndex = destinations.indexWhere(
      (d) => d.route == currentRoute,
    );

    void onSelect(int index) {
      final destination = destinations[index];
      if (!destination.enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${destination.label}: non ancora disponibile.'),
          ),
        );
        return;
      }
      if (destination.route == currentRoute) {
        // 6.2, VG-19: il doppio tocco sulla voce già selezionata di
        // *Piano* riporta alla giornata corrente, come l'azione "Oggi"
        // del selettore della data.
        if (destination.route == '/home') {
          ref.read(selectedDayProvider.notifier).select(DateTime.now());
        }
        return;
      }
      if (destination.route == '/home' || destination.route == '/profile') {
        context.go(destination.route!);
      } else {
        context.push(destination.route!);
      }
    }

    final breakpoint = context.breakpoint;
    if (breakpoint.isAtLeastExpanded) {
      return _RailScaffold(
        destinations: destinations,
        selectedIndex: selectedIndex,
        extended: true,
        onSelect: onSelect,
        child: child,
      );
    }
    if (breakpoint == AppBreakpoint.medium) {
      return _RailScaffold(
        destinations: destinations,
        selectedIndex: selectedIndex,
        extended: false,
        onSelect: onSelect,
        child: child,
      );
    }
    return _BottomBarScaffold(
      destinations: destinations,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
      child: child,
    );
  }
}

class _BottomBarScaffold extends StatelessWidget {
  const _BottomBarScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.child,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.dividerStrong)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.heightBottomNav,
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      key: ValueKey('navItem-${destinations[i].label}'),
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      axis: Axis.vertical,
                      showLabel: true,
                      onTap: () => onSelect(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailScaffold extends StatelessWidget {
  const _RailScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.extended,
    required this.onSelect,
    required this.child,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final bool extended;
  final ValueChanged<int> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(right: BorderSide(color: colors.dividerStrong)),
            ),
            child: SizedBox(
              width: extended
                  ? AppSpacing.widthNavigationRailExpanded
                  : AppSpacing.widthNavigationRailCompact,
              child: SafeArea(
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        _NavItem(
                          key: ValueKey('navItem-${destinations[i].label}'),
                          destination: destinations[i],
                          selected: i == selectedIndex,
                          axis: Axis.horizontal,
                          showLabel: extended,
                          onTap: () => onSelect(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Voce della barra (icona sopra, etichetta sotto — `Axis.vertical`) o
/// della barra laterale (icona a sinistra, etichetta a destra —
/// `Axis.horizontal`, solo se estesa): stessa selezione, stesso
/// trattamento del disabilitato (2.6), un solo widget per le tre
/// disposizioni.
class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.axis,
    required this.showLabel,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final Axis axis;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final Color color;
    if (!destination.enabled) {
      color = colors.textTertiary;
    } else if (selected) {
      color = colors.accent;
    } else {
      color = colors.textSecondary;
    }

    final icon = Icon(destination.icon, size: 24, color: color);
    final label = showLabel
        ? Text(
            destination.label,
            style:
                (axis == Axis.vertical
                        ? typography.caption
                        : typography.bodyMedium)
                    .copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    ),
          )
        : null;

    final content = axis == Axis.vertical
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (label != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  label,
                ],
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                icon,
                if (label != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  label,
                ],
              ],
            ),
          );

    final item = InkWell(
      onTap: onTap,
      child: SizedBox(
        height: axis == Axis.vertical ? double.infinity : null,
        child: Center(child: content),
      ),
    );
    // La barra laterale compatta è l'unico caso privo di etichetta
    // visibile: solo lì il suggerimento al passaggio del puntatore
    // (3.2 interfaccia.md) ha ragione d'essere.
    return showLabel ? item : Tooltip(message: destination.label, child: item);
  }
}
