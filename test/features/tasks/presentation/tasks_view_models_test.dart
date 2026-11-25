import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reopen_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockObserveMyTasks extends Mock implements ObserveMyTasksUseCase {}

class _MockRefreshMyTasks extends Mock implements RefreshMyTasksUseCase {}

class _MockObserveTask extends Mock implements ObserveTaskUseCase {}

class _MockGetDetail extends Mock implements GetTaskDetailUseCase {}

class _MockStart extends Mock implements StartTaskUseCase {}

class _MockPause extends Mock implements PauseTaskUseCase {}

class _MockReopen extends Mock implements ReopenTaskUseCase {}

class _MockSearch extends Mock implements SearchPartsUseCase {}

class _MockAddPart extends Mock implements AddPartToTaskUseCase {}

class _MockUpdatePart extends Mock implements UpdateTaskPartQuantityUseCase {}

class _MockRemovePart extends Mock implements RemovePartFromTaskUseCase {}

class _MockPausedElapsed extends Mock implements PausedElapsedStore {}

class _MockComplete extends Mock implements CompleteTaskUseCase {}

class _MockAttach extends Mock implements AttachTaskEvidenceUseCase {}

class _MockObserveEvidence extends Mock implements ObservePendingEvidenceUseCase {}

class _MockRequestSuspension extends Mock implements RequestSuspensionUseCase {}

class _MockApproveSuspension extends Mock implements ApproveSuspensionUseCase {}

class _MockRejectSuspension extends Mock implements RejectSuspensionUseCase {}

class _MockResumeSuspended extends Mock implements ResumeSuspendedTaskUseCase {}

Session _session(Set<String> permissions) {
  return Session(
    userId: 'u1',
    email: 'a@b.pe',
    fullName: 'Andrés',
    tenantId: 't1',
    tenantName: 'Taller Suárez',
    membershipId: 'm1',
    permissions: permissions,
    plan: null,
    branchId: 'b1',
    shiftId: 's1',
  );
}

Task _task({TaskStatus status = TaskStatus.assigned, HoldReason? hold, DateTime? startedAt, int paused = 0}) {
  return Task(
    id: TaskId('t1'),
    workOrderId: 'wo1',
    workOrderNumber: 1042,
    vehicleId: 'v1',
    plate: 'BKL482',
    bayName: 'B-2',
    status: status,
    holdReason: hold,
    description: 'Cambio de pastillas',
    estimatedHours: Decimal.parse('1.5'),
    startedAt: startedAt,
    totalPausedSeconds: paused,
  );
}

TaskDetail _detail({
  TaskStatus status = TaskStatus.inProgress,
  HoldReason? hold,
  DateTime? startedAt,
  int paused = 0,
  List<TaskProduct> products = const [],
}) {
  return TaskDetail(
    id: TaskId('t1'),
    workOrderId: 'wo1',
    serviceName: 'Cambio de pastillas',
    status: status,
    description: 'Cambio de pastillas',
    holdReason: hold,
    totalPausedSeconds: paused,
    startedAt: startedAt,
    products: products,
  );
}

