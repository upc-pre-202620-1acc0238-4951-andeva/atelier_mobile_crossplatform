import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_product_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_image_dto.dart';
import 'package:decimal/decimal.dart';

class WorkOrderTaskDto {
  final String id;
  final String workOrderId;
  final String? serviceId;
  final String? serviceName;
  final String? mechanicId;
  final String? mechanicName;
  final String? status;
  final String? description;
  final Decimal? price;
  final String? currency;
  final String? holdReason;
  final String? missingItemDescription;
  final int? totalPausedSeconds;
  final String? startedAt;
  final String? completedAt;
  final String? pendingSuspensionReason;
  final String? pendingSuspensionRequestedAt;
  final List<TaskProductDto>? products;
  final List<WorkOrderTaskImageDto>? evidenceImages;

  const WorkOrderTaskDto({
    required this.id,
    required this.workOrderId,
    this.serviceId,
    this.serviceName,
    this.mechanicId,
    this.mechanicName,
    this.status,
    this.description,
    this.price,
    this.currency,
    this.holdReason,
    this.missingItemDescription,
    this.totalPausedSeconds,
    this.startedAt,
    this.completedAt,
    this.pendingSuspensionReason,
    this.pendingSuspensionRequestedAt,
    this.products,
    this.evidenceImages,
  });

  factory WorkOrderTaskDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderTaskDto(
      id: json['id'] as String,
      workOrderId: json['workOrderId'] as String,
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String?,
      mechanicId: json['mechanicId'] as String?,
      mechanicName: json['mechanicName'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      price: decimalFromJson(json['price']),
      currency: json['currency'] as String?,
      holdReason: json['holdReason'] as String?,
      missingItemDescription: json['missingItemDescription'] as String?,
      totalPausedSeconds: (json['totalPausedSeconds'] as num?)?.toInt(),
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      pendingSuspensionReason: json['pendingSuspensionReason'] as String?,
      pendingSuspensionRequestedAt:
          json['pendingSuspensionRequestedAt'] as String?,
      products: (json['products'] as List?)
          ?.map((e) => TaskProductDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      evidenceImages: (json['evidenceImages'] as List?)
          ?.map((e) => WorkOrderTaskImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
