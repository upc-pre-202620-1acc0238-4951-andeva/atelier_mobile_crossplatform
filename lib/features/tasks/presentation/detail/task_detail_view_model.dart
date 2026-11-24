import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reopen_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/task_errors.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// US27, US23, US33: detalle de tarea con cronómetro tabular, pausa tipificada, reapertura y gestión FIFO de
/// repuestos. Sin evidencia fotográfica (US28), suspensiones (US29) ni cierre con horas hombre (US30).
class TaskDetailViewModel extends ChangeNotifier {
  static const searchDebounce = Duration(milliseconds: 300);

  final TaskId taskId;
  final ObserveSessionUseCase observeSession;
  final ObserveTaskUseCase observeTask;
  final GetTaskDetailUseCase getDetail;
  final StartTaskUseCase startTask;
  final PauseTaskUseCase pauseTask;
  final ReopenTaskUseCase reopenTask;
  final SearchPartsUseCase searchParts;
  final AddPartToTaskUseCase addPart;
  final UpdateTaskPartQuantityUseCase updatePartQuantity;
  final RemovePartFromTaskUseCase removePart;
  final PausedElapsedStore pausedElapsed;
  final ConnectivityObserver connectivity;
  final DateTime Function() now;

  TaskDetailViewModel({
    required this.taskId,
    required String workOrderId,
    required this.observeSession,
    required this.observeTask,
    required this.getDetail,
    required this.startTask,
    required this.pauseTask,
    required this.reopenTask,
    required this.searchParts,
    required this.addPart,
    required this.updatePartQuantity,
    required this.removePart,
    required this.pausedElapsed,
    required this.connectivity,
    this.now = DateTime.now,
  }) {
    _state = TaskDetailUiState(fallbackWorkOrderId: workOrderId, isOnline: connectivity.isOnline);
    _subscriptions.add(
      observeSession.execute().listen((session) {
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
            canTrackTime: session?.has(Permission.tasksTrackTime) == true,
            canChargeParts:
                session?.has(Permission.tasksChargeParts) == true || session?.has(Permission.workOrdersUpdate) == true,
            canEditParts: session?.has(Permission.workOrdersUpdate) == true,
            canReportFinding: session?.has(Permission.proposalsCreate) == true,
            canOpenObd: canOpenObd,
            canReopenTask: session?.has(Permission.workOrdersUpdate) == true,
          ),
        );
      }),
    );
    _subscriptions.add(observeTask.execute(taskId).listen((task) => _update(_state.copyWith(task: task))));
    connectivity.addListener(_onConnectivity);
    load();
  }

  late TaskDetailUiState _state;
  TaskDetailUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _searchTimer;
  bool _disposed = false;

  /// D3: si la pantalla se abrió sin red, al volver la conexión se carga el detalle (repuestos incluidos).
  void _onConnectivity() {
    final online = connectivity.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (online && _state.detail == null && !_state.isLoading) load();
  }

  /// `GET /tasks/{id}`: servicio y repuestos imputados. Sin red se sigue con la caché.
  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final detail = await getDetail.execute(taskId);
      _update(_state.copyWith(isLoading: false, detail: detail));
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, error: toTaskUiText(e)));
    }
    await _syncPausedElapsed();
  }

  /// D1: recupera el tiempo guardado al pausar; fuera de una pausa no hay nada que mostrar y se limpia.
  Future<void> _syncPausedElapsed() async {
    final paused = _state.status == TaskStatus.onHold;
    final seconds = paused ? await pausedElapsed.get(taskId) : null;
    if (!paused) await pausedElapsed.clear(taskId);
    _update(_state.copyWith(pausedElapsedSeconds: seconds, clearPausedElapsedSeconds: seconds == null));
  }

  /// US27 E1 y E5: pasa a `IN_PROGRESS`; el cronómetro cuenta desde `startedAt` menos lo pausado.
  Future<void> onStart() async {
    if (!_state.canStart) return;
    await _run(TaskAction.start, () => startTask.execute(taskId));
  }

  void onPauseClick() {
    if (!_state.canPause) return;
    _update(_state.copyWith(pauseForm: const PauseForm(), clearNotice: true, clearError: true));
  }

  void onPauseDismiss() {
    if (_state.pauseForm == null) return;
    _update(_state.copyWith(clearPauseForm: true));
  }

  /// US27 E2 y E3: el backend rechaza `END_OF_SHIFT` si el turno sigue vigente (422) y su `message` se muestra.
  Future<void> onPause(PauseReason reason) async {
    if (!_state.canPause) return;
    // El tiempo efectivo se calcula antes de pausar: después el backend ya no lo permite deducir.
    final startedAt = _state.startedAt;
    final elapsed = startedAt == null
        ? null
        : LaborTime.effectiveSeconds(startedAt, _state.totalPausedSeconds, now());
    _update(_state.copyWith(clearPauseForm: true));
    await _run(
      TaskAction.pause,
      () => pauseTask.execute(taskId, reason),
      frozenAtPause: elapsed,
    );
  }

  // --- Reabrir tarea cerrada (`operations:work_orders:update`) ---

  void onReopenClick() {
    if (!_state.canReopen) return;
    _update(
      _state.copyWith(reopenForm: const ReopenTaskForm(), clearNotice: true, clearError: true),
    );
  }

  void onReopenDismiss() {
    if (_state.reopenForm == null) return;
    _update(_state.copyWith(clearReopenForm: true, clearError: true));
  }

  void onReopenReasonChange(String value) {
    final form = _state.reopenForm;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(reopenForm: form.copyWith(reason: value), clearError: true));
  }

  Future<void> onReopenConfirm() async {
    final form = _state.reopenForm;
    if (form == null || !_state.canReopenTask || _state.isBusy) return;
    _update(_state.copyWith(busyAction: TaskAction.reopen, clearError: true, clearNotice: true));
    try {
      final detail = await reopenTask.execute(taskId, reason: form.reason);
      await pausedElapsed.clear(taskId);
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearReopenForm: true,
          detail: detail,
          clearPausedElapsedSeconds: true,
          notice: UiText.resource((s) => s.tasksSeg2ReopenedNotice),
        ),
      );
    } on Object catch (e) {
      _fail(e);
    }
  }

  // --- US32 E2/E3: imputar un repuesto a la tarea ---

  void onChargeClick() {
    if (!_state.canOpenCharge) return;
    _update(
      _state.copyWith(
        chargeForm: const ChargeForm(),
        clearNotice: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  void onChargeDismiss() {
    _searchTimer?.cancel();
    if (_state.chargeForm == null) return;
    _update(_state.copyWith(clearChargeForm: true, clearError: true, clearInvalidField: true));
  }

  void _editCharge(ChargeForm Function(ChargeForm form) change) {
    final form = _state.chargeForm;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(chargeForm: change(form), clearError: true, clearInvalidField: true));
  }

  /// Busca en línea por nombre o SKU con debounce; un texto vacío limpia la lista.
  void onChargeQueryChange(String value) {
    _searchTimer?.cancel();
    if (value.trim().isEmpty) {
      _editCharge(
        (f) => f.copyWith(query: value, clearSelected: true, results: const [], isSearching: false),
      );
      return;
    }
    _editCharge((f) => f.copyWith(query: value, clearSelected: true));
    _searchTimer = Timer(searchDebounce, () async {
      _editCharge((f) => f.copyWith(isSearching: true));
      try {
        final parts = await searchParts.execute(value.trim());
        _editCharge((f) => f.copyWith(results: parts, isSearching: false));
      } on Object catch (e) {
        final form = _state.chargeForm;
        _update(
          _state.copyWith(
            chargeForm: form?.copyWith(isSearching: false),
            error: toTaskUiText(e),
          ),
        );
      }
    });
  }

  /// Un repuesto agotado no se puede elegir (US31 E3).
  void onPartSelect(PartOption part) {
    if (!part.isAvailable) return;
    _editCharge((f) => f.copyWith(selected: part));
  }

  void onChargeQuantityChange(String value) => _editCharge((f) => f.copyWith(quantity: value));

  Future<void> onChargeConfirm() async {
    final form = _state.chargeForm;
    final part = form?.selected;
    if (form == null || part == null || _state.isBusy) return;
    final quantity = _toAmount(form.quantity);
    if (quantity == null) {
      _fail(const InvalidTaskInputException('quantity'));
      return;
    }
    _update(_state.copyWith(busyAction: TaskAction.charge, clearError: true, clearInvalidField: true));
    try {
      // El descargo FIFO lo hace el backend; 409 con el message si pide más de lo que hay.
      await addPart.execute(taskId, part.id, quantity);
    } on Object catch (e) {
      _fail(e);
      return;
    }
    await _reloadDetail(UiText.resource((s) => s.taskPartCharged));
  }

  // --- US33: corregir la cantidad o devolver el repuesto al lote de origen ---

  void onEditPartClick(TaskProduct product) => _openPartEdit(product, PartEditMode.editQuantity);

  void onReturnPartClick(TaskProduct product) => _openPartEdit(product, PartEditMode.returnPart);

  void _openPartEdit(TaskProduct product, PartEditMode mode) {
    if (!_state.canEditParts || _state.isBusy) return;
    _update(
      _state.copyWith(
        partEdit: PartEditForm(product: product, mode: mode, quantity: product.quantity.formatQuantity()),
        clearNotice: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  void onPartEditDismiss() {
    if (_state.partEdit == null) return;
    _update(_state.copyWith(clearPartEdit: true, clearError: true, clearInvalidField: true));
  }

  void onPartQuantityChange(String value) {
    final edit = _state.partEdit;
    if (edit == null || _state.isBusy) return;
    _update(_state.copyWith(partEdit: edit.copyWith(quantity: value), clearError: true, clearInvalidField: true));
  }

  Future<void> onPartEditConfirm() async {
    final edit = _state.partEdit;
    if (edit == null || !_state.canEditParts || _state.isBusy) return;
    switch (edit.mode) {
      case PartEditMode.returnPart:
        _update(_state.copyWith(busyAction: TaskAction.removePart, clearError: true, clearInvalidField: true));
        try {
          // Las unidades vuelven al lote del que salieron y la orden rebaja el costo imputado.
          await removePart.execute(taskId, edit.product.productId);
        } on Object catch (e) {
          _fail(e);
          return;
        }
        await _reloadDetail(UiText.resource((s) => s.taskPartReturned));
      case PartEditMode.editQuantity:
        final quantity = _toAmount(edit.quantity);
        if (quantity == null) {
          _fail(const InvalidTaskInputException('quantity'));
          return;
        }
        _update(_state.copyWith(busyAction: TaskAction.editPart, clearError: true, clearInvalidField: true));
        try {
          final detail = await updatePartQuantity.execute(taskId, edit.product.productId, quantity);
          _update(
            _state.copyWith(
              clearBusyAction: true,
              clearPartEdit: true,
              detail: detail,
              notice: UiText.resource((s) => s.taskPartUpdated),
            ),
          );
        } on Object catch (e) {
          _fail(e);
        }
    }
  }

  /// Recarga el detalle tras imputar o devolver: esas respuestas no traen la tarea completa.
  Future<void> _reloadDetail(UiText notice) async {
    try {
      final detail = await getDetail.execute(taskId);
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearChargeForm: true,
          clearPartEdit: true,
          detail: detail,
          notice: notice,
        ),
      );
    } on Object catch (e) {
      // La operación se hizo: se cierra el formulario y se avisa que falta refrescar.
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearChargeForm: true,
          clearPartEdit: true,
          notice: notice,
          error: toTaskUiText(e),
        ),
      );
    }
  }

  Future<void> _run(
    TaskAction action,
    Future<TaskDetail> Function() call, {
    int? frozenAtPause,
  }) async {
    _update(
      _state.copyWith(busyAction: action, clearNotice: true, clearError: true, clearInvalidField: true),
    );
    try {
      final detail = await call();
      // Al pausar se guarda el tiempo efectivo; al reanudar se descarta.
      int? frozen;
      if (detail.status == TaskStatus.onHold) {
        frozen = frozenAtPause;
        if (frozen != null) await pausedElapsed.save(taskId, frozen);
      } else {
        await pausedElapsed.clear(taskId);
      }
      _update(
        _state.copyWith(
          clearBusyAction: true,
          detail: detail,
          notice: _noticeFor(action),
          clearNotice: _noticeFor(action) == null,
          pausedElapsedSeconds: frozen,
          clearPausedElapsedSeconds: frozen == null,
        ),
      );
    } on Object catch (e) {
      _fail(e);
    }
  }

  UiText? _noticeFor(TaskAction action) => switch (action) {
    TaskAction.start => UiText.resource((s) => s.taskStarted),
    TaskAction.pause => UiText.resource((s) => s.taskPaused),
    _ => null,
  };

  /// Acepta coma o punto decimal; `null` si no es un número.
  Decimal? _toAmount(String value) => Decimal.tryParse(value.trim().replaceAll(',', '.'));

  void _fail(Object error) {
    _update(
      _state.copyWith(
        clearBusyAction: true,
        error: toTaskUiText(error),
        invalidField: invalidTaskField(error),
        clearInvalidField: invalidTaskField(error) == null,
      ),
    );
  }

  void _update(TaskDetailUiState state) {
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
