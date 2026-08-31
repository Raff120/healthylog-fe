import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/presentation/login_screen.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';

/// Regressione: `AsyncValue.guard` cattura il [DioException] lanciato da
/// dio, non l'[ApiException] al suo interno (vedi
/// `core/api/api_exception_test.dart`). Un controllo diretto
/// `error is ApiException` nella schermata è sempre falso e ogni esito
/// — comprese le credenziali errate — cade nel ramo generico. Questo
/// test esercita `LoginScreen` per intero, non solo l'estrazione
/// dell'errore, perché è lì che il difetto si è manifestato.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}

class _StatusCodeAdapter implements HttpClientAdapter {
  _StatusCodeAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

IdentityApi _identityApiReturning(int statusCode, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _StatusCodeAdapter(statusCode, body);
  dio.interceptors.add(ApiErrorInterceptor());
  return IdentityApi(dio);
}

Future<void> _pumpLoginScreen(WidgetTester tester, IdentityApi identityApi) async {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/verify-email', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/password-reset', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/register', builder: (context, state) => const SizedBox()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
        identityApiProvider.overrideWithValue(identityApi),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('credenziali errate mostrano il messaggio indistinto (AC-9)', (tester) async {
    await _pumpLoginScreen(tester, _identityApiReturning(401, '{"code":"INVALID_CREDENTIALS"}'));

    await tester.enterText(find.byType(TextField).first, 'utente@example.it');
    await tester.enterText(find.byType(TextField).last, 'password-sbagliata');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Indirizzo o password non corretti.'), findsOneWidget);
  });

  testWidgets('un guasto di rete non si presenta come credenziali errate', (tester) async {
    await _pumpLoginScreen(tester, _identityApiReturning(500, ''));

    await tester.enterText(find.byType(TextField).first, 'utente@example.it');
    await tester.enterText(find.byType(TextField).last, 'password-qualunque');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Indirizzo o password non corretti.'), findsNothing);
    expect(find.text('Connessione assente. Riprova.'), findsOneWidget);
  });

  testWidgets('un account non verificato conduce alla verifica, non a un errore', (tester) async {
    await _pumpLoginScreen(tester, _identityApiReturning(403, '{"code":"ACCOUNT_NOT_VERIFIED"}'));

    await tester.enterText(find.byType(TextField).first, 'utente@example.it');
    await tester.enterText(find.byType(TextField).last, 'password-qualunque');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Indirizzo o password non corretti.'), findsNothing);
  });
}
