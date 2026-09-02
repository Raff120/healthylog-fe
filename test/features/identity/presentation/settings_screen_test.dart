import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/presentation/settings_screen.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

/// 12.2 interfaccia.md, LO-13 (F11, deroga: vedi decisioni.md): tema e
/// fuso orario, più il collegamento a "Dispositivi collegati", spostato
/// qui dal Profilo.
class _InMemoryPreferencesStore extends PreferencesStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

Map<String, dynamic> _profileJson(String timezone) => {
      'id': 'user-1',
      'email': 'utente@esempio.test',
      'username': 'utente',
      'firstName': 'Nome',
      'lastName': 'Cognome',
      'birthDate': '2000-01-01',
      'birthPlace': 'Roma',
      'sex': 'MALE',
      'role': 'USER',
      'height': null,
      'timezone': timezone,
    };

class _ProfileAdapter implements HttpClientAdapter {
  _ProfileAdapter(this._timezone);

  String _timezone;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH' && options.path == '/me/timezone') {
      _timezone = (options.data as Map)['timezone'] as String;
    }
    return ResponseBody.fromString(
      jsonEncode(_profileJson(_timezone)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Future<void> _pumpSettingsScreen(WidgetTester tester, {required Dio dio, required PreferencesStore store}) async {
  final router = GoRouter(
    initialLocation: '/profile/settings',
    routes: [
      GoRoute(path: '/profile/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/profile/devices', builder: (context, state) => const Scaffold(body: Text('Dispositivi'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileApiProvider.overrideWithValue(ProfileApi(dio)),
        preferencesStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra il fuso orario corrente e permette di cambiarlo', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _ProfileAdapter('Europe/Rome')
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpSettingsScreen(tester, dio: dio, store: _InMemoryPreferencesStore());

    expect(find.text('Roma'), findsOneWidget);

    await tester.tap(find.text('Fuso orario'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New York');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'New York'));
    await tester.pumpAndSettle();

    expect(find.text('New York'), findsOneWidget);
    expect(find.text('Roma'), findsNothing);
  });

  testWidgets('la selezione del tema persiste nell\'archivio locale (FE-18)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _ProfileAdapter('Europe/Rome')
      ..interceptors.add(ApiErrorInterceptor());
    final store = _InMemoryPreferencesStore();

    await _pumpSettingsScreen(tester, dio: dio, store: store);

    await tester.tap(find.text('Scuro'));
    await tester.pumpAndSettle();

    expect(store.values['theme_mode'], ThemeMode.dark.name);
  });

  testWidgets('"Dispositivi collegati" conduce alla propria schermata (12.2)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _ProfileAdapter('Europe/Rome')
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpSettingsScreen(tester, dio: dio, store: _InMemoryPreferencesStore());

    await tester.tap(find.text('Dispositivi collegati'));
    await tester.pumpAndSettle();

    expect(find.text('Dispositivi'), findsOneWidget);
  });
}
