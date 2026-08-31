import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/router.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';
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
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const HealthyLogApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Accesso effettuato'), findsOneWidget);

    container.read(goRouterProvider).go('/login');
    await tester.pumpAndSettle();

    expect(find.text('Accesso effettuato'), findsOneWidget);
    expect(find.text('Accedi'), findsNothing);
  });
}
