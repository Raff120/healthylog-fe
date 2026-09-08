import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/care/data/care_models.dart';
import 'package:healthylog/features/care/domain/plan_competence.dart';
import 'package:healthylog/features/dietplan/data/diet_plan.dart';
import 'package:healthylog/features/dietplan/data/plan_status.dart';
import 'package:healthylog/features/identity/data/account_role.dart';

/// UT-8, PZ-4, PZ-9, CP-19 (F22): la stessa regola di competenza del
/// backend, anticipata in interfaccia.
DietPlan _plan({required String authorId, AccountRole authorRole = AccountRole.user}) => DietPlan(
      id: 'plan-1',
      ownerId: 'user-1',
      authorId: authorId,
      authorRole: authorRole,
      name: 'Dieta',
      status: PlanStatus.active,
      startDate: DateTime(2026, 9, 1),
      endDate: null,
      weeklySchedule: const [],
    );

CareLink _link({String nutritionistId = 'nutri-1', CareLinkStatus status = CareLinkStatus.active}) => CareLink(
      id: 'link-1',
      nutritionistId: nutritionistId,
      nutritionistFirstName: 'Anna',
      nutritionistLastName: 'Verdi',
      patientId: 'user-1',
      patientFirstName: 'Mario',
      patientLastName: 'Rossi',
      status: status,
      createdAt: DateTime(2026, 9, 1),
      revokedAt: null,
    );

void main() {
  test('il piano del Nutrizionista collegato è bloccato per il Paziente (UT-8)', () {
    expect(isPlanLockedForPatient(_plan(authorId: 'nutri-1', authorRole: AccountRole.nutritionist), _link()), isTrue);
  });

  test('il piano redatto dall\'Utente stesso non è mai bloccato (PZ-9)', () {
    expect(isPlanLockedForPatient(_plan(authorId: 'user-1'), _link()), isFalse);
  });

  test('senza collegamento vigente il blocco cade (CP-19, PZ-8)', () {
    final plan = _plan(authorId: 'nutri-1', authorRole: AccountRole.nutritionist);
    expect(isPlanLockedForPatient(plan, null), isFalse);
    expect(isPlanLockedForPatient(plan, _link(status: CareLinkStatus.revoked)), isFalse);
  });

  test('il piano di un altro professionista non è bloccato dal collegamento attuale', () {
    expect(
      isPlanLockedForPatient(_plan(authorId: 'nutri-2', authorRole: AccountRole.nutritionist), _link()),
      isFalse,
    );
  });

  test('il Paziente non crea piani propri, l\'Utente autonomo sì (UT-8, UT-6)', () {
    expect(canCreateOwnPlan(_link()), isFalse);
    expect(canCreateOwnPlan(null), isTrue);
    expect(canCreateOwnPlan(_link(status: CareLinkStatus.revoked)), isTrue);
  });
}
