import 'package:flutter/material.dart';

import '../../features/identity/data/account_role.dart';
import '../../l10n/l10n_context.dart';

/// Voce della navigazione principale (3.1, 3.2 interfaccia.md).
///
/// [route] è assente per una voce non abilitata (2.6): non esiste ancora
/// una destinazione a cui condurre.
class AppDestination {
  const AppDestination({required this.icon, required this.label, this.route});

  final IconData icon;
  final String label;
  final String? route;

  bool get enabled => route != null;
}

/// Quattro voci per l'Utente, tre per il Nutrizionista (3.1 interfaccia.md).
/// *Attività* è la destinazione introdotta da F23 (10.1): allenamenti e
/// misure, dati strettamente personali, che il Nutrizionista non ha fra le
/// proprie voci (AL-17, PR-11 — li consulta dal dettaglio del Paziente).
/// *Statistiche* (11), abilitata dalla Fase 7, è parimenti riservata
/// all'Utente: il Nutrizionista raggiunge quelle del Paziente dal suo
/// dettaglio, nei limiti di ST-16bis.
///
/// Le icone Material sono le più prossime alle icone Lucide di 3.1
/// (calendar-days, activity, chart-line, user, users, file-text): stesso
/// criterio già seguito da `SlotTypePresentation` per gli slot.
List<AppDestination> destinationsFor(BuildContext context, AccountRole role) {
  final l10n = context.l10n;
  return switch (role) {
    AccountRole.user => [
        AppDestination(icon: Icons.calendar_month_outlined, label: l10n.navPlan, route: '/home'),
        AppDestination(icon: Icons.monitor_heart_outlined, label: l10n.navActivity, route: '/activity'),
        AppDestination(icon: Icons.show_chart, label: l10n.navStatistics, route: '/statistics'),
        AppDestination(icon: Icons.person_outline, label: l10n.navProfile, route: '/profile'),
      ],
    AccountRole.nutritionist => [
        AppDestination(icon: Icons.groups_outlined, label: l10n.navPatients, route: '/home'),
        AppDestination(icon: Icons.description_outlined, label: l10n.navTemplates, route: '/diet-plan-templates'),
        AppDestination(icon: Icons.person_outline, label: l10n.navProfile, route: '/profile'),
      ],
  };
}
