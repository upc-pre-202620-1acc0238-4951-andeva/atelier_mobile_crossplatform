import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTaskRepository implements TaskRepository {
  final List<String> calls = [];
  final List<Task> myTasks = [];
  TaskDetail? taskDetail;
  final List<PendingEvidence> pendingEvidences = [];
  final List<PartOption> parts = [];

  @override
  Stream<List<Task>> observeMyTasks() => Stream.value(myTasks);

  @override
  Stream<Task?> observeTask(TaskId id) => Stream.value(
        myTasks.where((t) => t.id == id).firstOrNull,
      );

  @override
  Future<void> refreshMyTasks() async {
    calls.add('refreshMyTasks');
  }

  @override
  Future<TaskDetail> getDetail(TaskId id) async {
    calls.add('getDetail:${id.value}');
    return taskDetail ??
        TaskDetail(
          id: id,
          workOrderId: 'wo1',
          description: 'Fake',
          totalPausedSeconds: 0,
        );
  }

  @override
  Future<TaskDetail> start(TaskId id) async {
    calls.add('start:${id.value}');
    return taskDetail!;
  }

  @override
  Future<TaskDetail> pause(TaskId id, PauseReason reason) async {
    calls.add('pause:${id.value}:${reason.value}');
    return taskDetail!;
  }

  @override
  Future<TaskDetail> requestSuspension(
    TaskId id,
    String missingItemDescription, {
    String? inventoryItemId,
  }) async {
    calls.add(
      'requestSuspension:${id.value}:$missingItemDescription:$inventoryItemId',
    );
    return taskDetail!;
  }

  @override
  Future<TaskDetail> approveSuspension(TaskId id) async {
    calls.add('approveSuspension:${id.value}');
    return taskDetail!;
  }

  @override
  Future<TaskDetail> rejectSuspension(TaskId id) async {
    calls.add('rejectSuspension:${id.value}');
    return taskDetail!;
  }

  @override
  Future<TaskDetail> resume(TaskId id) async {
    calls.add('resume:${id.value}');
    return taskDetail!;
  }

  @override
  Future<TaskDetail> complete(
    TaskId id,
    double actualLaborHours, {
    String? notes,
  }) async {
    calls.add('complete:${id.value}:$actualLaborHours:$notes');
    return taskDetail!;
  }

  @override
  Future<void> attachEvidence(
    TaskId id,
    String workOrderId,
    File photo,
    String description,
  ) async {
    calls.add('attachEvidence:${id.value}:$workOrderId:$description');
  }

  @override
  Stream<List<PendingEvidence>> observePendingEvidence(TaskId id) =>
      Stream.value(pendingEvidences);

  @override
  Future<List<PartOption>> searchParts(String query) async {
    calls.add('searchParts:$query');
    return parts;
  }

  @override
  Future<TaskProduct> addPart(
    TaskId id,
    String productId,
    double quantity,
  ) async {
    calls.add('addPart:${id.value}:$productId:$quantity');
    return TaskProduct(
      id: 'tp1',
      productId: productId,
      quantity: quantity,
    );
  }

  @override
  Future<TaskDetail> updatePartQuantity(
    TaskId id,
    String productId,
    double quantity,
  ) async {
    calls.add('updatePartQuantity:${id.value}:$productId:$quantity');
    return taskDetail!;
  }

  @override
  Future<void> removePart(TaskId id, String productId) async {
    calls.add('removePart:${id.value}:$productId');
  }
}

