import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

class AssignedTaskDto {
  final String taskId;
  final String workOrderId;
  final int? workOrderNumber;
  final String? workOrderStatus;
  final String vehicleId;
  final String? branchId;
  final String? bayId;
  final String? status;
  final String? description;
  final Decimal? estimatedHours;
  final String? startedAt;
  final int? totalPausedSeconds;

  const AssignedTaskDto({
    required this.taskId,
    required this.workOrderId,
    this.workOrderNumber,
    this.workOrderStatus,
    required this.vehicleId,
    this.branchId,
    this.bayId,
    this.status,
    this.description,
    this.estimatedHours,
    this.startedAt,
    this.totalPausedSeconds,
  });

  factory AssignedTaskDto.fromJson(Map<String, dynamic> json) {
    return AssignedTaskDto(
      taskId: json['taskId'] as String,
      workOrderId: json['workOrderId'] as String,
      workOrderNumber: (json['workOrderNumber'] as num?)?.toInt(),
      workOrderStatus: json['workOrderStatus'] as String?,
      vehicleId: json['vehicleId'] as String,
      branchId: json['branchId'] as String?,
      bayId: json['bayId'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      estimatedHours: decimalFromJson(json['estimatedHours']),
      startedAt: json['startedAt'] as String?,
      totalPausedSeconds: (json['totalPausedSeconds'] as num?)?.toInt(),
    );
  }
}
