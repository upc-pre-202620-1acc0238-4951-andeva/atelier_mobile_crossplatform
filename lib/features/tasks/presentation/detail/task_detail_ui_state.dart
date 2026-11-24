import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

/// Acción en línea en curso: bloquea el resto de botones mientras responde el backend.
/// Sin las de evidencia (US28), suspensión (US29) ni cierre (US30).
enum TaskAction { start, pause, charge, editPart, removePart, reopen }

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

class TaskDetailUiState {
  /// Tarea desde Drift: se muestra sin red.
  final Task? task;

  /// Detalle en línea: servicio y productos imputados.
  final TaskDetail? detail;
  final String fallbackWorkOrderId;
  final bool isLoading;
  final bool isOnline;
  final TaskAction? busyAction;
  final PauseForm? pauseForm;
  final ChargeForm? chargeForm;
  final PartEditForm? partEdit;
  final ReopenTaskForm? reopenForm;
  final UiText? notice;
  final UiText? error;

  /// Campo que no pasó la validación (`quantity`).
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
  });

  bool get isBusy => busyAction != null;

  bool get hasOpenSheet => pauseForm != null || chargeForm != null || partEdit != null || reopenForm != null;

  /// D3: los productos solo vienen de `GET /tasks/{id}`; sin ese detalle no se sabe qué repuestos hay.
  bool get partsAvailable => detail != null;

  // El detalle en línea manda sobre la caché una vez que llega o tras una acción.
  TaskStatus? get status => detail?.status ?? task?.status;
  HoldReason? get holdReason => detail != null ? detail!.holdReason : task?.holdReason;
  DateTime? get startedAt => detail?.startedAt ?? task?.startedAt;
  int get totalPausedSeconds => detail?.totalPausedSeconds ?? task?.totalPausedSeconds ?? 0;
  String get description => detail?.description ?? task?.description ?? '';
  List<TaskProduct> get products => detail?.products ?? const [];

  String? get plate => task?.plate;
  String? get vehicleId => task?.vehicleId;
  String get resolvedWorkOrderId => detail?.workOrderId ?? task?.workOrderId ?? fallbackWorkOrderId;

  String? get pendingSuspensionReason =>
      detail != null ? detail!.pendingSuspensionReason : task?.pendingSuspensionReason;
  DateTime? get pendingSuspensionRequestedAt =>
      detail?.pendingSuspensionRequestedAt ?? task?.pendingSuspensionRequestedAt;

  /// Solo informativo: la solicitud y su revisión (US29) no se construyen en el móvil.
  bool get hasPendingSuspension =>
      pendingSuspensionRequestedAt != null || (pendingSuspensionReason?.trim().isNotEmpty ?? false);

  bool get isPausedByMechanic => status == TaskStatus.onHold && holdReason?.isMechanicPause == true;
  bool get isSuspended => status == TaskStatus.onHold && holdReason != null && holdReason!.isMechanicPause == false;

  /// US27 E1 y E5: iniciar la faena asignada o reanudar una pausa propia.
  bool get canStart => canTrackTime && !isBusy && (status == TaskStatus.assigned || isPausedByMechanic);
  bool get canPause => canTrackTime && !isBusy && status == TaskStatus.inProgress;

  /// Imputar repuestos solo con la tarea abierta.
  bool get canOpenCharge =>
      canChargeParts &&
      partsAvailable &&
      !isBusy &&
      (status == TaskStatus.inProgress || status == TaskStatus.assigned || status == TaskStatus.onHold);

  /// Reabrir tarea cerrada (`operations:work_orders:update`).
  bool get canReopen => canReopenTask && !isBusy && status == TaskStatus.completed;

  /// Permisos de acción que esta pantalla ofrece (sin cierre, evidencia ni suspensión: US28–US30).
  bool get hasAnyActionPermission => canTrackTime || canChargeParts || canEditParts || canReopenTask;

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
    );
  }
}
