import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/session_controller.dart';
import 'theme/theme_context.dart';

/// Verifica della sessione all'avvio (5.2 interfaccia.md): il solo
/// marchio, per un tempo che deve restare impercettibile. Conduce a
/// *Piano* (qui, provvisoriamente, alla destinazione temporanea) se una
/// sessione è stata ripristinata dal token di rinnovo (TK-8), altrimenti
/// all'accesso.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (session) => context.go(session == null ? '/login' : '/home'),
      );
    });

    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Text('HealthyLog', style: typography.titleLarge.copyWith(color: colors.textPrimary)),
      ),
    );
  }
}
