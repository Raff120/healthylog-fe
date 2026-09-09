import '../../../support/notification_api_stub.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/plan_screen.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';

import '../../../support/care_api_stub.dart';
import '../../../support/workout_api_stub.dart';

/// Intestazione di *Piano* (6.1 interfaccia.md) su schermo stretto: il
/// segmented control ha larghezza 180 e non deve essere compresso né
/// accostato alle azioni, con o senza selettore del membro (4.2).
///
/// Le misure sono quelle di un iPhone 17 Pro (402×874 punti), il
/// dispositivo su cui l'utente ha segnalato che *Settimana* arrivava a
/// ridosso del bordo.

const _iPhone17Pro = Size(402, 874);

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._body, {this.status = 200});
  final Object? _body;
  final int status;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async =>
      ResponseBody.fromString(jsonEncode(_body), status,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
}

Map<String, dynamic> _dayJson() => {
      'date': isoDate(dateOnly(DateTime.now())),
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Dieta',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': <Map<String, dynamic>>[],
    };

Map<String, dynamic> _profileJson() => {
      'id': 'user-1',
      'email': 'raffaele@example.it',
      'username': 'raffaele',
      'firstName': 'Raffaele',
      'lastName': 'Cirillo',
      'birthDate': '1990-01-01',
      'birthPlace': 'Roma',
      'sex': 'MALE',
      'role': 'USER',
      'height': 180,
      'targetWeightKg': null,
      'timezone': 'Europe/Rome',
    };

Map<String, dynamic> _groupJson() => {
      'id': 'group-1',
      'name': 'Casa',
      'ownerId': 'user-1',
      'members': [
        {'userId': 'user-1', 'firstName': 'Raffaele', 'lastName': 'Cirillo', 'cook': true},
        {'userId': 'user-2', 'firstName': 'Giulia', 'lastName': 'Rossi', 'cook': false},
      ],
    };

Future<void> _pumpPlan(WidgetTester tester, {required bool withGroup}) async {
  tester.view.physicalSize = _iPhone17Pro;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter(_dayJson())
    ..interceptors.add(ApiErrorInterceptor());
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _JsonAdapter(_profileJson())
    ..interceptors.add(ApiErrorInterceptor());
  final groupDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = withGroup
        ? _JsonAdapter(_groupJson())
        : _JsonAdapter({'code': 'RESOURCE_NOT_FOUND'}, status: 404)
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(ProviderScope(
    overrides: [
      careApiProvider.overrideWithValue(stubCareApi()),
      // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
      // di ogni destinazione principale (3.1).
      notificationApiProvider.overrideWithValue(stubNotificationApi()),
      workoutApiProvider.overrideWithValue(stubWorkoutApi()),
      planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
      profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
      cookingGroupApiProvider.overrideWithValue(CookingGroupApi(groupDio)),
      appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const PlanScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('il segmented control conserva la propria larghezza con il selettore del membro (6.1, MP-2)',
      (tester) async {
    await _pumpPlan(tester, withGroup: true);

    final control = tester.getSize(find.text('Settimana').hitTestable());
    expect(control.width, greaterThan(0));
    final segmented = tester.getRect(
      find.ancestor(of: find.text('Giorno'), matching: find.byType(Row)).last,
    );
    // 6.1: larghezza complessiva 180, non compressa dal leading.
    expect(segmented.width, 180);
    // Respiro dal bordo destro dello schermo: il testo non vi si accosta.
    expect(_iPhone17Pro.width - segmented.right, greaterThanOrEqualTo(12));
  });

  testWidgets('il segmented control conserva la propria larghezza anche senza gruppo (6.1, GE-18)',
      (tester) async {
    await _pumpPlan(tester, withGroup: false);

    final segmented = tester.getRect(
      find.ancestor(of: find.text('Giorno'), matching: find.byType(Row)).last,
    );
    expect(segmented.width, 180);
  });
}
