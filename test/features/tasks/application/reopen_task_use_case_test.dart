import 'package:atelier_mobile_crossplatform/features/tasks/application/reopen_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  const id = TaskId('t1');
  final detail = TaskDetail(
    id: id,
    workOrderId: 'wo1',
    description: 'Reabierta',
    totalPausedSeconds: 0,
  );
  late _MockTaskRepository repository;
  late ReopenTaskUseCase useCase;

  setUpAll(() => registerFallbackValue(const TaskId('x')));

  setUp(() {
    repository = _MockTaskRepository();
    useCase = ReopenTaskUseCase(repository: repository);
    when(
      () => repository.reopen(any(), reason: any(named: 'reason')),
    ).thenAnswer((_) async => detail);
  });

  test('recorta el motivo antes de delegar', () async {
    expect(await useCase.execute(id, reason: '  Retrabajo  '), detail);
    verify(() => repository.reopen(id, reason: 'Retrabajo')).called(1);
  });

  test('un motivo vacío o en blanco se envía como null', () async {
    await useCase.execute(id, reason: '   ');
    await useCase.execute(id);
    verify(() => repository.reopen(id, reason: null)).called(2);
  });

  group('hasPendingSuspension', () {
    test('Task y TaskDetail la detectan por fecha o por motivo no vacío', () {
      const base = Task(
        id: id,
        workOrderId: 'wo1',
        vehicleId: 'v1',
        description: 'x',
        totalPausedSeconds: 0,
      );
      expect(base.hasPendingSuspension, isFalse);
      expect(
        Task(
          id: id,
          workOrderId: 'wo1',
          vehicleId: 'v1',
          description: 'x',
          totalPausedSeconds: 0,
          pendingSuspensionReason: '  ',
        ).hasPendingSuspension,
        isFalse,
      );
      expect(
        Task(
          id: id,
          workOrderId: 'wo1',
          vehicleId: 'v1',
          description: 'x',
          totalPausedSeconds: 0,
          pendingSuspensionRequestedAt: DateTime.utc(2026, 11, 6),
        ).hasPendingSuspension,
        isTrue,
      );
      expect(
        TaskDetail(
          id: id,
          workOrderId: 'wo1',
          description: 'x',
          totalPausedSeconds: 0,
          pendingSuspensionReason: 'Filtro',
        ).hasPendingSuspension,
        isTrue,
      );
    });
  });
}