ConnectivityObserver _online() => ConnectivityObserver(
  changes: const Stream.empty(),
  current: () async => [ConnectivityResult.wifi],
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));

  setUpAll(() {
    registerFallbackValue(TaskId('x'));
    registerFallbackValue(PauseReason.breakTime);
    registerFallbackValue(Decimal.one);
    registerFallbackValue(EvidenceKind.disassembly);
    registerFallbackValue(File('x'));
  });

  group('MyTasksViewModel', () {
    late _MockObserveSession observeSession;
    late _MockObserveMyTasks observeTasks;
    late _MockRefreshMyTasks refresh;

    MyTasksViewModel build({Session? session, ConnectivityObserver? connectivity}) {
      when(() => observeSession.execute()).thenAnswer((_) => Stream.value(session));
      when(() => observeTasks.execute()).thenAnswer((_) => Stream.value([_task()]));
      return MyTasksViewModel(
        observeSession: observeSession,
        observeMyTasks: observeTasks,
        refreshMyTasks: refresh,
        connectivity: connectivity ?? _online(),
      );
    }

    setUp(() {
      observeSession = _MockObserveSession();
      observeTasks = _MockObserveMyTasks();
      refresh = _MockRefreshMyTasks();
    });

    test('carga la caché, refresca al abrir y deriva permisos y alcance de la sesión', () async {
      when(() => refresh.execute()).thenAnswer((_) async {});
      final vm = build(session: _session({'operations:tasks:read', 'operations:work_orders:update'}));
      await _settle();

      expect(vm.state.isLoaded, isTrue);
      expect(vm.state.tasks, hasLength(1));
      expect(vm.state.canRead, isTrue);
      expect(vm.state.isWorkshopScope, isTrue, reason: 'sin track_time y con work_orders:update es supervisión');
      expect(vm.state.tenantName, 'Taller Suárez');
      expect(vm.state.isRefreshing, isFalse);
      expect(vm.state.showingCache, isFalse);
      vm.dispose();
    });

    test('con track_time no es alcance de taller y sin tasks:read no puede leer', () async {
      when(() => refresh.execute()).thenAnswer((_) async {});
      final vm = build(session: _session({'operations:tasks:track_time', 'operations:work_orders:update'}));
      await _settle();
      expect(vm.state.isWorkshopScope, isFalse);
      expect(vm.state.canRead, isFalse);
      vm.dispose();
    });

    test('si la recarga falla sigue con la caché y muestra el message del backend', () async {
      when(() => refresh.execute()).thenThrow(
        const ApiException(httpStatus: 500, code: 'X', message: 'Servidor caído'),
      );
      final vm = build(session: _session({'operations:tasks:read'}));
      await _settle();

      expect(vm.state.showingCache, isTrue);
      expect(vm.state.error?.asString(strings), 'Servidor caído');
      expect(vm.state.tasks, hasLength(1));
      vm.dispose();
    });

    test('al volver la conexión recarga solo y quita el aviso', () async {
      final changes = StreamController<List<ConnectivityResult>>.broadcast();
      final connectivity = ConnectivityObserver(
        changes: changes.stream,
        current: () async => [ConnectivityResult.none],
      );
      await connectivity.start();
      var calls = 0;
      when(() => refresh.execute()).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const NetworkException();
      });
      final vm = build(session: _session({'operations:tasks:read'}), connectivity: connectivity);
      await _settle();
      expect(vm.state.showingCache, isTrue);
      expect(vm.state.isOnline, isFalse);

      changes.add([ConnectivityResult.wifi]);
      await _settle();
      await _settle();

      expect(calls, 2);
      expect(vm.state.isOnline, isTrue);
      expect(vm.state.showingCache, isFalse);
      expect(vm.state.error, isNull);
      vm.dispose();
      await changes.close();
    });

    test('los filtros cuentan y recortan la lista', () async {
      when(() => refresh.execute()).thenAnswer((_) async {});
      when(() => observeSession.execute()).thenAnswer((_) => Stream.value(null));
      when(() => observeTasks.execute()).thenAnswer(
        (_) => Stream.value([
          _task(status: TaskStatus.inProgress),
          _task(status: TaskStatus.onHold, hold: HoldReason.breakTime),
          _task(status: TaskStatus.onHold, hold: HoldReason.waitingParts),
          _task(),
        ]),
      );
      final vm = MyTasksViewModel(
        observeSession: observeSession,
        observeMyTasks: observeTasks,
        refreshMyTasks: refresh,
        connectivity: _online(),
      );
      await _settle();

      expect(vm.state.pendingCount, 1);
      expect(vm.state.inProgressCount, 1);
      expect(vm.state.pausedCount, 2);
      vm.onFilterChange(TaskFilter.paused);
      expect(vm.state.visibleTasks, hasLength(1), reason: 'solo las pausas del mecánico');
      vm.onFilterChange(TaskFilter.suspended);
      expect(vm.state.visibleTasks.single.holdReason, HoldReason.waitingParts);
      vm.dispose();
    });
  });

  group('TaskDetailViewModel', () {
    late _MockObserveSession observeSession;
    late _MockObserveTask observeTask;
    late _MockGetDetail getDetail;
    late _MockStart start;
    late _MockPause pause;
    late _MockReopen reopen;
    late _MockSearch search;
    late _MockAddPart addPart;
    late _MockUpdatePart updatePart;
    late _MockRemovePart removePart;
    late _MockPausedElapsed pausedElapsed;
    late _MockComplete completeTask;
    late _MockAttach attachEvidence;
    late _MockObserveEvidence observeEvidence;
    late _MockRequestSuspension requestSuspension;
    late _MockApproveSuspension approveSuspension;
    late _MockRejectSuspension rejectSuspension;
    late _MockResumeSuspended resumeSuspended;
    late StreamController<List<PendingEvidence>> evidenceStream;
    final startedAt = DateTime.utc(2026, 11, 24, 10);
    final now = startedAt.add(const Duration(seconds: 3600));

    TaskDetailViewModel build({
      required Set<String> permissions,
      Task? task,
      Future<TaskDetail> Function()? loadDetail,
      ConnectivityObserver? connectivity,
    }) {
      when(() => observeSession.execute()).thenAnswer((_) => Stream.value(_session(permissions)));
      when(() => observeTask.execute(any())).thenAnswer((_) => Stream.value(task));
      when(() => getDetail.execute(any())).thenAnswer((_) => (loadDetail ?? () async => _detail())());
      when(() => pausedElapsed.get(any())).thenAnswer((_) async => null);
      when(() => pausedElapsed.clear(any())).thenAnswer((_) async {});
      when(() => pausedElapsed.save(any(), any())).thenAnswer((_) async {});
      when(() => observeEvidence.execute(any())).thenAnswer((_) => evidenceStream.stream);
      return TaskDetailViewModel(
        taskId: TaskId('t1'),
        workOrderId: 'wo1',
        observeSession: observeSession,
        observeTask: observeTask,
        getDetail: getDetail,
        startTask: start,
        pauseTask: pause,
        reopenTask: reopen,
        searchParts: search,
        addPart: addPart,
        updatePartQuantity: updatePart,
        removePart: removePart,
        suggestLaborHours: SuggestLaborHoursUseCase(now: () => now),
        completeTask: completeTask,
        attachTaskEvidence: attachEvidence,
        observePendingEvidence: observeEvidence,
        requestSuspension: requestSuspension,
        approveSuspension: approveSuspension,
        rejectSuspension: rejectSuspension,
        resumeSuspendedTask: resumeSuspended,
        pausedElapsed: pausedElapsed,
        connectivity: connectivity ?? _online(),
        now: () => now,
      );
    }

    setUp(() {
      observeSession = _MockObserveSession();
      observeTask = _MockObserveTask();
      getDetail = _MockGetDetail();
      start = _MockStart();
      pause = _MockPause();
      reopen = _MockReopen();
      search = _MockSearch();
      addPart = _MockAddPart();
      updatePart = _MockUpdatePart();
      removePart = _MockRemovePart();
      pausedElapsed = _MockPausedElapsed();
      completeTask = _MockComplete();
      attachEvidence = _MockAttach();
      observeEvidence = _MockObserveEvidence();
      requestSuspension = _MockRequestSuspension();
      approveSuspension = _MockApproveSuspension();
      rejectSuspension = _MockRejectSuspension();
      resumeSuspended = _MockResumeSuspended();
      evidenceStream = StreamController<List<PendingEvidence>>.broadcast();
    });

    group('US30 cierre técnico', () {
      const permissions = {'operations:tasks:complete'};

      test('precarga las horas del cronómetro y cierra con Decimal', () async {
        when(() => completeTask.execute(any(), any(), notes: any(named: 'notes')))
            .thenAnswer((_) async => _detail(status: TaskStatus.completed));
        final vm = build(
          permissions: permissions,
          loadDetail: () async => _detail(startedAt: startedAt, paused: 300),
        );
        await _settle();

        vm.onCompleteClick();
        // (3600 − 300) s = 0.92 h.
        expect(vm.state.completeForm!.hours, '0.92');
        vm.onCompleteHoursChange('1,5');
        await vm.onCompleteConfirm();

        verify(() => completeTask.execute(any(), Decimal.parse('1.5'), notes: '')).called(1);
        expect(vm.state.completeForm, isNull);
        expect(vm.state.status, TaskStatus.completed);
        expect(vm.state.notice?.asString(strings), strings.taskCompletedNotice);
        vm.dispose();
      });

      test('en pausa propia sugiere el tiempo guardado al pausar, o nada si se desconoce', () async {
        final paused = _detail(status: TaskStatus.onHold, hold: HoldReason.breakTime, startedAt: startedAt);
        final unknown = build(permissions: permissions, loadDetail: () async => paused);
        await _settle();
        unknown.onCompleteClick();
        expect(unknown.state.completeForm!.hours, isEmpty);
        unknown.dispose();

        final known = build(permissions: permissions, loadDetail: () async => paused);
        when(() => pausedElapsed.get(any())).thenAnswer((_) async => 1800);
        await _settle();
        known.onCompleteClick();
        expect(known.state.completeForm!.hours, '0.5');
        known.dispose();
      });

      test('no ofrece cerrar sin permiso, sin iniciar ni suspendida por repuesto', () async {
        for (final (granted, detail) in [
          (<String>{}, _detail()),
          (permissions, _detail(status: TaskStatus.assigned)),
          (permissions, _detail(status: TaskStatus.onHold, hold: HoldReason.waitingParts)),
        ]) {
          final vm = build(permissions: granted, loadDetail: () async => detail);
          await _settle();
          vm.onCompleteClick();
          expect(vm.state.completeForm, isNull);
          vm.dispose();
        }
      });

      test('horas ilegibles marcan el campo sin llamar al backend', () async {
        final vm = build(permissions: permissions);
        await _settle();
        vm.onCompleteClick();
        vm.onCompleteHoursChange('dos');
        await vm.onCompleteConfirm();

        verifyNever(() => completeTask.execute(any(), any(), notes: any(named: 'notes')));
        expect(vm.state.invalidField, 'actualLaborHours');
        vm.dispose();
      });
    });

    group('US29 suspensión', () {
      test('el técnico solicita con motivo y queda pendiente', () async {
        when(() => requestSuspension.execute(any(), any(), inventoryItemId: any(named: 'inventoryItemId')))
            .thenAnswer(
          (_) async => TaskDetail(
            id: TaskId('t1'),
            workOrderId: 'wo1',
            status: TaskStatus.inProgress,
            description: 'Cambio de pastillas',
            totalPausedSeconds: 0,
            pendingSuspensionReason: 'Retén roto',
          ),
        );
        final vm = build(permissions: {'operations:tasks:hold_request'});
        await _settle();

        vm.onRequestSuspensionClick();
        vm.onSuspensionDescriptionChange('Retén roto');
        await vm.onRequestSuspensionConfirm();

        verify(() => requestSuspension.execute(any(), 'Retén roto', inventoryItemId: null)).called(1);
        expect(vm.state.suspensionForm, isNull);
        expect(vm.state.hasPendingSuspension, isTrue);
        expect(vm.state.showRequestSuspension, isFalse);
        expect(vm.state.showReviewSuspension, isFalse, reason: 'quien solicita no valida');
        vm.dispose();
      });

      test('el supervisor aprueba, rechaza y reanuda según el estado', () async {
        final pending = TaskDetail(
          id: TaskId('t1'),
          workOrderId: 'wo1',
          status: TaskStatus.inProgress,
          description: 'Cambio de pastillas',
          totalPausedSeconds: 0,
          pendingSuspensionReason: 'Retén roto',
        );
        final suspended = _detail(status: TaskStatus.onHold, hold: HoldReason.waitingParts);
        when(() => approveSuspension.execute(any())).thenAnswer((_) async => suspended);
        when(() => rejectSuspension.execute(any())).thenAnswer((_) async => _detail());
        when(() => resumeSuspended.execute(any())).thenAnswer((_) async => _detail());
        const permissions = {'operations:tasks:hold_validate'};

        final rejecting = build(permissions: permissions, loadDetail: () async => pending);
        await _settle();
        rejecting.onReviewSuspensionClick();
        await rejecting.onRejectSuspension();
        expect(rejecting.state.status, TaskStatus.inProgress);
        expect(rejecting.state.notice?.asString(strings), strings.ordersSuspensionRejectedNotice);
        rejecting.dispose();

        final vm = build(permissions: permissions, loadDetail: () async => pending);
        await _settle();
        vm.onReviewSuspensionClick();
        await vm.onApproveSuspension();
        expect(vm.state.isSuspended, isTrue);
        expect(vm.state.reviewForm, isNull);

        vm.onResumeSuspendedClick();
        await vm.onResumeSuspendedConfirm();
        verify(() => resumeSuspended.execute(any())).called(1);
        expect(vm.state.status, TaskStatus.inProgress);
        expect(vm.state.notice?.asString(strings), strings.ordersTaskResumedNotice);
        vm.dispose();
      });

      test('un error del backend deja la hoja abierta con su message', () async {
        when(() => requestSuspension.execute(any(), any(), inventoryItemId: any(named: 'inventoryItemId')))
            .thenThrow(const ApiException(httpStatus: 422, code: 'X', message: 'Ya hay una solicitud'));
        final vm = build(permissions: {'operations:tasks:hold_request'});
        await _settle();
        vm.onRequestSuspensionClick();
        vm.onSuspensionDescriptionChange('Retén');
        await vm.onRequestSuspensionConfirm();

        expect(vm.state.suspensionForm, isNotNull);
        expect(vm.state.error?.asString(strings), 'Ya hay una solicitud');
        vm.dispose();
      });
    });

    group('US28 evidencia', () {
      const permissions = {'operations:tasks:upload_photos'};

      PendingEvidence queued(String id) => PendingEvidence(
        operationId: id,
        imageUrl: 'https://x/$id.jpg',
        status: 'PENDING',
        capturedAt: now,
      );

      test('se adjunta sin red y deja el aviso de cola', () async {
        when(() => attachEvidence.execute(any(), any(), any(), any(), note: any(named: 'note')))
            .thenAnswer((_) async {});
        final offline = ConnectivityObserver(
          changes: const Stream.empty(),
          current: () async => [ConnectivityResult.none],
        );
        await offline.start();
        final vm = build(
          permissions: permissions,
          task: _task(status: TaskStatus.inProgress),
          loadDetail: () async => throw const NetworkException(),
          connectivity: offline,
        );
        await _settle();

        vm.onAddEvidenceClick();
        vm.onEvidenceKindChange(EvidenceKind.assembly);
        vm.onEvidenceNoteChange('Pastilla nueva');
        await vm.onEvidenceCaptured(File('foto.jpg'));

        expect(vm.state.isOnline, isFalse);
        verify(
          () => attachEvidence.execute(any(), 'wo1', any(), EvidenceKind.assembly, note: 'Pastilla nueva'),
        ).called(1);
        expect(vm.state.evidenceForm, isNull);
        expect(vm.state.notice?.asString(strings), strings.tasksSeg2EvidenceQueued);
        vm.dispose();
      });

      test('cuando una foto sale de la cola recarga el detalle', () async {
        final vm = build(permissions: permissions);
        await _settle();
        clearInteractions(getDetail);

        evidenceStream.add([queued('op1')]);
        await _settle();
        verifyNever(() => getDetail.execute(any()));
        expect(vm.state.pendingEvidence, hasLength(1));

        evidenceStream.add([]);
        await _settle();
        verify(() => getDetail.execute(any())).called(1);
        vm.dispose();
      });

      test('sin permiso no abre la captura', () async {
        final vm = build(permissions: {});
        await _settle();
        vm.onAddEvidenceClick();
        expect(vm.state.evidenceForm, isNull);
        vm.dispose();
      });
    });

    test('carga el detalle y deriva permisos de la sesión', () async {
      final vm = build(
        permissions: {'operations:tasks:track_time', 'operations:proposals:create', 'iot:devices:read'},
        task: _task(),
      );
      await _settle();

      expect(vm.state.isLoading, isFalse);
      expect(vm.state.detail, isNotNull);
      expect(vm.state.canTrackTime, isTrue);
      expect(vm.state.canReportFinding, isTrue);
      expect(vm.state.canOpenObd, isTrue);
      expect(vm.state.canChargeParts, isFalse);
      vm.dispose();
    });

    test('un error al cargar muestra el message del backend y no hay detalle', () async {
      final vm = build(
        permissions: {},
        loadDetail: () async => throw const ApiException(httpStatus: 404, code: 'N', message: 'No existe'),
      );
      await _settle();

      expect(vm.state.detail, isNull);
      expect(vm.state.error?.asString(strings), 'No existe');
      vm.dispose();
    });

    test('iniciar exige permiso y pasa la tarea a en curso con aviso', () async {
      when(() => start.execute(any())).thenAnswer((_) async => _detail());
      final vm = build(
        permissions: {'operations:tasks:track_time'},
        task: _task(),
        loadDetail: () async => _detail(status: TaskStatus.assigned),
      );
      await _settle();
      expect(vm.state.canStart, isTrue);

      await vm.onStart();

      verify(() => start.execute(any())).called(1);
      expect(vm.state.status, TaskStatus.inProgress);
      expect(vm.state.notice?.asString(strings), strings.taskStarted);
      expect(vm.state.isBusy, isFalse);
      vm.dispose();
    });

    test('sin track_time no inicia', () async {
      final vm = build(permissions: {}, loadDetail: () async => _detail(status: TaskStatus.assigned));
      await _settle();
      await vm.onStart();
      verifyNever(() => start.execute(any()));
      vm.dispose();
    });

    test('pausar guarda el tiempo efectivo calculado antes de pausar', () async {
      when(() => pause.execute(any(), any())).thenAnswer(
        (_) async => _detail(status: TaskStatus.onHold, hold: HoldReason.breakTime, startedAt: startedAt, paused: 300),
      );
      final vm = build(
        permissions: {'operations:tasks:track_time'},
        loadDetail: () async => _detail(startedAt: startedAt, paused: 300),
      );
      await _settle();

      vm.onPauseClick();
      expect(vm.state.pauseForm, isNotNull);
      await vm.onPause(PauseReason.breakTime);

      verify(() => pause.execute(any(), PauseReason.breakTime)).called(1);
      // 3600 s desde el inicio − 300 s ya pausados.
      verify(() => pausedElapsed.save(any(), 3300)).called(1);
      expect(vm.state.pauseForm, isNull);
      expect(vm.state.pausedElapsedSeconds, 3300);
      expect(vm.state.notice?.asString(strings), strings.taskPaused);
      vm.dispose();
    });

    test('reanudar descarta el tiempo guardado', () async {
      when(() => start.execute(any())).thenAnswer((_) async => _detail(startedAt: startedAt));
      when(() => pausedElapsed.get(any())).thenAnswer((_) async => 3300);
      final vm = build(
        permissions: {'operations:tasks:track_time'},
        loadDetail: () async => _detail(status: TaskStatus.onHold, hold: HoldReason.breakTime, startedAt: startedAt),
      );
      when(() => pausedElapsed.get(any())).thenAnswer((_) async => 3300);
      await _settle();
      expect(vm.state.pausedElapsedSeconds, 3300);

      await vm.onStart();

      verify(() => pausedElapsed.clear(any())).called(greaterThanOrEqualTo(1));
      expect(vm.state.pausedElapsedSeconds, isNull);
      vm.dispose();
    });

    test('el error de una acción se muestra y libera el bloqueo', () async {
      when(() => start.execute(any())).thenThrow(
        const ApiException(httpStatus: 422, code: 'X', message: 'Ya hay una tarea en curso'),
      );
      final vm = build(
        permissions: {'operations:tasks:track_time'},
        loadDetail: () async => _detail(status: TaskStatus.assigned),
      );
      await _settle();

      await vm.onStart();

      expect(vm.state.error?.asString(strings), 'Ya hay una tarea en curso');
      expect(vm.state.isBusy, isFalse);
      vm.dispose();
    });

    group('repuestos', () {
      const part = _Part();

      test('imputar: elegir, confirmar y recargar el detalle', () async {
        when(() => addPart.execute(any(), any(), any())).thenAnswer(
          (_) async => TaskProduct(id: 'tp1', productId: 'p1', quantity: Decimal.parse('2')),
        );
        final vm = build(
          permissions: {'operations:tasks:charge_parts'},
          loadDetail: () async => _detail(),
        );
        await _settle();

        vm.onChargeClick();
        expect(vm.state.chargeForm, isNotNull);
        vm.onPartSelect(part.out);
        expect(vm.state.chargeForm!.selected, isNull, reason: 'un repuesto agotado no se elige');
        vm.onPartSelect(part.available);
        vm.onChargeQuantityChange('2,5');
        await vm.onChargeConfirm();

        verify(() => addPart.execute(any(), 'p1', Decimal.parse('2.5'))).called(1);
        expect(vm.state.chargeForm, isNull);
        expect(vm.state.notice?.asString(strings), strings.taskPartCharged);
        vm.dispose();
      });

      test('una cantidad inválida marca el campo sin llamar al backend', () async {
        final vm = build(permissions: {'operations:tasks:charge_parts'});
        await _settle();

        vm.onChargeClick();
        vm.onPartSelect(part.available);
        vm.onChargeQuantityChange('abc');
        await vm.onChargeConfirm();

        verifyNever(() => addPart.execute(any(), any(), any()));
        expect(vm.state.invalidField, 'quantity');
        expect(vm.state.error?.asString(strings), strings.taskInvalidInput);
        vm.dispose();
      });

      test('buscar espera el debounce y limpia con texto vacío', () async {
        when(() => search.execute(any())).thenAnswer((_) async => [part.available]);
        final vm = build(permissions: {'operations:tasks:charge_parts'});
        await _settle();
        vm.onChargeClick();

        vm.onChargeQueryChange('pasti');
        verifyNever(() => search.execute(any()));
        await Future<void>.delayed(TaskDetailViewModel.searchDebounce + const Duration(milliseconds: 50));
        verify(() => search.execute('pasti')).called(1);
        expect(vm.state.chargeForm!.results, hasLength(1));

        vm.onChargeQueryChange('');
        expect(vm.state.chargeForm!.results, isEmpty);
        vm.dispose();
      });

      test('corregir cantidad usa el supervisor y devuelve quita el repuesto', () async {
        final product = TaskProduct(id: 'tp1', productId: 'p1', productName: 'Pastillas', quantity: Decimal.parse('2'));
        when(() => updatePart.execute(any(), any(), any())).thenAnswer((_) async => _detail(products: [product]));
        when(() => removePart.execute(any(), any())).thenAnswer((_) async {});
        final vm = build(
          permissions: {'operations:work_orders:update'},
          loadDetail: () async => _detail(products: [product]),
        );
        await _settle();

        vm.onEditPartClick(product);
        expect(vm.state.partEdit!.quantity, '2');
        vm.onPartQuantityChange('3');
        await vm.onPartEditConfirm();
        verify(() => updatePart.execute(any(), 'p1', Decimal.parse('3'))).called(1);
        expect(vm.state.partEdit, isNull);
        expect(vm.state.notice?.asString(strings), strings.taskPartUpdated);

        vm.onReturnPartClick(product);
        await vm.onPartEditConfirm();
        verify(() => removePart.execute(any(), 'p1')).called(1);
        expect(vm.state.notice?.asString(strings), strings.taskPartReturned);
        vm.dispose();
      });

      test('sin work_orders:update no se edita un repuesto', () async {
        final product = TaskProduct(id: 'tp1', productId: 'p1', quantity: Decimal.one);
        final vm = build(permissions: {'operations:tasks:charge_parts'});
        await _settle();
        vm.onEditPartClick(product);
        expect(vm.state.partEdit, isNull);
        vm.dispose();
      });
    });

    test('reabrir una tarea completada envía el motivo y deja el aviso', () async {
      when(() => reopen.execute(any(), reason: any(named: 'reason'))).thenAnswer((_) async => _detail());
      final vm = build(
        permissions: {'operations:work_orders:update'},
        loadDetail: () async => _detail(status: TaskStatus.completed),
      );
      await _settle();
      expect(vm.state.canReopen, isTrue);

      vm.onReopenClick();
      vm.onReopenReasonChange('Verificar torque');
      await vm.onReopenConfirm();

      verify(() => reopen.execute(any(), reason: 'Verificar torque')).called(1);
      expect(vm.state.reopenForm, isNull);
      expect(vm.state.notice?.asString(strings), strings.tasksSeg2ReopenedNotice);
      vm.dispose();
    });
  });
}

class _Part {
  const _Part();

  PartOption get available => PartOption(id: 'p1', name: 'Pastillas', totalStock: Decimal.parse('5'));

  PartOption get out => PartOption(id: 'p2', name: 'Discos', totalStock: Decimal.zero);
}
