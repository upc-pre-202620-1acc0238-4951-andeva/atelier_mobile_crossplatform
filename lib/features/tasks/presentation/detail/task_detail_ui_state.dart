import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

/// Acción en curso: bloquea el resto de botones mientras responde el backend (o se guarda la foto).
enum TaskAction {
  start,
  pause,
  charge,
  editPart,
  removePart,
  reopen,
  complete,
  requestSuspension,
  approveSuspension,
  rejectSuspension,
  resumeSuspended,
  attachEvidence,
}

/// US27 E2: hoja para tipificar la pausa.
class PauseForm {
  const PauseForm();
}

/// US32 E2: buscar el repuesto, elegirlo y fijar la cantidad a imputar a la tarea.
class ChargeForm {
  final String query;
  final List<PartOption> results;
  final bool isSearching;
  final PartOption? selected;
  final String quantity;

  const ChargeForm({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.selected,
    this.quantity = '1',
  });

  ChargeForm copyWith({
    String? query,
    List<PartOption>? results,
    bool? isSearching,
    PartOption? selected,
    bool clearSelected = false,
    String? quantity,
  }) {
    return ChargeForm(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      selected: clearSelected ? null : selected ?? this.selected,
      quantity: quantity ?? this.quantity,
    );
  }
}

enum PartEditMode { editQuantity, returnPart }

/// US33: cambiar la cantidad de un repuesto imputado o devolverlo a su lote de origen.
class PartEditForm {
  final TaskProduct product;
  final PartEditMode mode;
  final String quantity;

  const PartEditForm({required this.product, required this.mode, required this.quantity});

  PartEditForm copyWith({String? quantity}) =>
      PartEditForm(product: product, mode: mode, quantity: quantity ?? this.quantity);
}

/// Reapertura de tarea cerrada para retrabajo de calidad (`operations:work_orders:update`).
class ReopenTaskForm {
  final String reason;

  const ReopenTaskForm({this.reason = ''});

  ReopenTaskForm copyWith({String? reason}) => ReopenTaskForm(reason: reason ?? this.reason);
}

/// US30 E1: horas hombre efectivas (precargadas desde el cronómetro y editables) y notas.
class CompleteTaskForm {
  final String hours;
  final String notes;

  const CompleteTaskForm({this.hours = '', this.notes = ''});

  CompleteTaskForm copyWith({String? hours, String? notes}) =>
      CompleteTaskForm(hours: hours ?? this.hours, notes: notes ?? this.notes);
}

/// US29 E1: motivo obligatorio y repuesto del catálogo opcional.
class RequestSuspensionForm {
  final String missingItemDescription;
  final String partQuery;
  final List<PartOption> partResults;
  final bool isSearching;
  final PartOption? selectedPart;

  const RequestSuspensionForm({
    this.missingItemDescription = '',
    this.partQuery = '',
    this.partResults = const [],
    this.isSearching = false,
    this.selectedPart,
  });

  String? get inventoryItemId => selectedPart?.id;

  RequestSuspensionForm copyWith({
    String? missingItemDescription,
    String? partQuery,
    List<PartOption>? partResults,
    bool? isSearching,
    PartOption? selectedPart,
    bool clearSelectedPart = false,
  }) {
    return RequestSuspensionForm(
      missingItemDescription: missingItemDescription ?? this.missingItemDescription,
      partQuery: partQuery ?? this.partQuery,
      partResults: partResults ?? this.partResults,
      isSearching: isSearching ?? this.isSearching,
      selectedPart: clearSelectedPart ? null : selectedPart ?? this.selectedPart,
    );
  }
}

/// US29 E1/E2: el supervisor aprueba o desestima la solicitud pendiente.
class ReviewSuspensionForm {
  const ReviewSuspensionForm();
}

/// US29 E3: confirmación para levantar la suspensión.
class ResumeSuspensionForm {
  const ResumeSuspensionForm();
}

/// US28: tipo de foto y nota antes de abrir la cámara o la galería.
class EvidenceCaptureForm {
  final EvidenceKind kind;
  final String note;

  const EvidenceCaptureForm({this.kind = EvidenceKind.disassembly, this.note = ''});

  EvidenceCaptureForm copyWith({EvidenceKind? kind, String? note}) =>
      EvidenceCaptureForm(kind: kind ?? this.kind, note: note ?? this.note);
}

class TaskDetailUiState {
  /// Tarea desde Drift: se muestra sin red.
  final Task? task;

  /// Detalle en línea: servicio, productos imputados y evidencias.
  final TaskDetail? detail;
  final String fallbackWorkOrderId;
  final bool isLoading;
  final bool isOnline;
  final TaskAction? busyAction;
  final PauseForm? pauseForm;
  final ChargeForm? chargeForm;
  final PartEditForm? partEdit;
  final ReopenTaskForm? reopenForm;
  final CompleteTaskForm? completeForm;
  final RequestSuspensionForm? suspensionForm;
  final ReviewSuspensionForm? reviewForm;
  final ResumeSuspensionForm? resumeForm;
  final EvidenceCaptureForm? evidenceForm;

