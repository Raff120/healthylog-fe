import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/offline_bar.dart';
import '../../features/dietplan/providers/plan_day_providers.dart';
import '../../features/identity/providers/profile_providers.dart';
import '../../l10n/l10n_context.dart';
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
/// Ogni destinazione abilitata del ruolo è avvolta da questo involucro
/// (*Piano*/*Pazienti*, *Template* per il Nutrizionista, *Profilo*). Una
/// rotta avvolta che per il ruolo corrente non sia una destinazione —
/// *Template* per l'Utente, raggiunta dalla creazione del piano (CT-1)
/// — è resa senza barra, come una normale schermata in avanti: la
/// stessa rotta serve così entrambi i ruoli (F22, vedi decisioni.md).
/// Un'integrazione completa (`StatefulShellRoute` di go_router, con
/// conservazione dello stato di ciascuna destinazione, 3.2) resta
/// rinviata a quando le destinazioni avranno un contenuto reale da
/// conservare (F23+, F25+).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(profileControllerProvider).value?.role;
    if (role == null) return child;

    final destinations = destinationsFor(context, role);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final selectedIndex = destinations.indexWhere(
      (d) => d.route == currentRoute,
    );
    if (selectedIndex == -1) return child;

    void onSelect(int index) {
      final destination = destinations[index];
      if (!destination.enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.navNotAvailableYet(destination.label)),
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
      // Le destinazioni della barra si sostituiscono a vicenda (3.2), non
      // si impilano: nessuna freccia di ritorno tra l'una e l'altra.
      context.go(destination.route!);
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
      body: Column(
        children: [const OfflineBar(), Expanded(child: child)],
      ),
      bottomNavigationBar: DecoratedBox(
        key: const ValueKey('bottomNavBar'),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.dividerStrong)),
        ),
        // La rientranza sta dentro la superficie della barra, non fuori:
        // sotto la barra non deve restare fascia di colore diverso, che sul
        // web mostrerebbe lo sfondo della pagina (vedi decisioni.md).
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
          Expanded(
            child: Column(
              children: [const OfflineBar(), Expanded(child: child)],
            ),
          ),
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