void main() {
  late FakeTaskRepository repository;

  setUp(() {
    repository = FakeTaskRepository();
    repository.taskDetail = const TaskDetail(
      id: TaskId('t1'),
      workOrderId: 'wo1',
      description: 'Test detail',
      totalPausedSeconds: 0,
      status: TaskStatus.inProgress,
    );
  });

  test('ObserveMyTasksUseCase delega en el repositorio', () async {
    final useCase = ObserveMyTasksUseCase(repository: repository);
    expect(await useCase.execute().first, isEmpty);
  });

  test('RefreshMyTasksUseCase llama a refreshMyTasks', () async {
    final useCase = RefreshMyTasksUseCase(repository: repository);
    await useCase.execute();
    expect(repository.calls, contains('refreshMyTasks'));
  });

  test('ObserveTaskUseCase y GetTaskDetailUseCase', () async {
    final observe = ObserveTaskUseCase(repository: repository);
    expect(await observe.execute(const TaskId('t1')).first, isNull);

    final detail = GetTaskDetailUseCase(repository: repository);
    final res = await detail.execute(const TaskId('t1'));
    expect(res.id.value, 't1');
    expect(repository.calls, contains('getDetail:t1'));
  });

  test('StartTaskUseCase y PauseTaskUseCase', () async {
    final start = StartTaskUseCase(repository: repository);
    await start.execute(const TaskId('t1'));
    expect(repository.calls, contains('start:t1'));

    final pause = PauseTaskUseCase(repository: repository);
    await pause.execute(const TaskId('t1'), PauseReason.breakTime);
    expect(repository.calls, contains('pause:t1:BREAK'));
  });

  test('Suspension use cases (request, approve, reject, resume)', () async {
    final request = RequestSuspensionUseCase(repository: repository);
    expect(
      () => request.execute(const TaskId('t1'), ''),
      throwsA(isA<InvalidTaskInputException>()),
    );
    await request.execute(
      const TaskId('t1'),
      'Falta pastilla',
      inventoryItemId: 'inv1',
    );
    expect(
      repository.calls,
      contains('requestSuspension:t1:Falta pastilla:inv1'),
    );

    final approve = ApproveSuspensionUseCase(repository: repository);
    await approve.execute(const TaskId('t1'));
    expect(repository.calls, contains('approveSuspension:t1'));

    final reject = RejectSuspensionUseCase(repository: repository);
    await reject.execute(const TaskId('t1'));
    expect(repository.calls, contains('rejectSuspension:t1'));

    final resume = ResumeSuspendedTaskUseCase(repository: repository);
    await resume.execute(const TaskId('t1'));
    expect(repository.calls, contains('resume:t1'));
  });

  test('SuggestLaborHoursUseCase y CompleteTaskUseCase', () async {
    final suggest = SuggestLaborHoursUseCase(
      now: () => DateTime.utc(2026, 11, 6, 10, 0, 0),
    );
    final hours = suggest.execute(
      Task(
        id: const TaskId('t1'),
        workOrderId: 'wo1',
        vehicleId: 'v1',
        description: 'Faena',
        startedAt: DateTime.utc(2026, 11, 6, 8, 0, 0),
        totalPausedSeconds: 0,
      ),
    );
    expect(hours, 2.0);

    final complete = CompleteTaskUseCase(repository: repository);
    expect(
      () => complete.execute(const TaskId('t1'), -1.0),
      throwsA(isA<InvalidTaskInputException>()),
    );
    expect(
      () => complete.execute(const TaskId('t1'), 2.0, notes: 'a' * 1001),
      throwsA(isA<InvalidTaskInputException>()),
    );

    await complete.execute(const TaskId('t1'), 2.5, notes: 'Todo OK');
    expect(repository.calls, contains('complete:t1:2.5:Todo OK'));
  });

  test('AttachTaskEvidenceUseCase y ObservePendingEvidenceUseCase', () async {
    final attach = AttachTaskEvidenceUseCase(repository: repository);
    expect(
      () => attach.execute(
        const TaskId('t1'),
        'wo1',
        File('dummy.jpg'),
        EvidenceKind.disassembly,
        note: 'a' * 501,
      ),
      throwsA(isA<InvalidTaskInputException>()),
    );

    await attach.execute(
      const TaskId('t1'),
      'wo1',
      File('dummy.jpg'),
      EvidenceKind.disassembly,
      note: 'Faro roto',
    );
    expect(
      repository.calls,
      contains('attachEvidence:t1:wo1:Desmontaje: Faro roto'),
    );

    final observe = ObservePendingEvidenceUseCase(repository: repository);
    expect(await observe.execute(const TaskId('t1')).first, isEmpty);
  });

  test('Parts use cases (search, add, update, remove)', () async {
    final search = SearchPartsUseCase(repository: repository);
    await search.execute('pastillas');
    expect(repository.calls, contains('searchParts:pastillas'));

    final add = AddPartToTaskUseCase(repository: repository);
    expect(
      () => add.execute(const TaskId('t1'), 'p1', 0.0),
      throwsA(isA<InvalidTaskInputException>()),
    );
    await add.execute(const TaskId('t1'), 'p1', 2.0);
    expect(repository.calls, contains('addPart:t1:p1:2.0'));

    final update = UpdateTaskPartQuantityUseCase(repository: repository);
    expect(
      () => update.execute(const TaskId('t1'), 'p1', -1.0),
      throwsA(isA<InvalidTaskInputException>()),
    );
    await update.execute(const TaskId('t1'), 'p1', 3.0);
    expect(repository.calls, contains('updatePartQuantity:t1:p1:3.0'));

    final remove = RemovePartFromTaskUseCase(repository: repository);
    await remove.execute(const TaskId('t1'), 'p1');
    expect(repository.calls, contains('removePart:t1:p1'));
  });
}
