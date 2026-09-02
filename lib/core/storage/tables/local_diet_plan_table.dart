import 'package:drift/drift.dart';

/// Piano attivo con schema settimanale (PL-6: "Sempre"). Lo schema
/// settimanale è conservato come JSON in `weeklyScheduleJson`: ML-7 lo
/// annida nel piano anche sul backend (`ScheduleDay` e slot in
/// `DietPlan`), e `core/storage` non conosce la forma dei DTO di
/// dominio (PL-5) — è la feature a (de)serializzarli.
class LocalDietPlans extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get authorId => text()();
  TextColumn get authorRole => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get weeklyScheduleJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
