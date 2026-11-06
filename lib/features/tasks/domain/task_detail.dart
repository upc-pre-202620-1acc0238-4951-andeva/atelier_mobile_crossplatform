import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

class TaskDetail {
  final TaskId id;
  final String workOrderId;
  final String? serviceId;
  final String? serviceName;
  final String? mechanicId;
  final String? mechanicName;
  final TaskStatus? status;
  final String description;
  final Money? price;
  final String? currency;
  final HoldReason? holdReason;
  final String? missingItemDescription;
  final int totalPausedSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? pendingSuspensionReason;
  final DateTime? pendingSuspensionRequestedAt;
  final List<TaskProduct> products;
  final List<TaskEvidence> evidenceImages;

  const TaskDetail({
    required this.id,
    required this.workOrderId,
    this.serviceId,
    this.serviceName,
    this.mechanicId,
    this.mechanicName,
    this.status,
    required this.description,
    this.price,
    this.currency,
    this.holdReason,
    this.missingItemDescription,
    required this.totalPausedSeconds,
    this.startedAt,
    this.completedAt,
    this.pendingSuspensionReason,
    this.pendingSuspensionRequestedAt,
    this.products = const [],
    this.evidenceImages = const [],
  });

  bool get isPausedByMechanic =>
      status == TaskStatus.onHold && holdReason?.isMechanicPause == true;

  bool get isSuspended =>
      status == TaskStatus.onHold &&
      holdReason != null &&
      !holdReason!.isMechanicPause;

  bool get hasPendingSuspension => pendingSuspensionReason != null;
}
