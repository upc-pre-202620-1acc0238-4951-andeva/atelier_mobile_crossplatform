import 'dart:async';
import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/download_quotation_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_pending_suspensions_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/send_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ObserveSession extends Mock implements ObserveSessionUseCase {}

class _GetDetail extends Mock implements GetWorkOrderDetailUseCase {}

class _GetServices extends Mock implements GetServiceCatalogUseCase {}

class _AddTask extends Mock implements AddWorkOrderTaskUseCase {}

class _UpdateTask extends Mock implements UpdateWorkOrderTaskUseCase {}

class _Search extends Mock implements SearchPartsUseCase {}

class _AddPart extends Mock implements AddPartToTaskUseCase {}

class _UpdatePart extends Mock implements UpdateTaskPartQuantityUseCase {}

class _RemovePart extends Mock implements RemovePartFromTaskUseCase {}

class _Download extends Mock implements DownloadQuotationPdfUseCase {}

class _Send extends Mock implements SendQuotationUseCase {}

class _ApproveQuotation extends Mock implements ApproveQuotationUseCase {}

class _RejectQuotation extends Mock implements RejectQuotationUseCase {}

class _Approve extends Mock implements ApproveSuspensionUseCase {}

class _Reject extends Mock implements RejectSuspensionUseCase {}

class _Resume extends Mock implements ResumeSuspendedTaskUseCase {}

class _Repository extends Mock implements WorkOrderRepository {}

TaskDetail _task(String id, {TaskStatus status = TaskStatus.inProgress, HoldReason? hold, String? pending}) {
  return TaskDetail(
    id: TaskId(id),
    workOrderId: 'wo1',
    status: status,
    holdReason: hold,
    pendingSuspensionReason: pending,
    description: 'Tarea $id',
    totalPausedSeconds: 0,
  );
}

WorkOrder _order(String id, WorkOrderStatus status) {
  return WorkOrder(
    id: WorkOrderId(id),
    branchId: 'b1',
    vehicleId: 'v1',
    customerId: 'c1',
    status: status,
  );
}

