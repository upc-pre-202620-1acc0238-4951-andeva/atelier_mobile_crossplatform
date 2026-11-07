import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_product_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_image_dto.dart';
import 'package:decimal/decimal.dart';

/// Lo usan `tasks` y el detalle de la orden, que trae las mismas tareas (H5).
extension WorkOrderTaskDtoMapper on WorkOrderTaskDto {
  TaskDetail toDomain() {
    return TaskDetail(
      id: TaskId(id),
      workOrderId: workOrderId,
      serviceId: serviceId,
      serviceName: serviceName,
      mechanicId: mechanicId,
      mechanicName: mechanicName,
      status: TaskStatus.fromString(status),
      description: description ?? '',
      price: Money.orNull(price, currency),
      currency: currency,
      holdReason: HoldReason.fromString(holdReason),
      missingItemDescription: missingItemDescription,
      totalPausedSeconds: totalPausedSeconds ?? 0,
      startedAt: DateTime.tryParse(startedAt ?? '')?.toUtc(),
      completedAt: DateTime.tryParse(completedAt ?? '')?.toUtc(),
      pendingSuspensionReason: pendingSuspensionReason,
      pendingSuspensionRequestedAt: DateTime.tryParse(
        pendingSuspensionRequestedAt ?? '',
      )?.toUtc(),
      products: (products ?? []).map((e) => e.toDomain()).toList(),
      evidenceImages: (evidenceImages ?? []).map((e) => e.toDomain()).toList(),
    );
  }
}

extension TaskProductDtoMapper on TaskProductDto {
  TaskProduct toDomain() {
    return TaskProduct(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity ?? Decimal.zero,
      unitPrice: Money.orNull(unitPrice, currency),
      totalAmount: Money.orNull(totalAmount, currency),
    );
  }
}

extension WorkOrderTaskImageDtoMapper on WorkOrderTaskImageDto {
  TaskEvidence toDomain() {
    return TaskEvidence(
      id: id,
      imageUrl: imageUrl,
      description: description,
      uploadedAt: DateTime.tryParse(uploadedAt ?? '')?.toUtc(),
    );
  }
}
