import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/care/data/care_models.dart';
import 'package:healthylog/features/dietplan/data/diet_plan.dart';
import 'package:healthylog/features/dietplan/data/meal_swap_log.dart';
import 'package:healthylog/features/dietplan/data/plan_day.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/data/weekday.dart' as plan;
import 'package:healthylog/features/notification/data/app_notification.dart';
import 'package:healthylog/features/notification/data/notification_type.dart';
import 'package:healthylog/features/statistics/data/statistics_models.dart';
import 'package:healthylog/features/workout/data/workout_models.dart' as workout;

/// CC-41, VR-10: un valore di enumerativo che questa versione del client non
/// conosce — introdotto da un server più recente — non solleva errore.
/// L'elemento che lo reca è omesso dall'elenco che lo contiene, anziché
/// ricondotto a un valore esistente che ne falserebbe il senso.
void main() {
  Map<String, dynamic> daySlot(String id, String type, String status) => {
        'slotId': id,
        'type': type,
        'label': null,
        'order': 0,
        'content': 'Contenuto',
        'note': null,
        'recipeName': null,
        'recipeText': null,
        'status': status,
        'replacementNote': null,
      };

  Map<String, dynamic> scheduleSlot(String id, String type) => {
        'slotId': id,
        'type': type,
        'label': null,
        'order': 0,
        'content': 'Contenuto',
        'note': null,
        'recipeName': null,
        'recipeText': null,
        'adherenceWeight': 1.0,
      };

  Map<String, dynamic> dietPlan({String status = 'ACTIVE', List<Map<String, dynamic>> schedule = const []}) => {
        'id': 'plan-1',
        'ownerId': 'user-1',
        'authorId': 'user-1',
        'authorRole': 'USER',
        'name': 'Piano',
        'notes': null,
        'status': status,
        'startDate': '2026-09-01',
        'endDate': null,
        'periods': <Object>[],
        'suspensions': <Object>[],
        'weeklySchedule': schedule,
        'adherence': null,
      };

  test('la giornata omette gli slot di tipo o stato sconosciuti', () {
    final day = PlanDay.fromJson({
      'date': '2026-09-14',
      'coverage': 'ACTIVE',
      'planId': 'plan-1',
      'planName': 'Piano',
      'planStartDate': '2026-09-01',
      'planEndDate': null,
      'slots': [
        daySlot('noto', 'BREAKFAST', 'TO_CONSUME'),
        daySlot('tipo-ignoto', 'BRUNCH', 'TO_CONSUME'),
        daySlot('stato-ignoto', 'LUNCH', 'HALF_EATEN'),
      ],
    });

    expect(day.slots.map((slot) => slot.slotId), ['noto']);
    expect(day.slots.single.type, SlotType.breakfast);
  });

  test('lo schema settimanale omette giorni e slot sconosciuti', () {
    final dietPlanRead = DietPlan.fromJson(dietPlan(schedule: [
      {
        'dayOfWeek': 'MONDAY',
        'slots': [scheduleSlot('noto', 'LUNCH'), scheduleSlot('ignoto', 'BRUNCH')],
      },
      {'dayOfWeek': 'FUNDAY', 'slots': <Object>[]},
    ]));

    expect(dietPlanRead.weeklySchedule.map((day) => day.dayOfWeek), [plan.Weekday.monday]);
    expect(dietPlanRead.weeklySchedule.single.slots.map((slot) => slot.slotId), ['noto']);
  });

  test('gli elenchi omettono i piani in uno stato sconosciuto', () {
    expect(DietPlan.tryFromJson(dietPlan(status: 'ARCHIVED')), isNull);
    expect(DietPlan.tryFromJson(dietPlan()), isNotNull);

    final patient = PatientDetail.fromJson({
      'userId': 'user-1',
      'firstName': 'Nome',
      'lastName': 'Cognome',
      'username': null,
      'careLinkId': 'link-1',
      'linkedAt': '2026-09-01T00:00:00Z',
      'plans': [
        {'id': 'noto', 'name': 'A', 'status': 'ACTIVE', 'startDate': '2026-09-01', 'endDate': null},
        {'id': 'ignoto', 'name': 'B', 'status': 'ARCHIVED', 'startDate': '2026-09-01', 'endDate': null},
      ],
      'lastActivityAt': null,
    });
    expect(patient.plans.map((summary) => summary.id), ['noto']);
  });

  test('le richieste di collegamento in uno stato sconosciuto sono omesse', () {
    Map<String, dynamic> request(String status) => {
          'id': 'request-1',
          'nutritionistId': 'nutri-1',
          'nutritionistFirstName': null,
          'nutritionistLastName': null,
          'targetUserId': 'user-1',
          'targetFirstName': null,
          'targetLastName': null,
          'message': null,
          'status': status,
          'expiresAt': null,
          'createdAt': '2026-09-01T00:00:00Z',
          'resolvedAt': null,
        };

    expect(CareLinkRequest.tryFromJson(request('ESCALATED')), isNull);
    expect(CareLinkRequest.tryFromJson(request('PENDING'))?.status, CareLinkRequestStatus.pending);
  });

  test('lo storico omette le inversioni che coinvolgono tipi sconosciuti', () {
    Map<String, dynamic> log(String firstType) => {
          'id': 'swap-1',
          'performedBy': 'user-1',
          'performedAt': '2026-09-14T10:00:00Z',
          'first': {'date': '2026-09-14', 'slotId': 'a', 'type': firstType},
          'second': {'date': '2026-09-15', 'slotId': 'b', 'type': 'LUNCH'},
        };

    expect(MealSwapLog.tryFromJson(log('BRUNCH')), isNull);
    expect(MealSwapLog.tryFromJson(log('DINNER')), isNotNull);
  });

  test('le statistiche omettono grandezze, tipi e giorni sconosciuti invece di fallire', () {
    final measures = MeasurementStatistics.fromJson({
      'period': 'MONTH',
      'from': '2026-09-01',
      'to': '2026-09-30',
      'planId': null,
      'planName': null,
      'targetWeightKg': null,
      'series': [
        {'measure': 'WEIGHT', 'points': <Object>[], 'change': null},
        {'measure': 'NECK', 'points': <Object>[], 'change': null},
      ],
    });
    expect(measures.series.map((series) => series.measure), [BodyMeasure.weight]);

    final adherence = AdherenceStatistics.fromJson({
      'period': 'MONTH',
      'from': '2026-09-01',
      'to': '2026-09-30',
      'planId': null,
      'planName': null,
      'value': null,
      'suspendedDays': 0,
      'uncoveredDays': 0,
      'bySlotType': [
        {'key': 'LUNCH', 'value': 50},
        {'key': 'BRUNCH', 'value': 10},
      ],
      'byWeekday': [
        {'key': 'MONDAY', 'value': 80},
        {'key': 'FUNDAY', 'value': 20},
      ],
      'weekly': <Object>[],
      'periods': <Object>[],
    });
    expect(adherence.bySlotType.map((bucket) => bucket.slotType), [SlotType.lunch]);
    expect(adherence.byWeekday.map((bucket) => bucket.weekday), [workout.Weekday.monday]);
  });

  test('l\'allenamento pianificato omette i giorni sconosciuti', () {
    final planned = workout.PlannedWorkout.fromJson({
      'id': 'planned-1',
      'recurrence': 'WEEKLY',
      'daysOfWeek': ['MONDAY', 'FUNDAY'],
      'date': null,
      'activityType': 'Corsa',
      'activeFrom': '2026-09-01',
      'activeTo': null,
    });

    expect(planned.daysOfWeek, [workout.Weekday.monday]);
  });

  test('la notifica di tipo sconosciuto resta visibile come tale', () {
    final notification = AppNotification.fromJson({
      'id': 'notification-1',
      'type': 'SOMETHING_NEW',
      'payload': <String, Object>{},
      'occurredAt': '2026-09-14T10:00:00Z',
    });

    expect(notification.type, NotificationType.unknown);
  });
}
