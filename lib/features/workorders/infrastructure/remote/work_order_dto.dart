import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:decimal/decimal.dart';

/// `WorkOrderSummaryResource` (lista), `WorkOrderResource` (acciones) y `WorkOrderDetailResource`
/// (detalle) de docs/api/operations.md en un solo DTO: lo que una respuesta no trae llega en `null`.
class WorkOrderDto {
  final String id;
  final int? internalNumber;
  final String vehicleId;
  final String customerId;
  final String branchId;
  final String? currentBayId;
  final String? bayName;
  final int? mileageIn;
  final String? diagnosticSummary;
  final String? status;
  final Decimal? subtotal;
  final Decimal? taxAmount;
  final Decimal? totalAmount;
  final String? currency;
  final List<WorkOrderTaskDto>? tasks;
  final List<TaskProposalDto>? proposals;
  final List<WorkOrderImageDto>? intakeImages;
  final String? createdAt;
  final String? updatedAt;

  const WorkOrderDto({
    required this.id,
    this.internalNumber,
    required this.vehicleId,
    required this.customerId,
    required this.branchId,
    this.currentBayId,
    this.bayName,
    this.mileageIn,
    this.diagnosticSummary,
    this.status,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.currency,
    this.tasks,
    this.proposals,
    this.intakeImages,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkOrderDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderDto(
      id: json['id'] as String,
      internalNumber: (json['internalNumber'] as num?)?.toInt(),
      vehicleId: json['vehicleId'] as String,
      customerId: json['customerId'] as String,
      branchId: json['branchId'] as String,
      currentBayId: json['currentBayId'] as String?,
      bayName: json['bayName'] as String?,
      mileageIn: (json['mileageIn'] as num?)?.toInt(),
      diagnosticSummary: json['diagnosticSummary'] as String?,
      status: json['status'] as String?,
      subtotal: decimalFromJson(json['subtotal']),
      taxAmount: decimalFromJson(json['taxAmount']),
      totalAmount: decimalFromJson(json['totalAmount']),
      currency: json['currency'] as String?,
      tasks: (json['tasks'] as List?)
          ?.map((e) => WorkOrderTaskDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      proposals: (json['proposals'] as List?)
          ?.map((e) => TaskProposalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      intakeImages: (json['intakeImages'] as List?)
          ?.map((e) => WorkOrderImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// `TaskProposalResource`.
class TaskProposalDto {
  final String id;
  final String workOrderId;
  final String? taskId;
  final String? serviceId;
  final String? mechanicId;
  final String? description;
  final String? severity;
  final String? imageUrl;
  final String? status;
  final String? customerNotes;
  final String? createdAt;

  const TaskProposalDto({
    required this.id,
    required this.workOrderId,
    this.taskId,
    this.serviceId,
    this.mechanicId,
    this.description,
    this.severity,
    this.imageUrl,
    this.status,
    this.customerNotes,
    this.createdAt,
  });

  factory TaskProposalDto.fromJson(Map<String, dynamic> json) {
    return TaskProposalDto(
      id: json['id'] as String,
      workOrderId: json['workOrderId'] as String,
      taskId: json['taskId'] as String?,
      serviceId: json['serviceId'] as String?,
      mechanicId: json['mechanicId'] as String?,
      description: json['description'] as String?,
      severity: json['severity'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String?,
      customerNotes: json['customerNotes'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

/// `WorkOrderImageResource`.
class WorkOrderImageDto {
  final String id;
  final String imageUrl;
  final String? description;
  final String? uploadedAt;

  const WorkOrderImageDto({
    required this.id,
    required this.imageUrl,
    this.description,
    this.uploadedAt,
  });

  factory WorkOrderImageDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderImageDto(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
    );
  }
}

/// Respuesta de `notify` y `quotation/send`: [recipient] es el correo del cliente.
class EmailSentDto {
  final String? message;
  final String? recipient;

  const EmailSentDto({this.message, this.recipient});

  factory EmailSentDto.fromJson(Map<String, dynamic> json) {
    return EmailSentDto(
      message: json['message'] as String?,
      recipient: json['recipient'] as String?,
    );
  }
}
