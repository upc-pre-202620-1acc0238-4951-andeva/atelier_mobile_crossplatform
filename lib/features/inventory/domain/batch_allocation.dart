import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// Resultado de un descargo FIFO (`StockAllocationResource` de docs/api/inventory.md).
class StockAllocation {
  final String allocationId;
  final Decimal allocatedQuantity;
  final Money? totalCogs;
  final List<BatchDeduction> deductions;

  const StockAllocation({
    required this.allocationId,
    required this.allocatedQuantity,
    this.totalCogs,
    required this.deductions,
  });
}

/// Deducción sobre un lote dentro de un descargo FIFO (`BatchDeductionResource`).
class BatchDeduction {
  final String batchId;
  final Decimal quantityDeducted;
  final Money? unitCost;
  final Money? subtotal;

  const BatchDeduction({
    required this.batchId,
    required this.quantityDeducted,
    this.unitCost,
    this.subtotal,
  });
}

/// Respuesta de `POST /api/v1/inventory/batches/restore`.
class BatchRestoreResult {
  final String? status;
  final String? message;
  final String? batchId;
  final Decimal restoredQuantity;

  const BatchRestoreResult({
    this.status,
    this.message,
    this.batchId,
    required this.restoredQuantity,
  });
}
