import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_profile_dto.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_mapper.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_dto.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_reference_dtos.dart';
import 'package:decimal/decimal.dart';

/// Drift guarda los montos como texto decimal (06 §5); sin moneda se asume PEN.
extension WorkOrderDtoMapper on WorkOrderDto {
  WorkOrderEntity toEntity(int syncedAt) {
    return WorkOrderEntity(
      id: id,
      internalNumber: internalNumber,
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      currentBayId: currentBayId,
      bayName: bayName,
      status: status ?? '',
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      subtotal: subtotal?.toString(),
      taxAmount: taxAmount?.toString(),
      totalAmount: (totalAmount ?? Decimal.zero).toString(),
      currency: currency ?? Money.pen,
      syncedAt: syncedAt,
    );
  }

  /// [header] es la fila ya guardada.
  WorkOrderDetail toDetail(WorkOrder header) {
    return WorkOrderDetail(
      workOrder: header,
      tasks: (tasks ?? []).map((e) => e.toDomain()).toList(),
      proposals: (proposals ?? []).map((e) => e.toDomain()).toList(),
      intakeImages: (intakeImages ?? []).map((e) => e.toDomain()).toList(),
      createdAt: _instant(createdAt),
      updatedAt: _instant(updatedAt),
    );
  }
}

extension WorkOrderEntityMapper on WorkOrderEntity {
  WorkOrder toDomain({String? plate, String? customerName}) {
    return WorkOrder(
      id: WorkOrderId(id),
      internalNumber: internalNumber,
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      currentBayId: currentBayId,
      bayName: bayName,
      status: WorkOrderStatus.fromString(status),
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      subtotal: _money(subtotal, currency),
      taxAmount: _money(taxAmount, currency),
      totalAmount: _money(totalAmount, currency),
      plate: plate,
      customerName: customerName,
    );
  }
}

extension WorkOrderWithRefsMapper on WorkOrderWithRefs {
  WorkOrder toDomain() {
    return workOrder.toDomain(plate: plate, customerName: customerName);
  }
}

extension TaskProposalDtoMapper on TaskProposalDto {
  Proposal toDomain() {
    return Proposal(
      id: id,
      workOrderId: workOrderId,
      taskId: taskId,
      serviceId: serviceId,
      mechanicId: mechanicId,
      description: description ?? '',
      severity: ProposalSeverity.fromString(severity),
      imageUrl: imageUrl,
      status: ProposalStatus.fromString(status),
      customerNotes: customerNotes,
      createdAt: _instant(createdAt),
    );
  }
}

extension WorkOrderImageDtoMapper on WorkOrderImageDto {
  IntakeImage toDomain() {
    return IntakeImage(
      id: id,
      imageUrl: imageUrl,
      description: description,
      uploadedAt: _instant(uploadedAt),
    );
  }
}

extension ServiceDtoMapper on ServiceDto {
  ServiceOption toDomain() {
    return ServiceOption(
      id: id,
      name: name ?? '',
      basePrice: Money.orNull(basePrice, currency),
      estimatedMinutes: estimatedMinutes,
    );
  }
}

extension EmployeeProfileDtoMechanicMapper on EmployeeProfileDto {
  /// Sin `membershipId` el colaborador no se puede asignar: se descarta.
  MechanicOption? toMechanicOption() {
    final id = membershipId;
    if (id == null) return null;
    return MechanicOption(
      membershipId: id,
      jobTitle: jobTitle,
      employmentStatus: employmentStatus,
    );
  }
}

extension PartMovementDtoMapper on PartMovementDto {
  PartMovement toDomain() {
    return PartMovement(
      allocationId: allocationId,
      productId: productId,
      taskId: taskId,
      batchId: batchId,
      chargedQuantity: chargedQuantity ?? Decimal.zero,
      returnedQuantity: returnedQuantity ?? Decimal.zero,
      unitCost: Money.orNull(unitCost, currency),
      chargedAt: _instant(chargedAt),
      lastReturnedAt: _instant(lastReturnedAt),
      lastReturnedBy: lastReturnedBy,
      lastReturnReason: lastReturnReason,
    );
  }
}

extension WorkOrderProfitabilityDtoMapper on WorkOrderProfitabilityDto {
  Profitability toDomain() {
    return Profitability(
      workOrderId: workOrderId,
      currency: currency,
      laborRevenue: laborRevenue,
      partsRevenue: partsRevenue,
      partsCostOfSales: partsCostOfSales,
      partsGrossProfit: partsGrossProfit,
      subtotal: subtotal,
      lines: (lines ?? [])
          .map(
            (line) => PartProfitability(
              taskId: line.taskId,
              productId: line.productId,
              quantity: line.quantity ?? Decimal.zero,
              unitPrice: line.unitPrice,
              revenue: line.revenue,
              costOfSales: line.costOfSales,
              grossProfit: line.grossProfit,
            ),
          )
          .toList(),
    );
  }
}

DateTime? _instant(String? raw) => DateTime.tryParse(raw ?? '')?.toUtc();

Money? _money(String? amount, String currency) {
  return Money.orNull(Decimal.tryParse(amount ?? ''), currency);
}
