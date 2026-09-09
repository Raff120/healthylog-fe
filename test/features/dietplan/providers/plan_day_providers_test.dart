import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

class _SucceedThenFailAdapter implements HttpClientAdapter {
  _SucceedThenFailAdapter(this._date);

  final DateTime _date;
  var _first = true;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_first) {
      _first = false;
      return ResponseBody.fromString(
        '{"date":"${isoDate(_date)}","coverage":"ACTIVE","planId":"p1","planName":"Dieta",'
        '"planStartDate":"2026-01-01","planEndDate":null,"slots":[{"slotId":"s1","type":"LUNCH",'
        '"label":null,"order":0,"content":"Pasta","note":null,"recipeName":null,"recipeText":null,'
        '"status":"TO_CONSUME"}]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException.connectionError(requestOptions: options, reason: 'no network');
  }
}

class _AlwaysNetworkErrorAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(requestOptions: options, reason: 'no network');
  }
}

/// Cache di sola lettura della vista giornaliera (PL-11, OF-19, F14):
/// popolata a ogni lettura online riuscita, consultata in sua assenza
/// solo per un errore di rete genuino.
void main() {
  test('scrive in cache alla lettura riuscita e la legge quando la rete manca', () async {
    // La settimana corrente reale: `PlanDayLocalCache.save` pulisce
    // anche fuori da essa (PL-10) a ogni salvataggio, quindi la data
    // usata qui deve caderci, non una qualunque del 2026.
    final date = dateOnly(DateTime.now());
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _SucceedThenFailAdapter(date)
      ..interceptors.add(ApiErrorInterceptor());

    final container = ProviderContainer(
      overrides: [
        planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
        appDatabaseProvider.overrideWith((ref) => AppDatabase(NativeDatabase.memory())),
      ],
    );
    addTearDown(container.dispose);

    final online = await container.read(planDayProvider(date).future);
    expect(online.slots.single.content, 'Pasta');

    container.invalidate(planDayProvider(date));
    final offline = await container.read(planDayProvider(date).future);
    expect(offline.slots.single.content, 'Pasta');
  });

  test('senza copia locale per la data, un errore di rete si propaga', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = _AlwaysNetworkErrorAdapter()
      ..interceptors.add(ApiErrorInterceptor());

    final container = ProviderContainer(
      overrides: [
        planDayApiProvider.overrideWithValue(PlanDayApi(dio)),
        appDatabaseProvider.overrideWith((ref) => AppDatabase(NativeDatabase.memory())),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(planDayProvider(DateTime(2026, 9, 7)).future),
      throwsA(anything),
    );
  });
}
