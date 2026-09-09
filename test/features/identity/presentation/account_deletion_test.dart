import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/presentation/deletion_pending_screen.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

import '../../../support/l10n_test_support.dart';

/// PV-17, 12.2 interfaccia.md: durante il ripensamento l'accesso conduce
/// alla schermata che constata la richiesta, indica la data di
/// cancellazione definitiva e offre di annullarla.
void main() {
  testWidgets('constata la richiesta e la data di cancellazione (PV-17)', (tester) async {
    await _pump(tester, _ProfileAdapter());

    expect(find.text('Eliminazione richiesta'), findsOneWidget);
    expect(find.textContaining('16/09/2026'), findsOneWidget);
    expect(find.text('Annulla eliminazione'), findsOneWidget);
  });

  testWidgets('l\'annullamento revoca la richiesta sul server (PV-17)', (tester) async {
    final adapter = _ProfileAdapter();
    await _pump(tester, adapter);

    await tester.tap(find.text('Annulla eliminazione'));
    await tester.pumpAndSettle();

    expect(adapter.cancelCalls, 1);
  });
}

Future<void> _pump(WidgetTester tester, _ProfileAdapter adapter) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileApiProvider.overrideWithValue(ProfileApi(dio))],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: const DeletionPendingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ProfileAdapter implements HttpClientAdapter {
  int cancelCalls = 0;
  bool pending = true;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'DELETE' && options.path == '/me/deletion') {
      cancelCalls++;
      pending = false;
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
        'height': null,
        'targetWeightKg': null,
        'timezone': 'Europe/Rome',
        'locale': 'IT',
        'unitSystem': 'METRIC',
        'privacyAcceptanceRequired': false,
        'deletionRequestedAt': pending ? '2026-09-09T10:00:00Z' : null,
        'deletionEffectiveAt': pending ? '2026-09-16T10:00:00Z' : null,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
