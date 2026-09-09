import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/features/dietplan/data/plan_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/presentation/plan_status_presentation.dart';
import 'package:healthylog/features/dietplan/presentation/slot_type_presentation.dart';
import 'package:healthylog/l10n/app_locale.dart';
import 'package:healthylog/l10n/l10n_context.dart';

/// LO-1: l'applicazione è disponibile in italiano e in inglese. La prova
/// verifica che la stessa schermata renda testi diversi al variare della
/// sola lingua, comprese le denominazioni di dominio che non sono
/// costanti dell'enumerativo ma voci di traduzione.
void main() {
  testWidgets('la stessa schermata è resa nelle due lingue (LO-1)', (tester) async {
    await _pump(tester, const Locale('it'));
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Colazione'), findsOneWidget);
    expect(find.text('Sospeso'), findsOneWidget);

    await _pump(tester, const Locale('en'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Suspended'), findsOneWidget);
  });

  testWidgets('una lingua non prevista ricade sull\'italiano (LO-2)', (tester) async {
    await _pump(tester, const Locale('de'));
    expect(find.text('Impostazioni'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
        theme: AppTheme.light,
        home: const _Sample(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _Sample extends StatelessWidget {
  const _Sample();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Text(context.l10n.settingsTitle),
            Text(slotTypeLabel(context, SlotType.breakfast)),
            Text(planStatusLabel(context, PlanStatus.suspended)),
          ],
        ),
      );
}
