import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/refresh_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_errors.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/cancel_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/complete_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/download_quotation_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_part_movements_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/remove_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/send_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/start_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/cascade.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

const _searchDebounce = Duration(milliseconds: 300);

/// Detalle en línea y proforma comercial de la orden (`GET /work-orders/{id}`):
/// - **US22**: cómputo en cascada por tarea (mano de obra + repuestos), adición de tareas y edición de mano
///   de obra.
/// - **US23 / US33**: imputación de repuestos a tareas con validación de stock, ajuste de cantidad y
///   devolución al almacén.
/// - **US24**: descarga de la proforma comercial en PDF para compartirla y envío por correo.
/// - **US25**: respuesta del cliente (aceptar e iniciar trabajos o rechazar con motivo y cancelar).
///
/// - **US29**: aprobar o desestimar suspensiones y reanudar tareas suspendidas.
/// - **US40**: asignar o cambiar la bahía de una orden editable.
///
/// Sin lo que es de otras historias: rentabilidad (US35), resumen de liquidación (US36), cobro y entrega
/// (US37–US39).
class WorkOrderDetailViewModel extends ChangeNotifier {
  final String workOrderId;
  final ObserveSessionUseCase observeSession;
  final GetWorkOrderDetailUseCase getDetail;
  final GetServiceCatalogUseCase getServices;
  final AddWorkOrderTaskUseCase addTask;
  final UpdateWorkOrderTaskUseCase updateTask;
  final RemoveWorkOrderTaskUseCase? removeTask;
  final SearchPartsUseCase searchParts;
  final AddPartToTaskUseCase addPart;
  final UpdateTaskPartQuantityUseCase updatePartQuantity;
  final RemovePartFromTaskUseCase removePart;
  final DownloadQuotationPdfUseCase downloadQuotationPdf;
  final SendQuotationUseCase sendQuotation;
  final ApproveQuotationUseCase approveQuotation;
  final RejectQuotationUseCase rejectQuotation;
  final ConnectivityObserver connectivity;
  final GetBranchMechanicsUseCase? getBranchMechanics;
  final ReassignTaskMechanicUseCase? reassignTaskMechanic;
  final StartWorkOrderUseCase? startOrder;
  final CompleteWorkOrderUseCase? completeOrder;
  final CancelWorkOrderUseCase? cancelOrder;
  final GetPartMovementsUseCase? getPartMovements;
  final ObserveWorkOrderUseCase? observeWorkOrder;
  final ObserveBayBoardUseCase? observeBayBoard;
  final RefreshBayBoardUseCase? refreshBayBoard;
  final ReassignBayUseCase? reassignBay;
  final ApproveSuspensionUseCase? approveSuspension;
  final RejectSuspensionUseCase? rejectSuspension;
  final ResumeSuspendedTaskUseCase? resumeSuspendedTask;

  WorkOrderDetailViewModel({
    this.observeBayBoard,
    this.refreshBayBoard,
    this.reassignBay,
    this.approveSuspension,
    this.rejectSuspension,
    this.resumeSuspendedTask,
    required this.workOrderId,
    required this.observeSession,
    required this.getDetail,
    required this.getServices,
    required this.addTask,
    required this.updateTask,
    this.removeTask,
    required this.searchParts,
    required this.addPart,
    required this.updatePartQuantity,
    required this.removePart,
    required this.downloadQuotationPdf,
    required this.sendQuotation,
    required this.approveQuotation,
    required this.rejectQuotation,
    required this.connectivity,
    this.getBranchMechanics,
    this.reassignTaskMechanic,
    this.startOrder,
    this.completeOrder,
    this.cancelOrder,
    this.getPartMovements,
    this.observeWorkOrder,
  }) {
    _state = WorkOrderDetailUiState(isOnline: connectivity.isOnline);
    final observeCached = observeWorkOrder;
    if (observeCached != null) {
      _subscriptions.add(
        observeCached.execute(WorkOrderId(workOrderId)).listen(_onCachedOrder),
      );
    }
    _subscriptions.add(observeSession.execute().listen(_onSession));
    connectivity.addListener(_onConnectivity);
    load();
  }

  late WorkOrderDetailUiState _state;
  WorkOrderDetailUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _searchTimer;
  bool _disposed = false;

