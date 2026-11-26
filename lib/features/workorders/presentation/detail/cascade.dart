import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:decimal/decimal.dart';

final _igvRate = Decimal.parse('0.18');
final _hundred = Decimal.fromInt(100);
final _half = Decimal.parse('0.5');

/// Escala 2 con redondeo al par más cercano (`RoundingMode.HALF_EVEN` de Android).
Decimal scaleTwoHalfEven(Decimal value) {
  final scaled = value * _hundred;
  final floor = scaled.floor();
  final diff = scaled - floor;
  final Decimal rounded;
  if (diff > _half) {
    rounded = floor + Decimal.one;
  } else if (diff < _half) {
    rounded = floor;
  } else {
    rounded = (floor % Decimal.fromInt(2)) == Decimal.zero ? floor : floor + Decimal.one;
  }
  return (rounded / _hundred).toDecimal(scaleOnInfinitePrecision: 2);
}

/// Liquidación en cascada libre de errores de redondeo (escala 2, `HALF_EVEN`). Solo la lee la UI para el
/// importe de la fila "Proforma sin respuesta"; el resumen de liquidación (subtotal, IGV, total) es la
/// historia US36 y no se muestra.
class CascadeBreakdown {
  final String currency;
  final Money laborSubtotal;
  final Money partsSubtotal;
  final Money subtotal;
  final Money taxAmount;
  final Money totalAmount;

  const CascadeBreakdown({
    required this.currency,
    required this.laborSubtotal,
    required this.partsSubtotal,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
  });
}

/// Importe total de la línea de repuesto: usa `totalAmount` o calcula `cantidad × unitario` con escala 2.
Money resolvedTotal(TaskProduct product, [String? currency]) {
  final total = product.totalAmount;
  if (total != null) return total;
  final unit = product.unitPrice?.amount ?? Decimal.zero;
  final code = product.unitPrice?.currency ?? currency ?? Money.pen;
  return Money(amount: scaleTwoHalfEven(unit * product.quantity), currency: code);
}

/// Suma de todos los repuestos imputados a la tarea (sin IGV).
Money partsSubtotalOf(TaskDetail task, [String? currency]) {
  final code = currency ?? task.price?.currency ?? Money.pen;
  var sum = Decimal.zero;
  for (final item in task.products) {
    sum += resolvedTotal(item, code).amount;
  }
  return Money(amount: scaleTwoHalfEven(sum), currency: code);
}

/// Precio de la tarea = mano de obra + Σ(precio del repuesto × cantidad), con precisión decimal.
Money cascadeTotalOf(TaskDetail task, [String? currency]) {
  final code = currency ?? task.price?.currency ?? Money.pen;
  final labor = task.price?.amount ?? Decimal.zero;
  final parts = partsSubtotalOf(task, code).amount;
  return Money(amount: scaleTwoHalfEven(labor + parts), currency: code);
}

extension WorkOrderDetailCascade on WorkOrderDetail {
  /// Subtotal de mano de obra y de repuestos, subtotal imponible, IGV (18 %) y total de la orden.
  CascadeBreakdown cascadeBreakdown() {
    String? firstTaskCurrency;
    for (final task in tasks) {
      final code = task.price?.currency;
      if (code != null) {
        firstTaskCurrency = code;
        break;
      }
    }
    final currency =
        workOrder.totalAmount?.currency ??
        workOrder.subtotal?.currency ??
        firstTaskCurrency ??
        Money.pen;

    var laborSum = Decimal.zero;
    var partsSum = Decimal.zero;
    for (final task in tasks) {
      laborSum += task.price?.amount ?? Decimal.zero;
      partsSum += partsSubtotalOf(task, currency).amount;
    }
    laborSum = scaleTwoHalfEven(laborSum);
    partsSum = scaleTwoHalfEven(partsSum);
    final computedSubtotal = scaleTwoHalfEven(laborSum + partsSum);
    final hasTaskAmounts = tasks.any((t) => t.price != null || t.products.isNotEmpty);

    final Decimal subtotalAmount = hasTaskAmounts
        ? computedSubtotal
        : scaleTwoHalfEven(workOrder.subtotal?.amount ?? computedSubtotal);
    final Decimal taxAmount = hasTaskAmounts
        ? scaleTwoHalfEven(subtotalAmount * _igvRate)
        : scaleTwoHalfEven(workOrder.taxAmount?.amount ?? subtotalAmount * _igvRate);
    final Decimal totalAmount = hasTaskAmounts
        ? scaleTwoHalfEven(subtotalAmount + taxAmount)
        : scaleTwoHalfEven(workOrder.totalAmount?.amount ?? subtotalAmount + taxAmount);

    return CascadeBreakdown(
      currency: currency,
      laborSubtotal: Money(amount: laborSum, currency: currency),
      partsSubtotal: Money(amount: partsSum, currency: currency),
      subtotal: Money(amount: subtotalAmount, currency: currency),
      taxAmount: Money(amount: taxAmount, currency: currency),
      totalAmount: Money(amount: totalAmount, currency: currency),
    );
  }
}

/// La orden con los campos que cambian al fusionar la caché o la respuesta de una acción (`WorkOrder.copy`
/// de Android).
extension WorkOrderCopy on WorkOrder {
  WorkOrder copyWith({
    String? currentBayId,
    String? bayName,
    WorkOrderStatus? status,
    String? diagnosticSummary,
    int? mileageIn,
    String? plate,
    String? customerName,
  }) {
    return WorkOrder(
      id: id,
      internalNumber: internalNumber,
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      currentBayId: currentBayId ?? this.currentBayId,
      bayName: bayName ?? this.bayName,
      status: status ?? this.status,
      diagnosticSummary: diagnosticSummary ?? this.diagnosticSummary,
      mileageIn: mileageIn ?? this.mileageIn,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      plate: plate ?? this.plate,
      customerName: customerName ?? this.customerName,
    );
  }
}

extension WorkOrderDetailCopy on WorkOrderDetail {
  WorkOrderDetail copyWith({WorkOrder? workOrder, List<TaskDetail>? tasks}) {
    return WorkOrderDetail(
      workOrder: workOrder ?? this.workOrder,
      tasks: tasks ?? this.tasks,
      proposals: proposals,
      intakeImages: intakeImages,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
