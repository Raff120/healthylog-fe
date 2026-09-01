import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/auth/session.dart';
import '../core/auth/session_controller.dart';
import '../features/dietplan/data/diet_plan_template.dart';
import '../features/dietplan/presentation/create_diet_plan_screen.dart';
import '../features/dietplan/presentation/diet_plan_management_screen.dart';
import '../features/dietplan/presentation/diet_plan_schedule_screen.dart';
import '../features/dietplan/presentation/diet_plan_template_list_screen.dart';
import '../features/dietplan/presentation/diet_plan_template_preview_screen.dart';
import '../features/dietplan/presentation/diet_plan_template_schedule_screen.dart';
import '../features/identity/data/account_role.dart';
import '../features/identity/presentation/devices_screen.dart';
import '../features/identity/presentation/email_verification_link_screen.dart';
import '../features/identity/presentation/email_verification_waiting_screen.dart';
import '../features/identity/presentation/login_screen.dart';
import '../features/identity/presentation/password_reset_confirm_screen.dart';
import '../features/identity/presentation/password_reset_request_screen.dart';
import '../features/identity/presentation/personal_data_screen.dart';
import '../features/identity/presentation/profile_screen.dart';
import '../features/identity/presentation/registration_details_screen.dart';
import '../features/identity/presentation/role_selection_screen.dart';
import 'navigation/main_shell.dart';
import 'placeholder_home_screen.dart';
import 'splash_screen.dart';

part 'router.g.dart';

/// Percorsi raggiungibili solo **prima** di una sessione (5.2
/// interfaccia.md: "Chi ha una sessione attiva non incontra questa
/// schermata"). Un accesso già presente vi rimanda a `/home`.
const _preLoginOnlyPaths = ['/login', '/register', '/verify-email'];

/// Percorsi raggiungibili **a prescindere** dalla sessione: collegamenti
/// aperti da un messaggio di posta (AU-16), che possono capitare mentre
/// un'altra sessione è già attiva altrove — forzare un instradamento in
/// base allo stato dell'Utente sarebbe qui spiazzante, non protettivo.
const _alwaysAllowedPaths = ['/verify-email/confirm', '/password-reset'];

bool _startsWithAny(String path, List<String> prefixes) =>
    prefixes.any((prefix) => path == prefix || path.startsWith('$prefix/'));

/// Bridge minimo fra lo stato Riverpod della sessione e il
/// `Listenable` richiesto da `refreshListenable` di go_router, così
/// che una rotta protetta sia rivalutata non appena la sessione cambia
/// (accesso, disconnessione, ripristino), non solo alla navigazione.
class _SessionRouterRefresh extends ChangeNotifier {
  _SessionRouterRefresh(this._ref) {
    _subscription = _ref.listen(sessionControllerProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<AuthSession?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Instradamento (FE-3): ogni schermata corrisponde a un indirizzo (3.2
/// interfaccia.md). Le schermate esterne all'applicazione (3.1) sono
/// definite qui. La protezione delle rotte autenticate è centralizzata
/// nel `redirect` sottostante — un solo punto di decisione, non
/// duplicato nelle singole schermate (vedi il commento su
/// [SplashScreen]).
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refresh = _SessionRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final path = state.matchedLocation;

      // Ripristino ancora in corso (TK-8): resta sulla sola schermata
      // pensata per attenderlo (5.2 interfaccia.md), che infatti non
      // compare fra le rotte sempre ammesse — altrove si tornerebbe
      // comunque qui.
      if (session.isLoading) {
        return path == '/splash' ? null : '/splash';
      }

      if (_startsWithAny(path, _alwaysAllowedPaths)) return null;

      final loggedIn = session.value != null;
      final isPreLoginOnly = _startsWithAny(path, _preLoginOnlyPaths);

      if (!loggedIn) {
        return isPreLoginOnly ? null : '/login';
      }
      if (isPreLoginOnly || path == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register/details',
        // `extra` non sopravvive a un ricaricamento diretto
        // dell'indirizzo (path senza `#`, FE-3): senza il ruolo scelto
        // al passaggio precedente non c'è nulla da mostrare qui.
        redirect: (context, state) => state.extra is AccountRole ? null : '/register',
        builder: (context, state) => RegistrationDetailsScreen(role: state.extra as AccountRole),
      ),
      GoRoute(
        path: '/verify-email',
        redirect: (context, state) => state.extra is String ? null : '/login',
        builder: (context, state) => EmailVerificationWaitingScreen(email: state.extra as String),
      ),
      GoRoute(
        path: '/verify-email/confirm',
        builder: (context, state) =>
            EmailVerificationLinkScreen(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetRequestScreen(),
      ),
      GoRoute(
        path: '/password-reset/confirm',
        builder: (context, state) =>
            PasswordResetConfirmScreen(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(child: PlaceholderHomeScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainShell(child: ProfileScreen()),
      ),
      GoRoute(
        path: '/profile/personal-data',
        builder: (context, state) => const PersonalDataScreen(),
      ),
      GoRoute(path: '/profile/devices', builder: (context, state) => const DevicesScreen()),
      GoRoute(path: '/profile/plans', builder: (context, state) => const DietPlanManagementScreen()),
      GoRoute(
        path: '/diet-plans/new',
        builder: (context, state) =>
            CreateDietPlanScreen(sourceTemplate: state.extra as DietPlanTemplate?),
      ),
      GoRoute(
        path: '/diet-plans/:id/schedule',
        builder: (context, state) => DietPlanScheduleScreen(planId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/diet-plan-templates', builder: (context, state) => const DietPlanTemplateListScreen()),
      GoRoute(
        path: '/diet-plan-templates/:id',
        builder: (context, state) => DietPlanTemplatePreviewScreen(templateId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/diet-plan-templates/:id/schedule',
        builder: (context, state) =>
            DietPlanTemplateScheduleScreen(templateId: state.pathParameters['id']!),
      ),
    ],
  );
}