  void _onCachedOrder(WorkOrder? cached) {
    final current = _state.detail;
    WorkOrderDetail? updated = current;
    if (cached != null && current != null) {
      final base = current.workOrder;
      final cachedMileage = cached.mileageIn;
      updated = current.copyWith(
        workOrder: base.copyWith(
          mileageIn: cachedMileage != null && cachedMileage > 0
              ? cachedMileage
              : base.mileageIn,
          diagnosticSummary: cached.diagnosticSummary,
          currentBayId: cached.currentBayId,
          bayName: cached.bayName,
          plate: cached.plate,
          customerName: cached.customerName,
        ),
      );
    }
    _update(_state.copyWith(cachedOrder: cached, detail: updated));
  }

  void _onSession(Session? session) {
    bool has(Permission permission) => session?.has(permission) == true;
    final canReadParts = has(Permission.partsRead);
    final canOpenObd =
        session != null &&
        (session.canUseTelemetry() ||
            session.canReadTelemetry() ||
            session.canUseAiDiagnostics() ||
            session.canReadAiReports() ||
            session.has(Permission.devicesRead) ||
            session.has(Permission.devicesRegister) ||
            session.has(Permission.predictiveAlertsRead));
    _update(
      _state.copyWith(
        canValidateSuspension: has(Permission.tasksHoldValidate),
        canReassignBays: has(Permission.baysReassign),
        canUpdateWorkOrder: has(Permission.workOrdersUpdate),
        canChargeParts:
            has(Permission.tasksChargeParts) ||
            has(Permission.workOrdersUpdate),
        canReadParts: canReadParts,
        canReadQuotation: has(Permission.quotationsRead),
        canSendQuotation: has(Permission.quotationsSend),
        canApproveQuotation: has(Permission.quotationsApprove),
        canReassignMechanic:
            has(Permission.baysReassign) || has(Permission.workOrdersUpdate),
        canCancelWorkOrder: has(Permission.workOrdersCancel),
        canResolveProposals: has(Permission.proposalsResolve),
        canReadPartMovements:
            has(Permission.batchesRead) || has(Permission.batchesRestore),
        canReadProfitability:
            has(Permission.batchesRead) || has(Permission.cashflowExportPdf),
        canOpenObd: canOpenObd,
        hasCheckoutPermission:
            has(Permission.invoicesRead) || has(Permission.invoicesIssueSunat),
      ),
    );
    if (canReadParts && _state.partNamesById.isEmpty) _preloadPartNames();
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final wasOfflineWithoutDetail =
        online && _state.detail == null && !_state.isLoading;
    _update(_state.copyWith(isOnline: online));
    if (wasOfflineWithoutDetail) load();
  }

  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, error: null));
    var services = _state.services;
    try {
      services = await getServices.execute();
    } on Object {
      // Se sigue con el catálogo que ya había.
    }
    WorkOrderDetail? detail;
    Object? failure;
    try {
      detail = await getDetail.execute(WorkOrderId(workOrderId));
    } on Object catch (error) {
      failure = error;
    }
    var mechanics = _state.availableMechanics;
    final loadMechanics = getBranchMechanics;
    if (loadMechanics != null) {
      try {
        mechanics = await loadMechanics.execute();
      } on Object {
        // Se sigue con los colaboradores que ya había.
      }
    }
    if (detail != null) {
      _update(
        _state.copyWith(
          isLoading: false,
          detail: detail,
          services: services,
          availableMechanics: mechanics,
        ),
      );
    } else {
      _update(
        _state.copyWith(
          isLoading: false,
          services: services,
          availableMechanics: mechanics,
          error: toWorkOrderUiText(failure ?? StateError('detail')),
        ),
      );
    }
  }

  /// H11/H36: precarga nombres comerciales del catálogo si la sesión tiene `inventory:parts:read`.
  Future<void> _preloadPartNames() async {
    try {
      final parts = await searchParts.execute('');
      _update(_state.copyWith(partNamesById: _withNames(parts)));
    } on Object {
      // Sin catálogo se muestra el nombre que traiga la tarea.
    }
  }

  Map<String, String> _withNames(List<PartOption> parts) => {
    ..._state.partNamesById,
    for (final part in parts) part.id: part.name,
  };

  // --- US22 E1: agregar una tarea a la orden ---

  Future<void> onOpenAddTask() async {
    if (!_state.canModifyTasks) return;
    _update(
      _state.copyWith(
        addTaskForm: const AddTaskForm(),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    if (_state.availableMechanics.isEmpty) {
      await _loadMechanicsIfMissing();
    }
  }

  Future<void> _loadMechanicsIfMissing() async {
    final loader = getBranchMechanics;
    if (loader == null) return;
    try {
      _update(_state.copyWith(availableMechanics: await loader.execute()));
    } on Object {
      // La tarea se puede asignar luego.
    }
  }

  void onDismissAddTask() {
    if (_state.isBusy) return;
    _update(
      _state.copyWith(addTaskForm: null, error: null, invalidField: null),
    );
  }

  void onSelectTaskService(ServiceOption service) => _editAddTask((form) {
    final defaultPrice = service.basePrice?.amount.toString() ?? '';
    return form.copyWith(
      serviceId: service.id,
      description: form.description.trim().isEmpty
          ? service.name
          : form.description,
      price: form.price.trim().isEmpty ? defaultPrice : form.price,
    );
  });

  void onAddTaskDescriptionChange(String value) =>
      _editAddTask((form) => form.copyWith(description: value));

  void onAddTaskPriceChange(String value) =>
      _editAddTask((form) => form.copyWith(price: value));

  void onSelectAddTaskMechanic(String? mechanicId) =>
      _editAddTask((form) => form.copyWith(mechanicId: mechanicId));

  void _editAddTask(AddTaskForm Function(AddTaskForm) change) {
    final form = _state.addTaskForm;
    if (form == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        addTaskForm: change(form),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> onConfirmAddTask() async {
    final state = _state;
    final form = state.addTaskForm;
    if (form == null || !state.canModifyTasks) return;
    final serviceId = form.serviceId;
    if (serviceId == null || serviceId.trim().isEmpty) {
      _failWorkOrder(const InvalidWorkOrderInputException('serviceId'));
      return;
    }
    final price = form.price.trim().isEmpty
        ? null
        : _toDecimalAmount(form.price);
    if (form.price.trim().isNotEmpty && price == null) {
      _failWorkOrder(const InvalidWorkOrderInputException('price'));
      return;
    }
    _update(
      state.copyWith(
        busyAction: WorkOrderDetailAction.addTask,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final updated = await addTask.execute(
        WorkOrderId(workOrderId),
        NewWorkOrderTask(
          serviceId: serviceId,
          description: form.description.trim(),
          mechanicId: form.mechanicId,
          price: price,
        ),
      );
      _update(
        _state.copyWith(
          busyAction: null,
          addTaskForm: null,
          detail: updated,
          notice: UiText.resource((s) => s.orderTaskAdded),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  // --- US22 E2: editar mano de obra de una tarea ---

  void onOpenEditLabor(TaskDetail task) {
    final state = _state;
    if (!state.canModifyTasks) return;
    final currentPrice = task.price?.amount.toString() ?? '';
    _update(
      state.copyWith(
        editLaborForm: EditLaborForm(
          taskId: task.id,
          taskTitle: state.taskTitle(task),
          price: currentPrice,
        ),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissEditLabor() {
    if (_state.isBusy) return;
    _update(
      _state.copyWith(editLaborForm: null, error: null, invalidField: null),
    );
  }

  void onEditLaborPriceChange(String value) {
    final form = _state.editLaborForm;
    if (form == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        editLaborForm: form.copyWith(price: value),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> onConfirmEditLabor() async {
    final state = _state;
    final form = state.editLaborForm;
    if (form == null || !state.canModifyTasks) return;
    final price = _toDecimalAmount(form.price);
    if (price == null) {
      _failWorkOrder(const InvalidWorkOrderInputException('price'));
      return;
    }
    _update(
      state.copyWith(
        busyAction: WorkOrderDetailAction.editLabor,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final updated = await updateTask.execute(
        WorkOrderId(workOrderId),
        form.taskId,
        WorkOrderTaskChanges(price: price),
      );
      _update(
        _state.copyWith(
          busyAction: null,
          editLaborForm: null,
          detail: updated,
          notice: UiText.resource((s) => s.orderTaskUpdated),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  void onOpenDeleteTask(TaskDetail task) {
    final state = _state;
    if (!state.canModifyTasks) return;
    _update(
      state.copyWith(
        deletingTask: task,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissDeleteTask() {
    if (_state.isBusy) return;
    _update(_state.copyWith(deletingTask: null, error: null));
  }

  Future<void> onConfirmDeleteTask() async {
    final state = _state;
    final task = state.deletingTask;
    final remove = removeTask;
    if (task == null ||
        remove == null ||
        !state.canModifyTasks ||
        task.products.isNotEmpty)
      return;
    _update(
      state.copyWith(busyAction: WorkOrderDetailAction.deleteTask, error: null),
    );
    try {
      final updated = await remove.execute(WorkOrderId(workOrderId), task.id);
      _update(
        _state.copyWith(
          busyAction: null,
          deletingTask: null,
          detail: updated,
          notice: UiText.resource((s) => s.orderTaskDeleted),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  // --- US23: imputar repuesto a una tarea y recalcular en cascada ---

  Future<void> onOpenChargePart(TaskId taskId) async {
    if (!_state.canAddPartToTask) return;
    _update(
      _state.copyWith(
        chargeTaskId: taskId,
        chargeForm: const ChargeForm(isSearching: true),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final parts = await searchParts.execute('');
      _update(
        _state.copyWith(
          partNamesById: _withNames(parts),
          chargeForm: _state.chargeForm?.copyWith(
            results: parts,
            isSearching: false,
          ),
        ),
      );
    } on Object {
      _update(
        _state.copyWith(
          chargeForm: _state.chargeForm?.copyWith(isSearching: false),
        ),
      );
    }
  }

  void onDismissChargePart() {
    _searchTimer?.cancel();
    if (_state.isBusy) return;
    _update(
      _state.copyWith(
        chargeTaskId: null,
        chargeForm: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void _editCharge(ChargeForm Function(ChargeForm) change) {
    final form = _state.chargeForm;
    if (form == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        chargeForm: change(form),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> _loadParts(String query) async {
    try {
      final parts = await searchParts.execute(query);
      _update(
        _state.copyWith(
          partNamesById: _withNames(parts),
          chargeForm: _state.chargeForm?.copyWith(
            results: parts,
            isSearching: false,
          ),
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          chargeForm: _state.chargeForm?.copyWith(isSearching: false),
          error: toTaskUiText(error),
        ),
      );
    }
  }

  void onChargeQueryChange(String value) {
    _searchTimer?.cancel();
    if (value.trim().isEmpty) {
      _editCharge(
        (form) =>
            form.copyWith(query: value, selected: null, isSearching: true),
      );
      _loadParts('');
      return;
    }
    _editCharge((form) => form.copyWith(query: value, selected: null));
    _searchTimer = Timer(_searchDebounce, () {
      if (_disposed) return;
      _editCharge((form) => form.copyWith(isSearching: true));
      _loadParts(value.trim());
    });
  }

  void onSelectPart(PartOption part) {
    if (!part.isAvailable) return;
    final form = _state.chargeForm;
    if (form == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        partNamesById: {..._state.partNamesById, part.id: part.name},
        chargeForm: form.copyWith(
          selected: part,
          quantity: form.quantity.trim().isEmpty ? '1' : form.quantity,
        ),
        error: null,
        invalidField: null,
      ),
    );
  }

  void onChargeQuantityChange(String value) =>
      _editCharge((form) => form.copyWith(quantity: value));

  Future<void> onConfirmChargePart() async {
    final state = _state;
    final taskId = state.chargeTaskId;
    final form = state.chargeForm;
    final part = form?.selected;
    if (taskId == null || form == null || part == null) return;
    if (!state.canAddPartToTask) return;
    final quantity = _toDecimalAmount(form.quantity);
    if (quantity == null) {
      _failTask(const InvalidTaskInputException('quantity'));
      return;
    }
    _update(
      state.copyWith(
        busyAction: WorkOrderDetailAction.chargePart,
        error: null,
        invalidField: null,
      ),
    );
    try {
      await addPart.execute(taskId, part.id, quantity);
      await _reloadOrderAfterPartChange(
        UiText.resource((s) => s.taskPartCharged),
      );
    } on Object catch (error) {
      _failTask(error);
    }
  }

  // --- US23 / US33: corregir cantidad o retirar pieza imputada ---

  void onOpenEditPart(TaskId taskId, TaskProduct product) =>
      _openPartEdit(taskId, product, PartEditMode.editQuantity);

  void onOpenReturnPart(TaskId taskId, TaskProduct product) =>
      _openPartEdit(taskId, product, PartEditMode.returnPart);

  void _openPartEdit(TaskId taskId, TaskProduct product, PartEditMode mode) {
    if (!_state.canEditTaskParts) return;
    _update(
      _state.copyWith(
        editingPartTaskId: taskId,
        partEdit: PartEditForm(
          product: product,
          mode: mode,
          quantity: product.quantity.toString(),
        ),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissPartEdit() {
    if (_state.isBusy) return;
    _update(
      _state.copyWith(
        editingPartTaskId: null,
        partEdit: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onPartEditQuantityChange(String value) {
    final edit = _state.partEdit;
    if (edit == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        partEdit: edit.copyWith(quantity: value),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> onConfirmPartEdit() async {
    final state = _state;
    final taskId = state.editingPartTaskId;
    final edit = state.partEdit;
    if (taskId == null || edit == null || !state.canEditTaskParts) return;
    switch (edit.mode) {
      case PartEditMode.returnPart:
        _update(
          state.copyWith(
            busyAction: WorkOrderDetailAction.removePart,
            error: null,
            invalidField: null,
          ),
        );
        try {
          await removePart.execute(taskId, edit.product.productId);
          await _reloadOrderAfterPartChange(
            UiText.resource((s) => s.taskPartReturned),
          );
        } on Object catch (error) {
          _failTask(error);
        }
      case PartEditMode.editQuantity:
        final quantity = _toDecimalAmount(edit.quantity);
        if (quantity == null) {
          _failTask(const InvalidTaskInputException('quantity'));
          return;
        }
        _update(
          state.copyWith(
            busyAction: WorkOrderDetailAction.editPart,
            error: null,
            invalidField: null,
          ),
        );
        try {
          await updatePartQuantity.execute(
            taskId,
            edit.product.productId,
            quantity,
          );
          await _reloadOrderAfterPartChange(
            UiText.resource((s) => s.taskPartUpdated),
          );
        } on Object catch (error) {
          _failTask(error);
        }
    }
  }

  Future<void> _reloadOrderAfterPartChange(UiText notice) async {
    try {
      final updated = await getDetail.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          busyAction: null,
          chargeTaskId: null,
          chargeForm: null,
          editingPartTaskId: null,
          partEdit: null,
          detail: updated,
          notice: notice,
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          busyAction: null,
          chargeTaskId: null,
          chargeForm: null,
          editingPartTaskId: null,
          partEdit: null,
          notice: notice,
          error: toWorkOrderUiText(error),
        ),
      );
    }
  }

  // --- US24: generar proforma en PDF y enviar por correo ---

  Future<void> onGenerateQuotationPdf() async {
    if (!_state.canGeneratePdf) return;
    _update(
      _state.copyWith(
        busyAction: WorkOrderDetailAction.downloadPdf,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final file = await downloadQuotationPdf.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          busyAction: null,
          generatedPdf: file,
          notice: UiText.resource((s) => s.quotationPdfReady),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  void onPdfHandled() => _update(_state.copyWith(generatedPdf: null));

  void onPdfOpenFailed() => _update(
    _state.copyWith(
      generatedPdf: null,
      error: UiText.resource((s) => s.quotationNoPdfApp),
    ),
  );

  Future<void> onSendQuotationEmail() async {
    if (!_state.canEmailQuotation) return;
    _update(
      _state.copyWith(
        busyAction: WorkOrderDetailAction.sendEmail,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final email = await sendQuotation.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          busyAction: null,
          proformaSentLabel: email,
          notice: UiText.resource((s) => s.quotationSentNotice(email)),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  // --- US25: formalización de la respuesta del cliente (aceptar o rechazar presupuesto) ---

  Future<void> onApproveQuotation() async {
    if (!_state.canResolveQuotation) return;
    _update(
      _state.copyWith(
        busyAction: WorkOrderDetailAction.approveQuotation,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final updatedOrder = await approveQuotation.execute(
        WorkOrderId(workOrderId),
      );
      _update(
        _state.copyWith(
          busyAction: null,
          showQuotationDecision: false,
          detail: _state.detail?.copyWith(workOrder: updatedOrder),
          notice: UiText.resource((s) => s.quotationApprovedNotice),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  void onOpenRejectQuotation() {
    if (!_state.canResolveQuotation) return;
    _update(
      _state.copyWith(
        rejectForm: const RejectQuotationForm(),
        showQuotationDecision: false,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissRejectQuotation() {
    if (_state.isBusy) return;
    _update(_state.copyWith(rejectForm: null, error: null, invalidField: null));
  }

  void onRejectReasonChange(String value) {
    if (_state.rejectForm == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        rejectForm: RejectQuotationForm(reason: value),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> onConfirmRejectQuotation() async {
    final state = _state;
    final form = state.rejectForm;
    if (form == null || !state.canResolveQuotation) return;
    _update(
      state.copyWith(
        busyAction: WorkOrderDetailAction.rejectQuotation,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final canceled = await rejectQuotation.execute(
        WorkOrderId(workOrderId),
        form.reason.trim(),
      );
      _update(
        _state.copyWith(
          busyAction: null,
          rejectForm: null,
          detail: _state.detail?.copyWith(workOrder: canceled),
          notice: UiText.resource((s) => s.quotationRejectedNotice),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  // --- Respuesta del cliente a la proforma, en hoja inferior ---

  void onOpenQuotationDecision() {
    if (!(_state.canApproveQuotation && _state.isDraft)) return;
    _update(
      _state.copyWith(showQuotationDecision: true, notice: null, error: null),
    );
  }

  void onDismissQuotationDecision() {
    if (_state.isBusy) return;
    _update(_state.copyWith(showQuotationDecision: false, error: null));
  }

  // --- Ciclo de vida de la orden: iniciar, completar, cancelar (en línea) ---

  Future<void> onStartOrder() async {
    final start = startOrder;
    if (start == null || !_state.canStartOrder) return;
    await _runOrderAction(
      WorkOrderDetailAction.startOrder,
      UiText.resource((s) => s.ordersStartedNotice),
      () => start.execute(WorkOrderId(workOrderId)),
    );
  }

  Future<void> onCompleteOrder() async {
    final complete = completeOrder;
    if (complete == null || !_state.canCompleteOrder) return;
    await _runOrderAction(
      WorkOrderDetailAction.completeOrder,
      UiText.resource((s) => s.ordersCompletedNotice),
      () => complete.execute(WorkOrderId(workOrderId)),
    );
  }

  void onOpenCancelOrder() {
    if (!_state.canCancelOrder) return;
    _update(
      _state.copyWith(
        cancelForm: const CancelOrderForm(),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissCancelOrder() {
    if (_state.isBusy) return;
    _update(_state.copyWith(cancelForm: null, error: null, invalidField: null));
  }

  void onCancelReasonChange(String value) {
    if (_state.cancelForm == null || _state.isBusy) return;
    _update(
      _state.copyWith(
        cancelForm: CancelOrderForm(reason: value),
        error: null,
        invalidField: null,
      ),
    );
  }

  Future<void> onConfirmCancelOrder() async {
    final cancel = cancelOrder;
    final form = _state.cancelForm;
    if (cancel == null || form == null || !_state.canCancelOrder) return;
    await _runOrderAction(
      WorkOrderDetailAction.cancelOrder,
      UiText.resource((s) => s.ordersCanceledNotice),
      () => cancel.execute(WorkOrderId(workOrderId), form.reason.trim()),
    );
  }

  Future<void> _runOrderAction(
    WorkOrderDetailAction action,
    UiText notice,
    Future<WorkOrder> Function() call,
  ) async {
    _update(
      _state.copyWith(
        busyAction: action,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final updated = await call();
      final current = _state.detail;
      _update(
        _state.copyWith(
          busyAction: null,
          cancelForm: null,
          // La respuesta de estas acciones no trae placa ni cliente: se conservan los de la ficha.
          detail: current?.copyWith(
            workOrder: updated.copyWith(
              plate: updated.plate ?? current.workOrder.plate,
              customerName:
                  updated.customerName ?? current.workOrder.customerName,
              bayName: updated.bayName ?? current.workOrder.bayName,
            ),
          ),
          notice: notice,
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  // --- US40: asignar o cambiar la bahía de la orden ---

  Future<void> onOpenAssignBay() async {
    final observe = observeBayBoard;
    if (observe == null || !_state.canAssignBay) return;
    _update(
      _state.copyWith(
        assignBayForm: const AssignBayForm(),
        notice: null,
        error: null,
      ),
    );
    Object? failure;
    try {
      await refreshBayBoard?.execute();
    } on Object catch (error) {
      failure = error;
    }
    var bays = const <WorkBay>[];
    try {
      bays = [for (final item in await observe.execute().first) item.bay];
    } on Object catch (error) {
      failure = error;
    }
    // La hoja pudo cerrarse mientras cargaba.
    if (_state.assignBayForm == null) return;
    _update(
      _state.copyWith(
        assignBayForm: AssignBayForm(isLoading: false, bays: bays),
        error: failure == null ? null : toWorkOrderUiText(failure),
      ),
    );
  }

  void onDismissAssignBay() {
    if (_state.isBusy) return;
    _update(_state.copyWith(assignBayForm: null, error: null));
  }

  /// US40 E1/E2: una bahía no libre no llega al backend; con 409 la asignación previa queda intacta.
  Future<void> onConfirmAssignBay(WorkBay bay) async {
    final reassign = reassignBay;
    if (reassign == null ||
        _state.assignBayForm == null ||
        !_state.canAssignBay)
      return;
    _update(
      _state.copyWith(
        busyAction: WorkOrderDetailAction.assignBay,
        error: null,
        notice: null,
      ),
    );
    try {
      await reassign.execute(workOrderId, bay);
    } on BayUnavailableException {
      _update(
        _state.copyWith(
          busyAction: null,
          error: UiText.resource((s) => s.baysUnavailableError),
        ),
      );
      return;
    } on Object catch (error) {
      _failWorkOrder(error);
      return;
    }
    var detail = _state.detail;
    try {
      detail = await getDetail.execute(WorkOrderId(workOrderId));
    } on Object {
      detail = detail?.copyWith(
        workOrder: detail.workOrder.copyWith(
          currentBayId: bay.id,
          bayName: bay.name,
        ),
      );
    }
    _update(
      _state.copyWith(
        busyAction: null,
        assignBayForm: null,
        detail: detail,
        notice: UiText.resource((s) => s.baysAssignedNotice(bay.name)),
      ),
    );
  }

  // --- US29: revisar solicitudes de suspensión y reanudar tareas (H5) ---

  void onOpenSuspensionReview(TaskDetail task) {
    if (!_state.canReviewSuspension || !task.hasPendingSuspension) return;
    _update(
      _state.copyWith(reviewingSuspensionTask: task, notice: null, error: null),
    );
  }

  void onDismissSuspensionReview() {
    if (_state.isBusy) return;
    _update(_state.copyWith(reviewingSuspensionTask: null, error: null));
  }

  Future<void> onApproveSuspension() async {
    final approve = approveSuspension;
    final task = _state.reviewingSuspensionTask;
    if (approve == null || task == null || !_state.canReviewSuspension) return;
    await _runSuspensionAction(
      WorkOrderDetailAction.approveSuspension,
      UiText.resource((s) => s.ordersSuspensionApprovedNotice),
      () => approve.execute(task.id),
    );
  }

  Future<void> onRejectSuspension() async {
    final reject = rejectSuspension;
    final task = _state.reviewingSuspensionTask;
    if (reject == null || task == null || !_state.canReviewSuspension) return;
    await _runSuspensionAction(
      WorkOrderDetailAction.rejectSuspension,
      UiText.resource((s) => s.ordersSuspensionRejectedNotice),
      () => reject.execute(task.id),
    );
  }

  Future<void> onResumeSuspendedTask(TaskDetail task) async {
    final resume = resumeSuspendedTask;
    if (resume == null || !_state.canReviewSuspension || !task.isSuspended)
      return;
    await _runSuspensionAction(
      WorkOrderDetailAction.resumeSuspended,
      UiText.resource((s) => s.ordersTaskResumedNotice),
      () => resume.execute(task.id),
    );
  }

  /// La acción devuelve solo la tarea: se recarga la orden. Si la recarga falla, la acción igual se hizo, así
  /// que se pone la tarea devuelta en su sitio.
  Future<void> _runSuspensionAction(
    WorkOrderDetailAction action,
    UiText notice,
    Future<TaskDetail> Function() call,
  ) async {
    _update(
      _state.copyWith(
        busyAction: action,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    final TaskDetail updated;
    try {
      updated = await call();
    } on Object catch (error) {
      _failTask(error);
      return;
    }
    var detail = _state.detail;
    try {
      detail = await getDetail.execute(WorkOrderId(workOrderId));
    } on Object {
      detail = detail?.copyWith(
        tasks: [
          for (final task in detail.tasks)
            task.id.value == updated.id.value ? updated : task,
        ],
      );
    }
    _update(
      _state.copyWith(
        busyAction: null,
        reviewingSuspensionTask: null,
        detail: detail,
        notice: notice,
      ),
    );
  }

  // --- Movimientos de repuestos (US33 E2): se piden al abrir la hoja ---

  Future<void> onOpenMovements() async {
    final get = getPartMovements;
    final state = _state;
    if (get == null || !state.canReadPartMovements || !state.isOnline) return;
    _update(
      state.copyWith(
        movements: const OnDemand<List<PartMovement>>(),
        notice: null,
        error: null,
      ),
    );
    try {
      final data = await get.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          movements: OnDemand<List<PartMovement>>(isLoading: false, data: data),
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          movements: OnDemand<List<PartMovement>>(
            isLoading: false,
            error: toWorkOrderUiText(error),
          ),
        ),
      );
    }
  }

  void onDismissMovements() => _update(_state.copyWith(movements: null));

  // --- Asignar o reasignar mecánico para una tarea (US12 E2, US22 E2) ---

  Future<void> onOpenAssignMechanic(TaskDetail task) async {
    if (!_state.canChangeMechanic) return;
    _update(
      _state.copyWith(assigningMechanicTask: task, notice: null, error: null),
    );
    if (_state.availableMechanics.isEmpty) await _loadMechanicsIfMissing();
  }

  void onDismissAssignMechanic() {
    if (_state.isBusy) return;
    _update(_state.copyWith(assigningMechanicTask: null, error: null));
  }

  Future<void> onConfirmAssignMechanic(MechanicOption mechanic) async {
    final state = _state;
    final task = state.assigningMechanicTask;
    if (task == null || !state.canChangeMechanic || state.isBusy) return;
    _update(
      state.copyWith(
        busyAction: WorkOrderDetailAction.assignMechanic,
        error: null,
      ),
    );
    try {
      final id = WorkOrderId(workOrderId);
      final reassign = reassignTaskMechanic;
      WorkOrderDetail detail;
      if (reassign != null) {
        var fallback = false;
        try {
          await reassign.execute(task.id.value, mechanic.membershipId);
        } on ApiException catch (error) {
          if (error.httpStatus == 403 && state.canUpdateWorkOrder) {
            fallback = true;
          } else {
            rethrow;
          }
        }
        detail = fallback
            ? await updateTask.execute(
                id,
                task.id,
                WorkOrderTaskChanges(mechanicId: mechanic.membershipId),
              )
            : await getDetail.execute(id);
      } else {
        detail = await updateTask.execute(
          id,
          task.id,
          WorkOrderTaskChanges(mechanicId: mechanic.membershipId),
        );
      }
      final name = mechanic.displayName;
      _update(
        _state.copyWith(
          busyAction: null,
          assigningMechanicTask: null,
          detail: detail,
          notice: UiText.resource((s) => s.orderMechanicAssignedNotice(name)),
        ),
      );
    } on Object catch (error) {
      _failWorkOrder(error);
    }
  }

  Decimal? _toDecimalAmount(String value) =>
      Decimal.tryParse(value.trim().replaceAll(',', '.'));

  void _failWorkOrder(Object error) {
    _update(
      _state.copyWith(
        busyAction: null,
        error: toWorkOrderUiText(error),
        invalidField: invalidWorkOrderField(error),
      ),
    );
  }

  void _failTask(Object error) {
    _update(
      _state.copyWith(
        busyAction: null,
        error: toTaskUiText(error),
        invalidField: invalidTaskField(error),
      ),
    );
  }

  void _update(WorkOrderDetailUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
