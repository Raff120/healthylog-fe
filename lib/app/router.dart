import 'package:go_router/go_router.dart';

import '../features/identity/data/account_role.dart';
import '../features/identity/presentation/email_verification_link_screen.dart';
import '../features/identity/presentation/email_verification_waiting_screen.dart';
import '../features/identity/presentation/login_screen.dart';
import '../features/identity/presentation/password_reset_confirm_screen.dart';
import '../features/identity/presentation/password_reset_request_screen.dart';
import '../features/identity/presentation/registration_details_screen.dart';
import '../features/identity/presentation/role_selection_screen.dart';
import 'placeholder_home_screen.dart';

/// Instradamento (FE-3): ogni schermata corrisponde a un indirizzo (3.2
/// interfaccia.md). Le schermate esterne all'applicazione (3.1) sono
/// definite qui; la protezione delle rotte autenticate è compito di un
/// task successivo di F06.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/register/details',
      builder: (context, state) => RegistrationDetailsScreen(role: state.extra as AccountRole),
    ),
    GoRoute(
      path: '/verify-email',
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
    GoRoute(path: '/home', builder: (context, state) => const PlaceholderHomeScreen()),
  ],
);
