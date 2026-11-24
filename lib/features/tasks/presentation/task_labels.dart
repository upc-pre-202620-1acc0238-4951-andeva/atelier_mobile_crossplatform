import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

bool _isSuspension(HoldReason? holdReason) => holdReason != null && !holdReason.isMechanicPause;

/// Texto del estado; una pausa por repuesto se muestra como suspendida.
String taskStatusLabel(AppLocalizations strings, TaskStatus? status, HoldReason? holdReason) {
  return switch (status) {
    TaskStatus.inProgress => strings.taskStatusInProgress,
    TaskStatus.onHold => _isSuspension(holdReason) ? strings.taskStatusSuspended : strings.taskStatusOnHold,
    TaskStatus.assigned => strings.taskStatusAssigned,
    TaskStatus.completed => strings.taskStatusCompleted,
    TaskStatus.cancelled => strings.taskStatusCancelled,
    TaskStatus.pending || null => strings.taskStatusPending,
  };
}

ChipKind taskStatusChipKind(TaskStatus? status, HoldReason? holdReason) {
  return switch (status) {
    TaskStatus.inProgress => ChipKind.info,
    TaskStatus.onHold => _isSuspension(holdReason) ? ChipKind.bad : ChipKind.wait,
    TaskStatus.completed => ChipKind.ok,
    _ => ChipKind.idle,
  };
}
