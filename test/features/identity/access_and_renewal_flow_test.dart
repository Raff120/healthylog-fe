import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/router.dart';
import 'package:healthylog/core/api/api_client.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/token_refresh_interceptor.dart';
import 'package:healthylog/core/auth/session_controller.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/auth_models.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';
import 'package:healthylog/main.dart';

/// Task 7 di F06: il flusso di accesso (AC-8) e di rinnovo trasparente
/// (TK-13, TK-14) attraversati per intero, come li percorrerebbe
/// l'Utente — accesso da `LoginScreen`, instradamento a una schermata
/// protetta (`ProfileScreen`), scadenza del token durante la richiesta
/// del profilo e ripetizione automatica dopo il rinnovo. I singoli
/// meccanismi sono già provati isolatamente (`login_screen_test.dart`,
/// `token_refresh_interceptor_test.dart`, `session_controller_test.dart`,
/// `router_test.dart`): questo test verifica che, incatenati come
/// nell'app reale, producano lo stesso esito.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Accesso: token iniziale valido solo per un'unica richiesta protetta.
class _StubIdentityApi extends IdentityApi {
  _StubIdentityApi() : super(Dio());

  int loginCalls = 0;
  int refreshCalls = 0;

  @override
  Future<TokenPair> login(LoginRequest request) async {
    loginCalls++;
    return const TokenPair(accessToken: 'access-scaduto', refreshToken: 'refresh-1');
  }

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    refreshCalls++;
    return const TokenPair(accessToken: 'access-rinnovato', refreshToken: 'refresh-2');
  }
}

const _profileJson = '''
{
  "id": "u1",
  "email": "utente@example.it",
  "username": "utente",
  "firstName": "Maria",
  "lastName": "Rossi",
  "birthDate": "1990-01-01",
  "birthPlace": "Roma",
  "sex": "FEMALE",
  "role": "USER",
  "height": 170
}
''';

/// PA-10: `/home` è ora la vista giornaliera reale (F12), che alla prima
/// composizione richiede subito `GET /plan-days` — risposta neutra, priva
/// di copertura, non pertinente a ciò che questo test verifica.
const _planDayJson = '{'
    '"date":"2026-01-01","coverage":"NONE","planId":null,"planName":null,'
    '"planStartDate":null,"planEndDate":null,"slots":[]'
    '}';

/// `GET /me`: rifiuta il token rilasciato dall'accesso con
/// `TOKEN_EXPIRED` — come farebbe il backend con un token scaduto — e
/// accetta solo la richiesta ripetuta dopo il rinnovo (segnalata da
/// [TokenRefreshInterceptor] tramite `options.extra`). `GET /plan-days`,
/// emessa nel frattempo dalla vista giornaliera, è servita a parte: non
/// deve influire sul conteggio delle richieste di profilo verificato più
/// sotto.
class _MeAdapter implements HttpClientAdapter {
  int meRequests = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/plan-days')) {
      return ResponseBody.fromString(
        _planDayJson,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    meRequests++;
    final retried = options.extra['tokenRefreshRetried'] == true;
    if (!retried) {
      return ResponseBody.fromString(
        '{"code":"TOKEN_EXPIRED"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      _profileJson,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  testWidgets(
    'accesso, instradamento e rinnovo trasparente conducono al profilo',
    (tester) async {
      final identityApi = _StubIdentityApi();
      final meAdapter = _MeAdapter();

      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
          identityApiProvider.overrideWithValue(identityApi),
          // Stessa composizione di intercettori di `apiClientProvider`
          // (ordine incluso, vedi il relativo commento): solo il
          // trasporto è sostituito, per non ripetere sotto la logica
          // reale di `TokenRefreshInterceptor`.
          apiClientProvider.overrideWith((ref) {
            final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
            dio.httpClientAdapter = meAdapter;
            dio.interceptors.addAll([
              InterceptorsWrapper(
                onRequest: (options, handler) {
                  final accessToken = ref.read(sessionControllerProvider).value?.accessToken;
                  if (accessToken != null) {
                    options.headers['Authorization'] = 'Bearer $accessToken';
                  }
                  handler.next(options);
                },
              ),
              TokenRefreshInterceptor(ref, dio),
              ApiErrorInterceptor(),
            ]);
            return dio;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const HealthyLogApp()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Accedi'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'utente@example.it');
      await tester.enterText(find.byType(TextField).last, 'password-corretta');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      // AC-8, AC-11: l'accesso riuscito conduce a `/home`, non più a
      // `/login` (protezione delle rotte, task 6): vi si trova ora la
      // vista giornaliera reale (F12), priva di piano nella prova.
      expect(identityApi.loginCalls, 1);
      expect(find.text('Nessun piano per questo giorno'), findsOneWidget);

      container.read(goRouterProvider).push('/profile');
      await tester.pumpAndSettle();

      // Il profilo è comunque comparso: la scadenza incontrata dalla
      // prima richiesta non si è tradotta in un errore mostrato
      // all'Utente, perché il rinnovo l'ha risolta in modo trasparente
      // (TK-13) prima che `ProfileController` completasse.
      expect(meAdapter.meRequests, 2);
      expect(identityApi.refreshCalls, 1);
      expect(find.text('Maria Rossi'), findsOneWidget);
      expect(find.text('@utente'), findsOneWidget);

      // TK-11: il rinnovo ha sostituito la coppia di token — la sessione
      // porta ora quella rilasciata dal rinnovo, non più quella (scaduta)
      // rilasciata dall'accesso.
      final session = container.read(sessionControllerProvider).value;
      expect(session?.accessToken, 'access-rinnovato');
      expect(session?.refreshToken, 'refresh-2');
    },
  );
}
