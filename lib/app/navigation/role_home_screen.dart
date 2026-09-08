import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/care/presentation/patients_screen.dart';
import '../../features/dietplan/presentation/plan_screen.dart';
import '../../features/identity/data/account_role.dart';
import '../../features/identity/providers/profile_providers.dart';

/// Destinazione iniziale (3.1 interfaccia.md): *Piano* per l'Utente,
/// *Pazienti* per il Nutrizionista (F22). Il ruolo arriva con il profilo:
/// finché non è noto non si mostra nessuna delle due, per non avviare le
/// richieste di una schermata che non spetta a chi guarda.
class RoleHomeScreen extends ConsumerWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(profileControllerProvider).value?.role;
    return switch (role) {
      null => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AccountRole.nutritionist => const PatientsScreen(),
      AccountRole.user => const PlanScreen(),
    };
  }
}
