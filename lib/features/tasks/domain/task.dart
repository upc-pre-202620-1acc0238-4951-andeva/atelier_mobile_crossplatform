import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

class Task {
  final TaskId id;
  final String workOrderId;
  final int? workOrderNumber;
  final String? workOrderStatus;
  final String vehicleId;
  final String? plate;
  final String? branchId;
  final String? bayId;
  final String? bayName;
  final String? serviceName;
  final String? mechanicId;
  final TaskStatus? status;
  final String description;
  final double? estimatedHours;
  final HoldReason? holdReason;
  final String? missingItemDescription;
  final String? pendingSuspensionReason;
  final DateTime? startedAt;
  final int totalPausedSeconds;

  const Task({
    required this.id,
    required this.workOrderId,
    this.workOrderNumber,
    this.workOrderStatus,
    required this.vehicleId,
    this.plate,
    this.branchId,
    this.bayId,
    this.bayName,
    this.serviceName,
    this.mechanicId,
    this.status,
    required this.description,
    this.estimatedHours,
    this.holdReason,
    this.missingItemDescription,
    this.pendingSuspensionReason,
    this.startedAt,
    required this.totalPausedSeconds,
  });

  bool get isPausedByMechanic =>
      status == TaskStatus.onHold && holdReason?.isMechanicPause == true;

  bool get isSuspended =>
      status == TaskStatus.onHold &&
      holdReason != null &&
      !holdReason!.isMechanicPause;

  bool get hasPendingSuspension => pendingSuspensionReason != null;
}