  /// US28: fotos en cola de esta tarea; se ven sin red.
  final List<PendingEvidence> pendingEvidence;
  final UiText? notice;
  final UiText? error;

  /// Campo que no pasó la validación (`quantity`, `actualLaborHours`, `notes`, `missingItemDescription`,
  /// `description`).
  final String? invalidField;

  /// D1: tiempo efectivo al pausar, guardado en este teléfono. `null` si la pausa no la hizo esta app (el backend
  /// no envía la hora de la pausa), y el cronómetro no inventa un valor.
  final int? pausedElapsedSeconds;
  final bool canTrackTime;
  final bool canChargeParts;
  final bool canEditParts;
  final bool canReportFinding;
  final bool canOpenObd;
  final bool canReopenTask;
  final bool canCompleteTask;
  final bool canUploadPhotos;
  final bool canRequestSuspensionPermission;
  final bool canValidateSuspension;

  const TaskDetailUiState({
    this.task,
    this.detail,
    this.fallbackWorkOrderId = '',
    this.isLoading = true,
    this.isOnline = true,
    this.busyAction,
    this.pauseForm,
    this.chargeForm,
    this.partEdit,
    this.reopenForm,
    this.completeForm,
    this.suspensionForm,
    this.reviewForm,
    this.resumeForm,
    this.evidenceForm,
    this.pendingEvidence = const [],
    this.notice,
    this.error,
    this.invalidField,
    this.pausedElapsedSeconds,
    this.canTrackTime = false,
    this.canChargeParts = false,
    this.canEditParts = false,
    this.canReportFinding = false,
    this.canOpenObd = false,
    this.canReopenTask = false,
    this.canCompleteTask = false,
    this.canUploadPhotos = false,
    this.canRequestSuspensionPermission = false,
    this.canValidateSuspension = false,
  });

  bool get isBusy => busyAction != null;

  bool get hasOpenSheet =>
      pauseForm != null ||
      chargeForm != null ||
      partEdit != null ||
      reopenForm != null ||
      completeForm != null ||
      suspensionForm != null ||
      reviewForm != null ||
      resumeForm != null ||
      evidenceForm != null;

  /// D3: los productos solo vienen de `GET /tasks/{id}`; sin ese detalle no se sabe qué repuestos hay.
  bool get partsAvailable => detail != null;

  // El detalle en línea manda sobre la caché una vez que llega o tras una acción.
  TaskStatus? get status => detail?.status ?? task?.status;
  HoldReason? get holdReason => detail != null ? detail!.holdReason : task?.holdReason;
  DateTime? get startedAt => detail?.startedAt ?? task?.startedAt;
  int get totalPausedSeconds => detail?.totalPausedSeconds ?? task?.totalPausedSeconds ?? 0;
  String get description => detail?.description ?? task?.description ?? '';
  List<TaskProduct> get products => detail?.products ?? const [];
  List<TaskEvidence> get evidenceImages => detail?.evidenceImages ?? const [];

  String? get plate => task?.plate;
  String? get vehicleId => task?.vehicleId;
  String get resolvedWorkOrderId => detail?.workOrderId ?? task?.workOrderId ?? fallbackWorkOrderId;

  String? get pendingSuspensionReason =>
      detail != null ? detail!.pendingSuspensionReason : task?.pendingSuspensionReason;
  DateTime? get pendingSuspensionRequestedAt =>
      detail != null ? detail!.pendingSuspensionRequestedAt : task?.pendingSuspensionRequestedAt;

  bool get hasPendingSuspension =>
      pendingSuspensionRequestedAt != null || (pendingSuspensionReason?.trim().isNotEmpty ?? false);

  bool get isPausedByMechanic => status == TaskStatus.onHold && holdReason?.isMechanicPause == true;
  bool get isSuspended => status == TaskStatus.onHold && holdReason != null && holdReason!.isMechanicPause == false;

  bool get isOpenTask =>
      status == TaskStatus.inProgress || status == TaskStatus.assigned || status == TaskStatus.onHold;

  /// US27 E1 y E5: iniciar la faena asignada o reanudar una pausa propia.
  bool get canStart => canTrackTime && !isBusy && (status == TaskStatus.assigned || isPausedByMechanic);
  bool get canPause => canTrackTime && !isBusy && status == TaskStatus.inProgress;

  /// US30 E1: se cierra una tarea en curso o en una pausa propia; nunca sin iniciar ni suspendida por repuesto.
  bool get showComplete => canCompleteTask && (status == TaskStatus.inProgress || isPausedByMechanic);
  bool get canComplete => showComplete && !isBusy;

  /// US29 E1: pedir la suspensión de una tarea en curso sin otra solicitud pendiente.
  bool get showRequestSuspension =>
      canRequestSuspensionPermission && status == TaskStatus.inProgress && !hasPendingSuspension;

