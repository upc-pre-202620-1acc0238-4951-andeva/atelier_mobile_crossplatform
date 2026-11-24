import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Texto del estado de la orden (equivale a `WorkOrderStatus?.labelRes()` de Android).
String workOrderStatusLabel(AppLocalizations strings, WorkOrderStatus? status) => switch (status) {
  WorkOrderStatus.draft => strings.orderStatusDraft,
  WorkOrderStatus.inProgress => strings.orderStatusInProgress,
  WorkOrderStatus.completed => strings.orderStatusCompleted,
  WorkOrderStatus.paid => strings.orderStatusPaid,
  WorkOrderStatus.canceled => strings.orderStatusCanceled,
  null => strings.orderStatusUnknown,
};

ChipKind workOrderStatusChipKind(WorkOrderStatus? status) => switch (status) {
  WorkOrderStatus.inProgress => ChipKind.info,
  WorkOrderStatus.completed || WorkOrderStatus.paid => ChipKind.ok,
  WorkOrderStatus.canceled => ChipKind.bad,
  WorkOrderStatus.draft || null => ChipKind.idle,
};

/// Texto del estado de una tarea; una pausa por repuesto se muestra como suspendida (solo el estado: la
/// solicitud y la aprobación de la suspensión son US29).
String taskStatusLabel(AppLocalizations strings, TaskStatus? status, HoldReason? holdReason) {
  return switch (status) {
    TaskStatus.inProgress => strings.taskStatusInProgress,
    TaskStatus.onHold =>
      holdReason != null && !holdReason.isMechanicPause
          ? strings.taskStatusSuspended
          : strings.taskStatusOnHold,
    TaskStatus.assigned => strings.taskStatusAssigned,
    TaskStatus.completed => strings.taskStatusCompleted,
    TaskStatus.cancelled => strings.taskStatusCancelled,
    TaskStatus.pending || null => strings.taskStatusPending,
  };
}

ChipKind taskStatusChipKind(TaskStatus? status, HoldReason? holdReason) {
  return switch (status) {
    TaskStatus.inProgress => ChipKind.info,
    TaskStatus.onHold =>
      holdReason != null && !holdReason.isMechanicPause ? ChipKind.bad : ChipKind.wait,
    TaskStatus.completed => ChipKind.ok,
    _ => ChipKind.idle,
  };
}

/// Campo que `WorkOrderValidation` rechazó antes de llamar al backend, para marcarlo en el formulario.
String? invalidWorkOrderField(Object error) {
  if (error is InvalidWorkOrderInputException) return error.field;
  return null;
}

/// Dato inválido: aviso genérico (el campo se marca aparte); el resto muestra el `message` del backend.
UiText toWorkOrderUiText(Object error) {
  if (error is InvalidWorkOrderInputException) {
    return UiText.resource((s) => s.workorderInvalidInput);
  }
  return toUiText(error);
}

/// Igual que [invalidWorkOrderField] para los datos de una tarea (cantidad de un repuesto).
String? invalidTaskField(Object error) {
  if (error is InvalidTaskInputException) return error.field;
  return null;
}

/// Igual que [toWorkOrderUiText] para las acciones de repuestos de una tarea.
UiText toTaskUiText(Object error) {
  if (error is InvalidTaskInputException) {
    return UiText.resource((s) => s.taskInvalidInput);
  }
  return toUiText(error);
}
