import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/hydration/data/hydration_api.dart';
import 'package:healthylog/features/hydration/presentation/widgets/water_fab_menu.dart';
import 'package:healthylog/features/hydration/providers/hydration_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

import '../../../support/l10n_test_support.dart';

/// Pulsante mobile dell'acqua e suo ventaglio (AQ-5, AQ-6, AQ-7, AQ-16;
/// 6.2 interfaccia.md): offre l'azione e non la misura — nessun totale,
/// nessuna percentuale, nessun anello di avanzamento — dispiega quattro
/// voci, registra senza conferma e si richiude col velo.

class _HydrationAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/me/water-goal') return _json(200, {'valueMl': 2000});
    if (options.path == '/water-intakes' && options.method == 'GET') return _json(200, const <Object>[]);
    return _json(200, {'userId': 'user-1', 'date': '2026-09-18', 'totalMl': 150, 'entries': []});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

class _ProfileAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode({
          'id': 'user-1',
          'email': 'a@b.it',
          'emailVerified': true,
          'username': 'utente',
          'firstName': 'Nome',
          'lastName': 'Cognome',
          'birthDate': '1990-01-01',
          'birthPlace': 'Roma',
          'sex': 'MALE',
          'role': 'USER',
          'height': 180,
          'targetWeightKg': null,
          'timezone': 'Europe/Rome',
          'locale': 'IT',
          'unitSystem': 'METRIC',
          'privacyPolicyVersion': '1',
          'privacyAcceptedAt': '2026-01-01T00:00:00Z',
          'deletionRequestedAt': null,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Future<_HydrationAdapter> _pump(WidgetTester tester) async {
  final adapter = _HydrationAdapter();
  final hydrationDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _ProfileAdapter()
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hydrationApiProvider.overrideWithValue(HydrationApi(hydrationDio)),
        profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: const SizedBox.expand(),
          // 3.2: lo scostamento arriva dall'alto, dal chiamante che
          // conosce la barra fluttuante. Qui non ve n'è alcuna.
          floatingActionButton: WaterFabMenu(date: DateTime.now(), bottomInset: 0),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('offre l\'azione e non la misura: nessun totale sul pulsante (AQ-16, AQ-17)',
      (tester) async {
    await _pump(tester);

    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    // Nessun totale, nessun obiettivo, nessuna percentuale: quelli stanno
    // in *Statistiche*.
    expect(find.textContaining('ml'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('il tocco dispiega le quattro voci attorno al pulsante (AQ-6, AQ-7)', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('waterFab')));
    await tester.pumpAndSettle();

    expect(find.text('Bicchiere'), findsOneWidget);
    expect(find.text('150 ml'), findsOneWidget);
    expect(find.text('Bottiglietta'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
    expect(find.text('Bottiglia'), findsOneWidget);
    expect(find.text('1 L'), findsOneWidget);
    // AQ-7: la quantità libera, che non ha nome.
    expect(find.byIcon(Icons.add), findsOneWidget);
    // Il pulsante aperto richiude.
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('le voci stanno sopra e a sinistra del pulsante, entro lo schermo (6.2)', (tester) async {
    await _pump(tester);
    final fab = tester.getCenter(find.byKey(const Key('waterFab')));

    await tester.tap(find.byKey(const Key('waterFab')));
    await tester.pumpAndSettle();

    for (final label in ['Bicchiere', 'Bottiglietta', 'Bottiglia']) {
      final box = tester.getRect(
        find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first,
      );
      expect(box.right, lessThanOrEqualTo(fab.dx + WaterFabMenu.diameter / 2 + 1));
      expect(box.top, lessThan(fab.dy));
      expect(box.left, greaterThanOrEqualTo(0));
    }
  });

  testWidgets('il tocco su una voce registra e richiude, senza conferma (AQ-5)', (tester) async {
    final adapter = await _pump(tester);

    await tester.tap(find.byKey(const Key('waterFab')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bottiglietta'));
    await tester.pumpAndSettle();

    final posts = adapter.requests.where((r) => r.method == 'POST').toList();
    expect(posts, hasLength(1));
    expect(posts.single.data['amountMl'], 500);
    // Nessuna conferma, e il ventaglio si è richiuso.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Bottiglietta'), findsNothing);
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
  });

  testWidgets('il tocco sul velo richiude senza registrare nulla (6.2)', (tester) async {
    final adapter = await _pump(tester);

    await tester.tap(find.byKey(const Key('waterFab')));
    await tester.pumpAndSettle();
    // In alto a sinistra non v'è alcuna voce: solo il velo.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Bicchiere'), findsNothing);
    expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
  });
}
