import '../../../support/l10n_test_support.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/measurement/data/measurement_api.dart';
import 'package:healthylog/features/measurement/data/measurement_models.dart';
import 'package:healthylog/features/measurement/presentation/measurement_list.dart';
import 'package:healthylog/features/measurement/presentation/widgets/measurement_sheet.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';

/// Misurazioni (11.3 interfaccia.md, già 10.3): PR-13 (almeno un
/// valore), PR-14 (nessun vincolo di frequenza), PR-17/AN-5 (fonte
/// distinta e non modificabile dal Paziente), AN-11 (nessuna
/// elaborazione nell'elenco).
///
/// L'elenco vive ora nel segmento *Corpo* di *Statistiche*, che gli
/// passa le misurazioni del periodo: le prove lo esercitano da sé, con
/// le misurazioni date, e non attraverso la schermata che lo ospita
/// (vedi decisioni.md).

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Map<String, dynamic> _measurement({
  required String id,
  required DateTime date,
  double? weightKg,
  Map<String, dynamic>? circumferences,
  String role = 'USER',
  bool editable = true,
}) =>
    {
      'id': id,
      'userId': 'user-1',
      'date': _isoDate(date),
      'weightKg': weightKg,
      'circumferences': circumferences ??
          {'waist': null, 'hips': null, 'chest': null, 'arm': null, 'thigh': null},
      'note': null,
      'recordedBy': role == 'USER' ? 'user-1' : 'nutritionist-1',
      'recordedByRole': role,
      'editable': editable,
    };

class _MeasurementAdapter implements HttpClientAdapter {
  _MeasurementAdapter(this.measurements);

  final List<Map<String, dynamic>> measurements;
  final posted = <Map<String, dynamic>>[];
  final deleted = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'DELETE') {
      deleted.add(options.path);
      return _json(204, const <String, Object>{});
    }
    if (options.method == 'POST') {
      posted.add(Map<String, dynamic>.from(options.data as Map));
      return _json(201, measurements.isEmpty ? _measurement(id: 'm-new', date: DateTime.now()) : measurements.first);
    }
    return _json(200, measurements);
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

Future<_MeasurementAdapter> _pumpList(
  WidgetTester tester,
  List<Map<String, dynamic>> measurements,
) async {
  final adapter = _MeasurementAdapter(measurements);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [measurementApiProvider.overrideWithValue(MeasurementApi(dio))],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MeasurementList(items: measurements.map(BodyMeasurement.fromJson).toList()),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

Future<_MeasurementAdapter> _pumpSheet(WidgetTester tester) async {
  final adapter = _MeasurementAdapter(const []);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [measurementApiProvider.overrideWithValue(MeasurementApi(dio))],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showMeasurementSheet(context),
                child: const Text('Apri'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Apri'));
  await tester.pumpAndSettle();
  return adapter;
}

/// Il foglio scorre: il pulsante di salvataggio va portato in vista prima
/// di toccarlo.
Future<void> _tapSave(WidgetTester tester) async {
  final save = find.widgetWithText(ElevatedButton, 'Salva');
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('impedisce il salvataggio di un modulo interamente vuoto (PR-13)', (tester) async {
    final adapter = await _pumpSheet(tester);

    await _tapSave(tester);

    expect(find.text('Inserisci almeno un valore'), findsOneWidget);
    expect(adapter.posted, isEmpty);
  });

  testWidgets('la sola nota non basta: non è un valore rilevato (PR-13)', (tester) async {
    final adapter = await _pumpSheet(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Nota'), 'a digiuno');
    await _tapSave(tester);

    expect(find.text('Inserisci almeno un valore'), findsOneWidget);
    expect(adapter.posted, isEmpty);
  });

  testWidgets('il solo peso basta, e i campi non compilati restano vuoti (PR-12)', (tester) async {
    final adapter = await _pumpSheet(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Peso (kg)'), '72,5');
    await _tapSave(tester);

    expect(adapter.posted.single['weightKg'], 72.5);
    final circumferences = adapter.posted.single['circumferences'] as Map;
    expect(circumferences.values.every((value) => value == null), isTrue);
  });

  testWidgets('distingue la fonte delle misurazioni nell\'elenco (AN-5, PR-17)', (tester) async {
    final today = DateTime.now();
    await _pumpList(tester, [
      _measurement(id: 'm-1', date: today, weightKg: 70, role: 'NUTRITIONIST', editable: false),
      _measurement(id: 'm-2', date: today.subtract(const Duration(days: 7)), weightKg: 71),
    ]);

    // L'icona compare sulla sola rilevazione del professionista.
    expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
  });

  testWidgets('la misurazione del professionista si consulta ma non si modifica (PR-17)',
      (tester) async {
    await _pumpList(tester, [
      _measurement(
        id: 'm-1',
        date: DateTime.now(),
        weightKg: 70,
        role: 'NUTRITIONIST',
        editable: false,
      ),
    ]);

    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();

    expect(find.text('Rilevata dal tuo nutrizionista.'), findsOneWidget);
    // Nessun modulo: né campi né salvataggio.
    expect(find.widgetWithText(ElevatedButton, 'Salva'), findsNothing);
    expect(find.widgetWithText(TextField, 'Peso (kg)'), findsNothing);
  });

  testWidgets('la misurazione propria si elimina dal foglio, previa conferma (PR-16)', (tester) async {
    final adapter = await _pumpList(tester, [
      _measurement(id: 'm-1', date: DateTime.now(), weightKg: 70),
    ]);

    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();
    final delete = find.widgetWithText(TextButton, 'Elimina');
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();

    expect(find.text('Eliminare questa misurazione?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Elimina').last);
    await tester.pumpAndSettle();

    expect(adapter.deleted, ['/body-measurements/m-1']);
  });

  testWidgets('la misurazione del professionista non offre l\'eliminazione al Paziente (PR-17)',
      (tester) async {
    await _pumpList(tester, [
      _measurement(
        id: 'm-1',
        date: DateTime.now(),
        weightKg: 70,
        role: 'NUTRITIONIST',
        editable: false,
      ),
    ]);

    await tester.tap(find.byType(InkWell).last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Elimina'), findsNothing);
  });

  testWidgets('l\'elenco non presenta variazioni né confronti (AN-11, AN-12)', (tester) async {
    final today = DateTime.now();
    await _pumpList(tester, [
      _measurement(id: 'm-1', date: today, weightKg: 70),
      _measurement(id: 'm-2', date: today.subtract(const Duration(days: 7)), weightKg: 72),
    ]);

    // Ciascuna voce reca il proprio valore, una volta sola.
    expect(find.text('70 kg'), findsOneWidget);
    expect(find.text('72 kg'), findsOneWidget);
    // Nessuna differenza calcolata, nessuna freccia direzionale: la
    // variazione compete al solo riquadro di 11.3, in forma neutra.
    expect(find.textContaining('-2'), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
  });
}
