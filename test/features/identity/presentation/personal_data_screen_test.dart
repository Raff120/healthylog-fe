import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/presentation/personal_data_screen.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

import '../../../support/l10n_test_support.dart';

/// Dati personali (12.1 interfaccia.md, PR-1, PR-4, PR-6).
///
/// I due obiettivi — peso e acqua — non vi stanno più: si impostano da
/// *Statistiche*, dove il riferimento che ne discende è sotto gli occhi
/// (11.1 e 11.3, segnalato dall'utente, vedi decisioni.md).

Future<_ProfileAdapter> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final adapter = _ProfileAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  // Il salvataggio riuscito torna indietro (`context.pop`): serve un
  // instradamento che abbia dove tornare.
  final router = GoRouter(
    initialLocation: '/profile/personal-data',
    routes: [
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(body: Text('profilo')),
        routes: [
          GoRoute(
            path: 'personal-data',
            builder: (context, state) => const PersonalDataScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

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
  return adapter;
}

void main() {
  testWidgets('non reca più i due obiettivi (PR-8, AQ-11)', (tester) async {
    await _pump(tester);

    expect(find.text('Luogo di nascita'), findsOneWidget);
    expect(find.textContaining('Peso obiettivo'), findsNothing);
    expect(find.textContaining('Obiettivo d’acqua'), findsNothing);
  });

  /// `PATCH /me` porta il profilo per intero, e il campo assente rimuove
  /// il peso obiettivo (PR-10): ometterlo dal modulo che non lo presenta
  /// più lo cancellerebbe a ogni salvataggio.
  testWidgets('il salvataggio conserva il peso obiettivo vigente (PR-8, PR-10)',
      (tester) async {
    final adapter = await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Mario'), 'Marco');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(adapter.updates.single['firstName'], 'Marco');
    expect(adapter.updates.single['targetWeightKg'], 72.0);
  });
}

class _ProfileAdapter implements HttpClientAdapter {
  final updates = <Map<String, dynamic>>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH' && options.path == '/me') {
      updates.add(Map<String, dynamic>.from(options.data as Map));
    }
    return ResponseBody.fromString(
      jsonEncode({
        'id': 'user-1',
        'email': 'utente@example.it',
        'username': 'utente',
        'firstName': 'Mario',
        'lastName': 'Rossi',
        'birthDate': '1990-01-01',
        'birthPlace': 'Roma',
        'sex': 'MALE',
        'role': 'USER',
        'height': 178,
        'targetWeightKg': 72.0,
        'timezone': 'Europe/Rome',
        'locale': 'IT',
        'unitSystem': 'METRIC',
        'privacyAcceptanceRequired': false,
        'deletionRequestedAt': null,
        'deletionEffectiveAt': null,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
