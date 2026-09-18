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
/// inferiore fluttuante su `compact`, barra laterale compatta su `medium`, barra
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
      // Il corpo arriva sotto la pillola: una barra che fluttua sopra una
      // schermata che finisce dove lei comincia non fluttua, si vede il
      // taglio (segnalato dall'utente, vedi decisioni.md). Le destinazioni
      // lasciano perciò scorrere il contenuto sotto la barra e prendono da
      // `MediaQuery.padding` la spaziatura in coda che le compete
      // (`bottom_bar_insets.dart`), che `Scaffold` valorizza qui con
      // l'ingombro della barra.
      extendBody: true,
      body: Column(
        children: [const OfflineBar(), Expanded(child: child)],
      ),
      // La pillola non occupa la zona riservata al bordo inferiore dello
      // schermo ma le sta sopra: la rientranza è fuori dalla sua
      // superficie, e lo spazio che le resta intorno lo dipinge lo
      // sfondo della schermata. Sul web ciò è vero quanto sulle
      // piattaforme native — l'elemento ospite arriva al bordo dello
      // schermo e la zona riservata è riferita come `MediaQuery.padding`
      // (vedi decisioni.md): la fascia in fondo non mostra la pagina.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Material(
            key: const ValueKey('bottomNavBar'),
            // 2.4, 3.2: la barra ha una superficie propria, distinta da
            // quella delle card che le scorrono sotto in entrambi i temi —
            // altrimenti, dove una card le passa dietro, i due piani si
            // confondono (segnalato dall'utente, vedi decisioni.md).
            // L'ombra accompagna la distinzione nel tema chiaro, dove
            // funziona; nel tema scuro la distinzione è il colore, più
            // chiaro del fondo (2.4).
            color: colors.surfaceFloating,
            elevation: AppSpacing.elevationFloating,
            shadowColor: colors.shadowFloating,
            surfaceTintColor: colors.surfaceFloating,
            shape: StadiumBorder(side: BorderSide(color: colors.dividerStrong)),
            clipBehavior: Clip.antiAlias,
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
            child: Padding(
              // Il riquadro di riga dell'etichetta comprende, sotto la
              // linea di base, uno spazio che nessun glifo riempie:
              // centrare i riquadri porta perciò l'icona più vicina al
              // bordo superiore di quanto l'etichetta non lo sia
              // all'inferiore, e si vede (segnalato dall'utente). Lo
              // scarto si ricava dalla scala tipografica — l'interlinea
              // eccedente il corpo, di cui metà cade sotto la linea di
              // base — e si restituisce sopra l'icona.
              padding: EdgeInsets.only(top: _labelDescentSlack(typography.caption)),
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

/// Metà dell'interlinea eccedente il corpo dell'etichetta: quanto il
/// riquadro di riga lascia vuoto sotto la linea di base (2.3
/// interfaccia.md).
double _labelDescentSlack(TextStyle style) {
  final fontSize = style.fontSize ?? 0;
  final lineHeight = (style.height ?? 1) * fontSize;
  return (lineHeight - fontSize) / 2;
}
