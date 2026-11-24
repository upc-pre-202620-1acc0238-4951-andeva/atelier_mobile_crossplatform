import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:decimal/decimal.dart';

/// Agrega una línea a una orden de compra en borrador (`inventory:purchase_orders:create`).
class AddPurchaseOrderItemUseCase {
  final InventoryRepository repository;

  const AddPurchaseOrderItemUseCase({required this.repository});

  Future<PurchaseOrder> execute(
    String purchaseOrderId, {
    required String itemId,
    required Decimal quantity,
    required Decimal unitCost,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(purchaseOrderId)
        ? 'purchaseOrderId'
        : !InventoryValidation.isNonEmptyText(itemId)
        ? 'itemId'
        : !InventoryValidation.isPositiveQty(quantity)
        ? 'quantity'
        : !InventoryValidation.isNonNegative(unitCost)
        ? 'unitCost'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.addPurchaseOrderItem(
      purchaseOrderId,
      itemId: itemId,
      quantity: quantity,
      unitCost: unitCost,
    );
  }
}
