import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/presentation/group_screen.dart';
import 'package:healthylog/features/group/presentation/widgets/group_member_tile.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';

/// GE-1, GE-18: stato vuoto con le due azioni offerte in pari evidenza, e
/// creazione del Gruppo con il creatore Proprietario e Cuoco (8.1
/// interfaccia.md).
Map<String, dynamic> _profileJson() => {
      'id': 'user-1',
      'email': 'utente@esempio.test',
      'username': 'utente',
      'firstName': 'Mario',
      'lastName': 'Rossi',
      'birthDate': '2000-01-01',
      'birthPlace': 'Roma',
      'sex': 'MALE',
      'role': 'USER',
      'height': null,
      'timezone': 'Europe/Rome',
    };

/// Due membri, il secondo dei quali semplice: è quello su cui il
/// Proprietario agisce (GE-6, GE-7).
Map<String, dynamic> _groupWithMemberJson({required bool cook}) => {
      'id': 'group-1',
      'name': 'Casa Rossi',
      'ownerId': 'user-1',
      'members': [
        {
          'userId': 'user-1',
          'firstName': 'Mario',
          'lastName': 'Rossi',
          'owner': true,
          'cook': true,
          'joinedAt': '2026-09-01T00:00:00Z',
        },
        {
          'userId': 'user-2',
          'firstName': 'Anna',
          'lastName': 'Bianchi',
          'owner': false,
          'cook': cook,
          'joinedAt': '2026-09-02T00:00:00Z',
        },
      ],
      'createdAt': '2026-09-01T00:00:00Z',
    };

/// Il server dopo un'operazione sul membro: la composizione è mutata, e
/// la lettura successiva DEVE riferirla (GE-6, GE-7).
class _MemberOperationAdapter implements HttpClientAdapter {
  _MemberOperationAdapter();

  bool cook = false;
  bool removed = false;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH' && options.path.contains('/members/')) {
      cook = (options.data as Map)['cook'] as bool;
      return _jsonResponse(200, _groupWithMemberJson(cook: cook));
    }
    if (options.method == 'DELETE' && options.path.contains('/members/')) {
      removed = true;
      return _jsonResponse(200, _groupJson());
    }
    if (options.path.endsWith('/cooking-groups/current')) {
      return _jsonResponse(200, removed ? _groupJson() : _groupWithMemberJson(cook: cook));
    }
    if (options.path.contains('/invite-codes')) {
      return _jsonResponse(200, <Object>[]);
    }
    throw StateError('Richiesta non gestita dal test: ${options.method} ${options.path}');
  }
}

Map<String, dynamic> _groupJson() => {
      'id': 'group-1',
      'name': 'Casa Rossi',
      'ownerId': 'user-1',
      'members': [
        {
          'userId': 'user-1',
          'firstName': 'Mario',
          'lastName': 'Rossi',
          'owner': true,
          'cook': true,
          'joinedAt': '2026-09-01T00:00:00Z',
        },
      ],
      'createdAt': '2026-09-01T00:00:00Z',
    };

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return responder(options);
  }
}

ResponseBody _jsonResponse(int statusCode, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Nessun gruppo finché [created] non diventa vero, sul modello di un
/// server reale prima e dopo la creazione (GE-1, GE-2).
class _GroupLifecycleAdapter implements HttpClientAdapter {
  bool created = false;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'POST' && options.path.endsWith('/cooking-groups')) {
      created = true;
      return _jsonResponse(201, _groupJson());
    }
    if (options.path.endsWith('/cooking-groups/current')) {
      return created ? _jsonResponse(200, _groupJson()) : _jsonResponse(404, {'code': 'RESOURCE_NOT_FOUND'});
    }
    if (options.path.contains('/invite-codes')) {
      return _jsonResponse(200, <Object>[]);
    }
    throw StateError('Richiesta non gestita dal test: ${options.method} ${options.path}');
  }
}