  /// US29 E1/E2: aprobar o desestimar.
  bool get showReviewSuspension => canValidateSuspension && hasPendingSuspension;

  /// US29 E3 (H6): solo quien valida suspensiones puede levantarlas.
  bool get showResumeSuspended => canValidateSuspension && isSuspended;

  /// US28: funciona sin red; solo con la tarea abierta.
  bool get canAddEvidence => canUploadPhotos && isOpenTask && resolvedWorkOrderId.trim().isNotEmpty;

  /// Imputar repuestos solo con la tarea abierta.
  bool get canOpenCharge => canChargeParts && partsAvailable && !isBusy && isOpenTask;

  /// Reabrir tarea cerrada (`operations:work_orders:update`).
  bool get canReopen => canReopenTask && !isBusy && status == TaskStatus.completed;

  /// Permisos de acción que esta pantalla ofrece.
  bool get hasAnyActionPermission =>
      canTrackTime ||
      canChargeParts ||
      canEditParts ||
      canReopenTask ||
      canCompleteTask ||
      canUploadPhotos ||
      canRequestSuspensionPermission ||
      canValidateSuspension;

  TaskDetailUiState copyWith({
    Task? task,
    TaskDetail? detail,
    bool? isLoading,
    bool? isOnline,
    TaskAction? busyAction,
    bool clearBusyAction = false,
    PauseForm? pauseForm,
    bool clearPauseForm = false,
    ChargeForm? chargeForm,
    bool clearChargeForm = false,
    PartEditForm? partEdit,
    bool clearPartEdit = false,
    ReopenTaskForm? reopenForm,
    bool clearReopenForm = false,
    CompleteTaskForm? completeForm,
    bool clearCompleteForm = false,
    RequestSuspensionForm? suspensionForm,
    bool clearSuspensionForm = false,
    ReviewSuspensionForm? reviewForm,
    bool clearReviewForm = false,
    ResumeSuspensionForm? resumeForm,
    bool clearResumeForm = false,
    EvidenceCaptureForm? evidenceForm,
    bool clearEvidenceForm = false,
    List<PendingEvidence>? pendingEvidence,
    UiText? notice,
    bool clearNotice = false,
    UiText? error,
    bool clearError = false,
    String? invalidField,
    bool clearInvalidField = false,
    int? pausedElapsedSeconds,
    bool clearPausedElapsedSeconds = false,
    bool? canTrackTime,
    bool? canChargeParts,
    bool? canEditParts,
    bool? canReportFinding,
    bool? canOpenObd,
    bool? canReopenTask,
    bool? canCompleteTask,
    bool? canUploadPhotos,
    bool? canRequestSuspensionPermission,
    bool? canValidateSuspension,
  }) {
    return TaskDetailUiState(
      task: task ?? this.task,
      detail: detail ?? this.detail,
      fallbackWorkOrderId: fallbackWorkOrderId,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      busyAction: clearBusyAction ? null : busyAction ?? this.busyAction,
      pauseForm: clearPauseForm ? null : pauseForm ?? this.pauseForm,
      chargeForm: clearChargeForm ? null : chargeForm ?? this.chargeForm,
      partEdit: clearPartEdit ? null : partEdit ?? this.partEdit,
      reopenForm: clearReopenForm ? null : reopenForm ?? this.reopenForm,
      completeForm: clearCompleteForm ? null : completeForm ?? this.completeForm,
      suspensionForm: clearSuspensionForm ? null : suspensionForm ?? this.suspensionForm,
      reviewForm: clearReviewForm ? null : reviewForm ?? this.reviewForm,
      resumeForm: clearResumeForm ? null : resumeForm ?? this.resumeForm,
      evidenceForm: clearEvidenceForm ? null : evidenceForm ?? this.evidenceForm,
      pendingEvidence: pendingEvidence ?? this.pendingEvidence,
      notice: clearNotice ? null : notice ?? this.notice,
      error: clearError ? null : error ?? this.error,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
      pausedElapsedSeconds: clearPausedElapsedSeconds ? null : pausedElapsedSeconds ?? this.pausedElapsedSeconds,
      canTrackTime: canTrackTime ?? this.canTrackTime,
      canChargeParts: canChargeParts ?? this.canChargeParts,
      canEditParts: canEditParts ?? this.canEditParts,
      canReportFinding: canReportFinding ?? this.canReportFinding,
      canOpenObd: canOpenObd ?? this.canOpenObd,
      canReopenTask: canReopenTask ?? this.canReopenTask,
      canCompleteTask: canCompleteTask ?? this.canCompleteTask,
      canUploadPhotos: canUploadPhotos ?? this.canUploadPhotos,
      canRequestSuspensionPermission: canRequestSuspensionPermission ?? this.canRequestSuspensionPermission,
      canValidateSuspension: canValidateSuspension ?? this.canValidateSuspension,
    );
  }
}
