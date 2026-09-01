import 'package:flutter/material.dart';

import '../../features/identity/data/account_role.dart';

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
/// Attività e Statistiche non hanno ancora una schermata propria (F23+,
/// F25+): restano visibili e disabilitate (2.6, "l'elemento disabilitato
/// resta visibile"), non nascoste — non si tratta di un'esclusione per
/// ruolo, l'unico caso in cui 2.6 prescrive di ometterle del tutto.
///
/// Le icone Material sono le più prossime alle icone Lucide di 3.1
/// (calendar-days, activity, chart-line, user, users, file-text): stesso
/// criterio già seguito da `SlotTypePresentation` per gli slot.
List<AppDestination> destinationsFor(AccountRole role) => switch (role) {
      AccountRole.user => const [
          AppDestination(icon: Icons.calendar_month_outlined, label: 'Piano', route: '/home'),
          AppDestination(icon: Icons.monitor_heart_outlined, label: 'Attività'),
          AppDestination(icon: Icons.show_chart, label: 'Statistiche'),
          AppDestination(icon: Icons.person_outline, label: 'Profilo', route: '/profile'),
        ],
      AccountRole.nutritionist => const [
          AppDestination(icon: Icons.groups_outlined, label: 'Pazienti', route: '/home'),
          AppDestination(icon: Icons.description_outlined, label: 'Template', route: '/diet-plan-templates'),
          AppDestination(icon: Icons.person_outline, label: 'Profilo', route: '/profile'),
        ],
    };