Future<void> _pumpGroupScreen(
  WidgetTester tester, {
  required CookingGroupApi groupApi,
  Locale locale = testLocale,
}) async {
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter((_) => _jsonResponse(200, _profileJson()))
    ..interceptors.add(ApiErrorInterceptor());

  final router = GoRouter(
    initialLocation: '/group',
    routes: [GoRoute(path: '/group', builder: (context, state) => const GroupScreen())],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
        cookingGroupApiProvider.overrideWithValue(groupApi),
      ],
      child: MaterialApp.router(
      locale: locale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra lo stato vuoto con le due azioni (GE-18)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _JsonAdapter((_) => _jsonResponse(404, {'code': 'RESOURCE_NOT_FOUND'}))
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpGroupScreen(tester, groupApi: CookingGroupApi(dio));

    expect(find.text('Non fai parte di un gruppo'), findsOneWidget);
    expect(find.text('Crea un gruppo'), findsOneWidget);
    expect(find.text('Entra con un codice'), findsOneWidget);
  });

  testWidgets('una creazione riuscita mostra il dettaglio del gruppo (GE-1, GE-2)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _GroupLifecycleAdapter()
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpGroupScreen(tester, groupApi: CookingGroupApi(dio));
    expect(find.text('Non fai parte di un gruppo'), findsOneWidget);

    await tester.tap(find.text('Crea un gruppo'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Casa Rossi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(find.text('Casa Rossi'), findsOneWidget);
    expect(find.text('1 membro'), findsOneWidget);
    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('(tu)'), findsOneWidget);
    expect(find.text('Proprietario'), findsOneWidget);
  });

  /// GE-7, 8.2 interfaccia.md: la nomina a Cuoco muta la composizione, e
  /// la vista DEVE riferirla subito — il Proprietario non ha altro modo
  /// di sapere se l'operazione sia andata a buon fine (segnalato
  /// dall'utente).
  testWidgets('la nomina a Cuoco aggiorna subito la vista (GE-7)', (tester) async {
    final adapter = _MemberOperationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpGroupScreen(tester, groupApi: CookingGroupApi(dio));
    expect(find.text('Anna Bianchi'), findsOneWidget);
    expect(find.text('Cuoco'), findsNothing);

    await tester.tap(find.byType(PopupMenuButton<GroupMemberAction>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nomina Cuoco'));
    await tester.pumpAndSettle();

    expect(adapter.cook, isTrue);
    expect(find.text('Cuoco'), findsOneWidget);
  });

  /// GE-6: altrettanto vale per la rimozione — il membro rimosso deve
  /// sparire dall'elenco senza che occorra riaprire la schermata.
  testWidgets('la rimozione di un membro aggiorna subito la vista (GE-6)', (tester) async {
    final adapter = _MemberOperationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpGroupScreen(tester, groupApi: CookingGroupApi(dio));
    expect(find.text('Anna Bianchi'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<GroupMemberAction>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rimuovi dal gruppo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rimuovi'));
    await tester.pumpAndSettle();

    expect(adapter.removed, isTrue);
    expect(find.text('Anna Bianchi'), findsNothing);
    expect(find.text('1 membro'), findsOneWidget);
  });

  /// LO-1, FR-22: l'indicazione accanto al proprio nome era scritta a
  /// mano in italiano e restava tale in inglese. La prova la esercita
  /// nella lingua che ne rivelava l'assenza dalle traduzioni.
  testWidgets('l\'indicazione del proprio account è tradotta (LO-1, FR-22)', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _JsonAdapter((_) => _jsonResponse(200, _groupJson()))
      ..interceptors.add(ApiErrorInterceptor());

    await _pumpGroupScreen(tester, groupApi: CookingGroupApi(dio), locale: const Locale('en'));

    expect(find.text('(you)'), findsOneWidget);
    expect(find.text('(tu)'), findsNothing);
  });
}