WorkOrderDetail _detail(List<TaskDetail> tasks, {String id = 'wo1'}) {
  return WorkOrderDetail(
    workOrder: _order(id, WorkOrderStatus.inProgress),
    tasks: tasks,
    proposals: const [],
    intakeImages: const [],
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));

  setUpAll(() {
    registerFallbackValue(TaskId('x'));
    registerFallbackValue(WorkOrderId('x'));
  });

  group('US29 desde el detalle de la orden', () {
    late _GetDetail getDetail;
    late _Approve approve;
    late _Reject reject;
    late _Resume resume;

    WorkOrderDetailViewModel build(Set<String> permissions) {
      final session = _ObserveSession();
      when(() => session.execute()).thenAnswer(
        (_) => Stream.value(
          Session(
            userId: 'u1',
            email: 'a@b.pe',
            fullName: 'Ana',
            tenantId: 't1',
            tenantName: 'Taller',
            membershipId: 'm1',
            permissions: permissions,
            plan: null,
          ),
        ),
      );
      final services = _GetServices();
      when(() => services.execute()).thenAnswer((_) async => []);
      return WorkOrderDetailViewModel(
        workOrderId: 'wo1',
        observeSession: session,
        getDetail: getDetail,
        getServices: services,
        addTask: _AddTask(),
        updateTask: _UpdateTask(),
        searchParts: _Search(),
        addPart: _AddPart(),
        updatePartQuantity: _UpdatePart(),
        removePart: _RemovePart(),
        downloadQuotationPdf: _Download(),
        sendQuotation: _Send(),
        approveQuotation: _ApproveQuotation(),
        rejectQuotation: _RejectQuotation(),
        connectivity: ConnectivityObserver(
          changes: const Stream.empty(),
          current: () async => [ConnectivityResult.wifi],
        ),
        approveSuspension: approve,
        rejectSuspension: reject,
        resumeSuspendedTask: resume,
      );
    }

    setUp(() {
      getDetail = _GetDetail();
      approve = _Approve();
      reject = _Reject();
      resume = _Resume();
      when(() => getDetail.execute(any())).thenAnswer((_) async => _detail([_task('t1', pending: 'Retén')]));
    });

    test('aprobar cierra la hoja y recarga la orden', () async {
      final suspended = _task('t1', status: TaskStatus.onHold, hold: HoldReason.waitingParts);
      when(() => approve.execute(any())).thenAnswer((_) async => suspended);
      final vm = build({'operations:tasks:hold_validate'});
      await _settle();

      vm.onOpenSuspensionReview(vm.state.detail!.tasks.single);
      expect(vm.state.reviewingSuspensionTask, isNotNull);
      when(() => getDetail.execute(any())).thenAnswer((_) async => _detail([suspended]));
      await vm.onApproveSuspension();

      verify(() => approve.execute(any())).called(1);
      expect(vm.state.reviewingSuspensionTask, isNull);
      expect(vm.state.detail!.tasks.single.isSuspended, isTrue);
      expect(vm.state.notice?.asString(strings), strings.ordersSuspensionApprovedNotice);
      vm.dispose();
    });

    test('reanudar sin poder recargar deja la tarea devuelta en la orden', () async {
      final suspended = _task('t1', status: TaskStatus.onHold, hold: HoldReason.waitingParts);
      when(() => getDetail.execute(any())).thenAnswer((_) async => _detail([suspended, _task('t2')]));
      when(() => resume.execute(any())).thenAnswer((_) async => _task('t1'));
      final vm = build({'operations:tasks:hold_validate'});
      await _settle();

      when(() => getDetail.execute(any())).thenThrow(const NetworkException());
      await vm.onResumeSuspendedTask(suspended);

      expect(vm.state.detail!.tasks.map((t) => t.status), [TaskStatus.inProgress, TaskStatus.inProgress]);
      expect(vm.state.notice?.asString(strings), strings.ordersTaskResumedNotice);
      vm.dispose();
    });

    test('si el backend rechaza, la hoja sigue abierta con su message', () async {
      when(() => reject.execute(any()))
          .thenThrow(const ApiException(httpStatus: 422, code: 'X', message: 'Sin solicitud'));
      final vm = build({'operations:tasks:hold_validate'});
      await _settle();

      vm.onOpenSuspensionReview(vm.state.detail!.tasks.single);
      await vm.onRejectSuspension();

      expect(vm.state.reviewingSuspensionTask, isNotNull);
      expect(vm.state.error?.asString(strings), 'Sin solicitud');
      vm.dispose();
    });

    test('sin hold_validate no abre la revisión', () async {
      final vm = build({'operations:tasks:hold_request'});
      await _settle();
      vm.onOpenSuspensionReview(vm.state.detail!.tasks.single);
      expect(vm.state.reviewingSuspensionTask, isNull);
      vm.dispose();
    });
  });

  group('FindPendingSuspensionsUseCase', () {
    test('consulta solo órdenes activas y sigue si una falla', () async {
      final repository = _Repository();
      when(() => repository.getDetail(any())).thenAnswer((invocation) async {
        final id = (invocation.positionalArguments.first as WorkOrderId).value;
        if (id == 'broken') throw const NetworkException();
        return _detail([_task('t1', pending: 'Retén'), _task('t2')], id: id);
      });

      final pending = await FindPendingSuspensionsUseCase(repository: repository).execute([
        _order('broken', WorkOrderStatus.inProgress),
        _order('wo1', WorkOrderStatus.inProgress),
        _order('done', WorkOrderStatus.completed),
      ]);

      expect(pending.map((p) => '${p.order.id.value}:${p.task.id.value}'), ['wo1:t1']);
      verify(() => repository.getDetail(any())).called(2);
    });

    test('mira como mucho 15 órdenes en curso y no las borradores', () async {
      final repository = _Repository();
      when(() => repository.getDetail(any())).thenAnswer((invocation) async {
        final id = (invocation.positionalArguments.first as WorkOrderId).value;
        return _detail([_task('t1', pending: 'Retén')], id: id);
      });

      final pending = await FindPendingSuspensionsUseCase(repository: repository).execute([
        for (var i = 0; i < 20; i++) _order('wo$i', WorkOrderStatus.inProgress),
        _order('draft', WorkOrderStatus.draft),
      ]);

      expect(pending, hasLength(15));
      verify(() => repository.getDetail(any())).called(15);
    });
  });
}
