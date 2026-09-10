import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/presentation/change_password_screen.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

import '../../../support/l10n_test_support.dart';

/// AC-19, AU-20: la modifica della password richiede quella corrente.
/// Le prove riguardano ciò che l'Utente vede — la password corrente
/// errata segnalata sul proprio campo e non altrove, la conferma
/// discorde che non parte — e la richiesta effettivamente inviata.
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

Future<_RecordingAdapter> _pumpScreen(WidgetTester tester, int statusCode, String body) async {
  final adapter = _RecordingAdapter(statusCode, body);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ApiErrorInterceptor());

  // La schermata torna indietro alla conferma: il banco di prova deve
  // avere un dietro cui tornare, come l'applicazione, dove vi si arriva
  // dai *Dati personali*.
  final router = GoRouter(
    initialLocation: '/profile/personal-data',
    routes: [
      GoRoute(
        path: '/profile/personal-data',
        builder: (context, state) => const Scaffold(body: Text('dati personali')),
      ),
      GoRoute(
        path: '/profile/personal-data/password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileApiProvider.overrideWithValue(ProfileApi(dio))],
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
  router.push('/profile/personal-data/password');
  await tester.pumpAndSettle();
  return adapter;
}

Future<void> _fill(
  WidgetTester tester, {
  required String current,
  required String next,
  required String confirm,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), confirm);
  await tester.tap(find.text('Salva'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('invia la password corrente insieme alla nuova', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await _fill(tester, current: 'vecchia123', next: 'nuovissima1', confirm: 'nuovissima1');

    expect(adapter.sentBodies.single, {
      'currentPassword': 'vecchia123',
      'newPassword': 'nuovissima1',
    });
    // La conferma riporta ai *Dati personali*, da cui si era venuti.
    expect(find.text('dati personali'), findsOneWidget);
  });

  testWidgets('la password corrente errata è segnalata sul proprio campo', (tester) async {
    await _pumpScreen(tester, 401, '{"code":"INVALID_CREDENTIALS"}');

    await _fill(tester, current: 'sbagliata1', next: 'nuovissima1', confirm: 'nuovissima1');

    expect(find.text('La password attuale non è corretta'), findsOneWidget);
  });

  testWidgets('la conferma discorde non invia nulla', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await _fill(tester, current: 'vecchia123', next: 'nuovissima1', confirm: 'nuovissima2');

    expect(adapter.sentBodies, isEmpty);
    expect(find.text('Le password non coincidono'), findsOneWidget);
  });

  testWidgets('la nuova password troppo corta non è inviata', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await _fill(tester, current: 'vecchia123', next: 'corta', confirm: 'corta');

    expect(adapter.sentBodies, isEmpty);
  });

  testWidgets('la nuova password uguale alla corrente non è inviata', (tester) async {
    final adapter = await _pumpScreen(tester, 204, '');

    await _fill(tester, current: 'identica123', next: 'identica123', confirm: 'identica123');

    expect(adapter.sentBodies, isEmpty);
    expect(find.text('La nuova password coincide con quella attuale'), findsOneWidget);
  });
}
