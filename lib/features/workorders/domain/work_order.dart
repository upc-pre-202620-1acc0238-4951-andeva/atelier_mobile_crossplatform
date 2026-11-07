import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';

/// `WorkOrderStatus` de docs/api/README.md §8.
enum WorkOrderStatus {
  draft('DRAFT'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  paid('PAID'),
  canceled('CANCELED');

  final String value;
  const WorkOrderStatus(this.value);

  /// `PAID` y `CANCELED` ya no se trabajan: no se guardan en la caché de la sede (06 §4).
  bool get isClosed => this == paid || this == canceled;

  static WorkOrderStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// Cabecera de la orden (caché `work_orders`). Montos sin IGV en tareas y repuestos; el backend
/// calcula [subtotal], [taxAmount] (IGV 18 %) y [totalAmount] (US36). La lista de la sede no trae
/// [subtotal], [taxAmount], [mileageIn] ni [diagnosticSummary]: llegan con el detalle. [plate] y
/// [customerName] salen de las cachés de recepción.
class WorkOrder {
  final WorkOrderId id;
  final int? internalNumber;
  final String branchId;
  final String vehicleId;
  final String customerId;
  final String? currentBayId;
  final String? bayName;
  final WorkOrderStatus? status;
  final String? diagnosticSummary;
  final int? mileageIn;
  final Money? subtotal;
  final Money? taxAmount;
  final Money? totalAmount;
  final String? plate;
  final String? customerName;

  const WorkOrder({
    required this.id,
    this.internalNumber,
    required this.branchId,
    required this.vehicleId,
    required this.customerId,
    this.currentBayId,
    this.bayName,
    this.status,
    this.diagnosticSummary,
    this.mileageIn,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.plate,
    this.customerName,
  });
}

/// Detalle en línea (`GET /work-orders/{id}`). Las tareas son [TaskDetail] de `tasks`: sus acciones
/// (suspensión, repuestos) se hacen con esos casos de uso (H5). `serviceName`, `mechanicName` y
/// `productName` no traen el valor real (H11 de docs/03-traceability.md).
class WorkOrderDetail {
  final WorkOrder workOrder;
  final List<TaskDetail> tasks;
  final List<Proposal> proposals;
  final List<IntakeImage> intakeImages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkOrderDetail({
    required this.workOrder,
    required this.tasks,
    required this.proposals,
    required this.intakeImages,
    this.createdAt,
    this.updatedAt,
  });

  /// Tareas con una solicitud de suspensión esperando al supervisor (H5).
  List<TaskDetail> get tasksAwaitingSuspensionReview {
    return tasks
        .where((task) => task.pendingSuspensionRequestedAt != null)
        .toList();
  }
}

/// Foto de recepción ya registrada (`WorkOrderImageResource`, US13 E2).
class IntakeImage {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime? uploadedAt;

  const IntakeImage({
    required this.id,
    required this.imageUrl,
    this.description,
    this.uploadedAt,
  });
}

/// Apertura de orden (US12 E1): `CreateWorkOrderResource`; la sede es la de la sesión.
class NewWorkOrder {
  final String vehicleId;
  final String customerId;
  final int mileageIn;
  final String? diagnosticSummary;
  final String? appointmentId;

  const NewWorkOrder({
    required this.vehicleId,
    required this.customerId,
    required this.mileageIn,
    this.diagnosticSummary,
    this.appointmentId,
  });
}
