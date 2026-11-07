import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// Descargo de un repuesto desde un lote y lo que volvió a él (`PartMovementResource`, US33 E2).
class PartMovement {
  final String allocationId;
  final String productId;
  final String? taskId;
  final String? batchId;
  final Decimal chargedQuantity;
  final Decimal returnedQuantity;
  final Money? unitCost;
  final DateTime? chargedAt;
  final DateTime? lastReturnedAt;
  final String? lastReturnedBy;
  final String? lastReturnReason;

  const PartMovement({
    required this.allocationId,
    required this.productId,
    this.taskId,
    this.batchId,
    required this.chargedQuantity,
    required this.returnedQuantity,
    this.unitCost,
    this.chargedAt,
    this.lastReturnedAt,
    this.lastReturnedBy,
    this.lastReturnReason,
  });
}

/// Rentabilidad con costo de ventas FIFO (`WorkOrderProfitabilityResource`, US35 E2). Sin IGV. La
/// ganancia puede ser negativa: por eso `Decimal` y no `Money`, que exige ≥ 0.
class Profitability {
  final String workOrderId;
  final String? currency;
  final Decimal? laborRevenue;
  final Decimal? partsRevenue;
  final Decimal? partsCostOfSales;
  final Decimal? partsGrossProfit;
  final Decimal? subtotal;
  final List<PartProfitability> lines;

  const Profitability({
    required this.workOrderId,
    this.currency,
    this.laborRevenue,
    this.partsRevenue,
    this.partsCostOfSales,
    this.partsGrossProfit,
    this.subtotal,
    required this.lines,
  });
}

class PartProfitability {
  final String? taskId;
  final String productId;
  final Decimal quantity;
  final Decimal? unitPrice;
  final Decimal? revenue;
  final Decimal? costOfSales;
  final Decimal? grossProfit;

  const PartProfitability({
    this.taskId,
    required this.productId,
    required this.quantity,
    this.unitPrice,
    this.revenue,
    this.costOfSales,
    this.grossProfit,
  });
}
