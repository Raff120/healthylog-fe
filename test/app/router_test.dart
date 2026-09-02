import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/router.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/main.dart';

/// Protezione delle rotte (5.2 interfaccia.md: "Chi ha una sessione
/// attiva non incontra questa schermata"; task 6 di F06). Verificato
/// tramite l'app reale (`HealthyLogApp`) e il router reale
/// (`goRouterProvider`), non un router minimo di prova: è proprio la
/// funzione `redirect` centralizzata a dover essere esercitata.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
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
  return IdentityApi(dio);
}

const _profileJson = '{'
    '"id":"user-1","email":"utente@esempio.test","username":"utente",'
    '"firstName":"Nome","lastName":"Cognome","birthDate":"2000-01-01",'
    '"birthPlace":"Roma","sex":"MALE","role":"USER","height":null'
    '}';

ProfileApi _profileApiReturning(int statusCode, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _StatusCodeAdapter(statusCode, body);
  return ProfileApi(dio);
}

/// PA-10: nessun piano non è un errore — la giornata di prova risulta
/// semplicemente priva di copertura.
const _planDayJson = '{'
    '"date":"2026-01-01","coverage":"NONE","planId":null,"planName":null,'
    '"planStartDate":null,"planEndDate":null,"slots":[]'
    '}';

PlanDayApi _planDayApiReturning(int statusCode, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _StatusCodeAdapter(statusCode, body);
  return PlanDayApi(dio);
}

void main() {
  testWidgets('una rotta protetta senza sessione reindirizza all\'accesso', (tester) async {
    final container = ProviderContainer(
      overrides: [
        secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const HealthyLogApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);

    container.read(goRouterProvider).go('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Accedi'), findsOneWidget);
  });

  testWidgets('le schermate di accesso non sono raggiungibili con una sessione attiva', (tester) async {
    final store = _InMemorySecureKeyValueStore()..values['refresh_token'] = 'token-valido';
    final container = ProviderContainer(
      overrides: [
        secureKeyValueStoreProvider.overrideWithValue(store),
        identityApiProvider.overrideWithValue(
          _identityApiReturning(200, '{"accessToken":"a","refreshToken":"r"}'),
        ),
        // MainShell (3.2 interfaccia.md) legge il ruolo dal profilo per
        // comporre la barra di navigazione, avvolgendo ora anche /home.
        profileApiProvider.overrideWithValue(_profileApiReturning(200, _profileJson)),
        // /home è ora la vista giornaliera reale (F12), non più la
        // destinazione temporanea di F06.
        planDayApiProvider.overrideWithValue(_planDayApiReturning(200, _planDayJson)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const HealthyLogApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nessun piano per questo giorno'), findsOneWidget);

    container.read(goRouterProvider).go('/login');
    await tester.pumpAndSettle();

    expect(find.text('Nessun piano per questo giorno'), findsOneWidget);
    expect(find.text('Accedi'), findsNothing);
  });
}
