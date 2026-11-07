import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// `PurchaseOrderStatus` de docs/api/README.md §8. Solo `ISSUED` se puede recibir.
enum PurchaseOrderStatus {
  draft('DRAFT'),
  issued('ISSUED'),
  received('RECEIVED'),
  canceled('CANCELED');

  final String value;
  const PurchaseOrderStatus(this.value);

  static PurchaseOrderStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// Orden de compra a proveedor (`PurchaseOrderResource`). Se recibe para reponer stock (US34 E2).
class PurchaseOrder {
  final String id;
  final String? orderNumber;
  final String? supplierId;
  final String? branchId;
  final PurchaseOrderStatus? status;
  final Money? totalCost;
  final String? receiptNumber;
  final String? receiptImageUrl;
  final DateTime? receivedAt;
  final List<PurchaseOrderLine> lines;

  const PurchaseOrder({
    required this.id,
    this.orderNumber,
    this.supplierId,
    this.branchId,
    this.status,
    this.totalCost,
    this.receiptNumber,
    this.receiptImageUrl,
    this.receivedAt,
    required this.lines,
  });

  bool get canBeReceived => status == PurchaseOrderStatus.issued;
}

/// Línea de la orden: al recibir, cada una crea un lote con su cantidad y costo.
class PurchaseOrderLine {
  final String id;
  final String itemId;
  final Decimal quantity;
  final Money? unitCost;
  final Money? totalCost;

  const PurchaseOrderLine({
    required this.id,
    required this.itemId,
    required this.quantity,
    this.unitCost,
    this.totalCost,
  });
}

/// Valorización del inventario: saldo de los lotes por su costo, en PEN.
class InventoryValuation {
  final Money total;

  const InventoryValuation({required this.total});
}
