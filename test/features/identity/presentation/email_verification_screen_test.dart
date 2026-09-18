import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/presentation/email_verification_waiting_screen.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';

import '../../../support/l10n_test_support.dart';

/// AU-11: la verifica dell'indirizzo avviene per codice ricopiato dal
/// messaggio, non più per collegamento aperto dal dispositivo (vedi
/// decisioni.md). Le prove riguardano i due esiti che l'Utente vede — la
/// conferma che prosegue e il codice rifiutato che resta sulla schermata
/// — e la richiesta effettivamente inviata, che deve recare l'indirizzo
/// insieme al codice: il codice, breve, non identifica alcun account.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;
  final List<Object?> sentBodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sentBodies.add(options.data);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Future<_RecordingAdapter> _pumpScreen(
  WidgetTester tester,
  int statusCode,
  String body, {
  bool redirectToLogin = false,
}) async {
  final adapter = _RecordingAdapter(statusCode, body);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ApiErrorInterceptor());

  final router = GoRouter(
    initialLocation: '/verify-email',
    routes: [
      GoRoute(
        path: '/verify-email',
        builder: (context, state) =>
            const EmailVerificationWaitingScreen(email: 'utente@example.it'),
      ),
      // La destinazione reale è una schermata con la propria Scaffold —
      // *Piano* o l'accesso: la barra di conferma vi si attacca, e senza
      // di quella non avrebbe dove comparire (4.5).
      //
      // Chi si è appena registrato non ha sessione, e l'instradamento lo
      // rimanda da sé all'accesso: la barra attraversa **due** cambi di
      // schermata, che è il caso segnalato dall'utente.
      GoRoute(
        path: '/home',
        redirect: (context, state) => redirectToLogin ? '/login' : null,
        builder: (context, state) => const Scaffold(body: Text('piano')),
      ),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('accesso'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [identityApiProvider.overrideWithValue(IdentityApi(dio))],
      child: MaterialApp.router(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('il codice completo conferma l\'indirizzo e prosegue', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(adapter.sentBodies.single, {'email': 'utente@example.it', 'code': '123456'});
    expect(find.text('piano'), findsOneWidget);
  });

  /// 4.5, 5.3: chi si registra non ha sessione, e la conferma lo riporta
  /// all'accesso. Senza constatazione si ritrovava davanti al modulo di
  /// accesso senza sapere se il codice fosse stato accolto (segnalato
  /// dall'utente).
  testWidgets('la conferma riuscita è constatata e sopravvive al cambio di schermata (4.5)',
      (tester) async {
    await _pumpScreen(tester, 204, '', redirectToLogin: true);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('accesso'), findsOneWidget);
    expect(
      find.widgetWithText(SnackBar, 'Indirizzo confermato: ora puoi accedere.'),
      findsOneWidget,
    );
  });

  testWidgets('il codice rifiutato resta sulla schermata e lo dichiara', (tester) async {
    await _pumpScreen(tester, 409, '{"code":"VERIFICATION_TOKEN_INVALID"}');

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text('piano'), findsNothing);
    expect(find.textContaining('Il codice non è valido'), findsOneWidget);
  });

  testWidgets('il codice incompleto non è inviato', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();

    expect(adapter.sentBodies, isEmpty);
  });
}
