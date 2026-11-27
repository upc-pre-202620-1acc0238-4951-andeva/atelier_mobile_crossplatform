import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/discard_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/retry_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reopen_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/task_errors.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// US27, US23, US33: detalle de tarea con cronómetro tabular, pausa tipificada, reapertura y gestión FIFO de
/// repuestos. US28: evidencia fotográfica (funciona sin red). US29: suspensión por pieza. US30: cierre con horas
/// hombre.
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
  final SuggestLaborHoursUseCase suggestLaborHours;
  final CompleteTaskUseCase completeTask;
  final AttachTaskEvidenceUseCase attachTaskEvidence;
  final ObservePendingEvidenceUseCase observePendingEvidence;
  final RequestSuspensionUseCase requestSuspension;
  final ApproveSuspensionUseCase approveSuspension;
  final RejectSuspensionUseCase rejectSuspension;
  final ResumeSuspendedTaskUseCase resumeSuspendedTask;
  final RetryPendingOperationUseCase? retryPendingOperation;
  final DiscardPendingOperationUseCase? discardPendingOperation;
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
    required this.suggestLaborHours,
    required this.completeTask,
    required this.attachTaskEvidence,
    required this.observePendingEvidence,
    required this.requestSuspension,
    required this.approveSuspension,
    required this.rejectSuspension,
    required this.resumeSuspendedTask,
    this.retryPendingOperation,
    this.discardPendingOperation,
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
            canCompleteTask: session?.has(Permission.tasksComplete) == true,
            canUploadPhotos: session?.has(Permission.tasksUploadPhotos) == true,
            canRequestSuspensionPermission: session?.has(Permission.tasksHoldRequest) == true,
            canValidateSuspension: session?.has(Permission.tasksHoldValidate) == true,
          ),
        );
      }),
    );
    _subscriptions.add(observeTask.execute(taskId).listen((task) => _update(_state.copyWith(task: task))));
    _subscriptions.add(observePendingEvidence.execute(taskId).listen(_onPendingEvidence));
    connectivity.addListener(_onConnectivity);
    load();
  }

  late TaskDetailUiState _state;
  TaskDetailUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _searchTimer;
  bool _disposed = false;

  /// Una foto salió de la cola y falta traer la confirmada por el servidor.
  bool _evidenceStale = false;

  /// D3: si la pantalla se abrió sin red, al volver la conexión se carga el detalle (repuestos incluidos).
  void _onConnectivity() {
    final online = connectivity.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (online && (_state.detail == null || _evidenceStale) && !_state.isLoading) load();
  }

  /// US28: cuando una foto deja la cola (ya se registró en el backend) se recarga el detalle para mostrarla.
  void _onPendingEvidence(List<PendingEvidence> evidence) {
    final current = {for (final item in evidence) item.operationId};
    final someLeft = _state.pendingEvidence.any((item) => !current.contains(item.operationId));
    _update(_state.copyWith(pendingEvidence: evidence));
    if (!someLeft) return;
    _evidenceStale = true;
    if (_state.isOnline && !_state.isLoading) load();
  }

  /// `GET /tasks/{id}`: servicio y repuestos imputados. Sin red se sigue con la caché.
  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final detail = await getDetail.execute(taskId);
      _evidenceStale = false;
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

  // --- US30: cierre técnico con horas hombre ---

  void onCompleteClick() {
    if (!_state.canComplete) return;
    _update(
      _state.copyWith(
        completeForm: CompleteTaskForm(hours: _suggestedHours()?.toString() ?? ''),
        clearNotice: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  /// H3: en curso, `ahora − startedAt − totalPausedSeconds`. En pausa ese cálculo sumaría la pausa abierta, así
  /// que solo se sugiere el tiempo guardado al pausar; sin él, el mecánico escribe las horas.
  Decimal? _suggestedHours() {
    var startedAt = _state.startedAt;
    var pausedSeconds = _state.totalPausedSeconds;
    if (_state.status == TaskStatus.onHold) {
      final frozen = _state.pausedElapsedSeconds;
      if (frozen == null) return null;
      startedAt = suggestLaborHours.now().subtract(Duration(seconds: frozen));
      pausedSeconds = 0;
    }
    return suggestLaborHours.execute(
      Task(
        id: taskId,
        workOrderId: _state.resolvedWorkOrderId,
        vehicleId: _state.vehicleId ?? '',
        description: _state.description,
        startedAt: startedAt,
        totalPausedSeconds: pausedSeconds,
      ),
    );
  }

  void onCompleteDismiss() {
    if (_state.completeForm == null) return;
    _update(_state.copyWith(clearCompleteForm: true, clearError: true, clearInvalidField: true));
  }

  void onCompleteHoursChange(String value) => _editComplete((f) => f.copyWith(hours: value));

  void onCompleteNotesChange(String value) => _editComplete((f) => f.copyWith(notes: value));

  void _editComplete(CompleteTaskForm Function(CompleteTaskForm form) change) {
    final form = _state.completeForm;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(completeForm: change(form), clearError: true, clearInvalidField: true));
  }

  Future<void> onCompleteConfirm() async {
    final form = _state.completeForm;
    if (form == null || !_state.canComplete) return;
    // US30: con permiso de fotos, el cierre exige al menos una foto de Montaje.
    if (_state.requiresAssemblyEvidence) {
      _update(_state.copyWith(error: UiText.resource((s) => s.tasksSeg2CompleteMissingAssemblyWarning)));
      return;
    }
    final hours = _toAmount(form.hours);
    if (hours == null) {
      _fail(const InvalidTaskInputException('actualLaborHours'));
      return;
    }
    _startAction(TaskAction.complete);
    try {
      final detail = await completeTask.execute(taskId, hours, notes: form.notes);
      await pausedElapsed.clear(taskId);
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearCompleteForm: true,
          detail: detail,
          clearPausedElapsedSeconds: true,
          notice: UiText.resource((s) => s.taskCompletedNotice),
        ),
      );
    } on Object catch (e) {
      _fail(e);
    }
  }

  // --- US29: suspensión por pieza defectuosa ---

  void onRequestSuspensionClick() {
    if (!_state.showRequestSuspension || _state.isBusy) return;
    _update(
      _state.copyWith(
        suspensionForm: const RequestSuspensionForm(),
        clearNotice: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  void onRequestSuspensionDismiss() {
    _searchTimer?.cancel();
    if (_state.suspensionForm == null) return;
    _update(_state.copyWith(clearSuspensionForm: true, clearError: true, clearInvalidField: true));
  }

  void onSuspensionDescriptionChange(String value) =>
      _editSuspension((f) => f.copyWith(missingItemDescription: value));

  void _editSuspension(RequestSuspensionForm Function(RequestSuspensionForm form) change) {
    final form = _state.suspensionForm;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(suspensionForm: change(form), clearError: true, clearInvalidField: true));
  }

  /// Repuesto opcional del catálogo: misma búsqueda en línea que al imputar.
  void onSuspensionPartQueryChange(String value) {
    _searchTimer?.cancel();
    if (value.trim().isEmpty) {
      _editSuspension((f) => f.copyWith(partQuery: value, partResults: const [], isSearching: false));
      return;
    }
    _editSuspension((f) => f.copyWith(partQuery: value));
    _searchTimer = Timer(searchDebounce, () async {
      _editSuspension((f) => f.copyWith(isSearching: true));
      try {
        final parts = await searchParts.execute(value.trim());
        _editSuspension((f) => f.copyWith(partResults: parts, isSearching: false));
      } on Object catch (e) {
        final form = _state.suspensionForm;
        _update(
          _state.copyWith(suspensionForm: form?.copyWith(isSearching: false), error: toTaskUiText(e)),
        );
      }
    });
  }

  /// Se admite un repuesto agotado: justamente puede ser el que falta.
  void onSuspensionPartSelect(PartOption part) => _editSuspension((f) => f.copyWith(selectedPart: part));

  void onSuspensionPartClear() => _editSuspension((f) => f.copyWith(clearSelectedPart: true));

  Future<void> onRequestSuspensionConfirm() async {
    final form = _state.suspensionForm;
    if (form == null || !_state.showRequestSuspension || _state.isBusy) return;
    await _runSuspension(
      TaskAction.requestSuspension,
      () => requestSuspension.execute(
        taskId,
        form.missingItemDescription,
        inventoryItemId: form.inventoryItemId,
      ),
      UiText.resource((s) => s.tasksSeg2SuspensionRequestedNotice),
    );
  }

  void onReviewSuspensionClick() {
    if (!_state.showReviewSuspension || _state.isBusy) return;
    _update(
      _state.copyWith(reviewForm: const ReviewSuspensionForm(), clearNotice: true, clearError: true),
    );
  }

  void onReviewSuspensionDismiss() {
    if (_state.reviewForm == null) return;
    _update(_state.copyWith(clearReviewForm: true, clearError: true));
  }

  Future<void> onApproveSuspension() async {
    if (!_state.showReviewSuspension || _state.isBusy) return;
    await _runSuspension(
      TaskAction.approveSuspension,
      () => approveSuspension.execute(taskId),
      UiText.resource((s) => s.ordersSuspensionApprovedNotice),
    );
  }

  Future<void> onRejectSuspension() async {
    if (!_state.showReviewSuspension || _state.isBusy) return;
    await _runSuspension(
      TaskAction.rejectSuspension,
      () => rejectSuspension.execute(taskId),
      UiText.resource((s) => s.ordersSuspensionRejectedNotice),
    );
  }

  void onResumeSuspendedClick() {
    if (!_state.showResumeSuspended || _state.isBusy) return;
    _update(
      _state.copyWith(resumeForm: const ResumeSuspensionForm(), clearNotice: true, clearError: true),
    );
  }

  void onResumeSuspendedDismiss() {
    if (_state.resumeForm == null) return;
    _update(_state.copyWith(clearResumeForm: true, clearError: true));
  }

  Future<void> onResumeSuspendedConfirm() async {
    if (!_state.showResumeSuspended || _state.isBusy) return;
    await _runSuspension(
      TaskAction.resumeSuspended,
      () => resumeSuspendedTask.execute(taskId),
      UiText.resource((s) => s.ordersTaskResumedNotice),
    );
  }

  /// Las cuatro acciones de US29 devuelven la tarea: si salen bien se cierra su hoja y se muestra el estado nuevo.
  Future<void> _runSuspension(
    TaskAction action,
    Future<TaskDetail> Function() call,
    UiText notice,
  ) async {
    _startAction(action);
    try {
      final detail = await call();
      _searchTimer?.cancel();
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearSuspensionForm: true,
          clearReviewForm: true,
          clearResumeForm: true,
          detail: detail,
          notice: notice,
        ),
      );
      await _syncPausedElapsed();
    } on Object catch (e) {
      _fail(e);
    }
  }

  // --- US28: evidencia fotográfica ---

  void onEvidenceKindChange(EvidenceKind kind) =>
      _update(_state.copyWith(evidenceKind: kind, clearError: true, clearInvalidField: true));

  void onEvidenceNoteChange(String value) =>
      _update(_state.copyWith(evidenceNote: value, clearError: true, clearInvalidField: true));

  void onCameraDenied() {
    _update(_state.copyWith(error: UiText.resource((s) => s.galleryCameraDenied), clearNotice: true));
  }

  /// No exige conexión: la foto se encola y se sube cuando haya señal.
  Future<void> onEvidenceCaptured(File photo) async {
    if (!_state.canUploadPhotos || _state.isBusy) return;
    final state = _state;
    _startAction(TaskAction.attachEvidence);
    try {
      await attachTaskEvidence.execute(
        taskId,
        state.resolvedWorkOrderId,
        photo,
        state.evidenceKind,
        note: state.evidenceNote,
      );
      _update(
        _state.copyWith(
          clearBusyAction: true,
          evidenceNote: '',
          notice: UiText.resource((s) => s.tasksSeg2EvidenceQueued),
        ),
      );
    } on Object catch (e) {
      _fail(e);
    }
  }

  /// Una foto que falló al subir: se abre la hoja para reintentar o descartar.
  void onSelectFailedEvidence(PendingEvidence pending) =>
      _update(_state.copyWith(selectedFailedEvidence: pending, clearError: true, clearNotice: true));

  void onDismissFailedEvidence() => _update(_state.copyWith(clearSelectedFailedEvidence: true));

  Future<void> onRetryFailedEvidence() async {
    final pending = _state.selectedFailedEvidence;
    if (pending == null) return;
    _update(_state.copyWith(clearSelectedFailedEvidence: true));
    await retryPendingOperation?.execute(pending.operationId);
    _update(_state.copyWith(notice: UiText.resource((s) => s.tasksSeg2EvidenceFailedRetryNotice)));
  }

  Future<void> onDiscardFailedEvidence() async {
    final pending = _state.selectedFailedEvidence;
    if (pending == null) return;
    _update(_state.copyWith(clearSelectedFailedEvidence: true));
    await discardPendingOperation?.execute(pending.operationId);
    _update(_state.copyWith(notice: UiText.resource((s) => s.tasksSeg2EvidenceFailedDiscardNotice)));
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

  void _startAction(TaskAction action) {
    _update(
      _state.copyWith(busyAction: action, clearNotice: true, clearError: true, clearInvalidField: true),
    );
  }

  Future<void> _run(
    TaskAction action,
    Future<TaskDetail> Function() call, {
    int? frozenAtPause,
  }) async {
    _startAction(action);
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
