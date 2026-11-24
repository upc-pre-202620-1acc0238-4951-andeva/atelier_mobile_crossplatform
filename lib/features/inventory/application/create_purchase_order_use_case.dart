import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Crea una orden de compra en borrador (`inventory:purchase_orders:create`) en la sede de la sesión.
class CreatePurchaseOrderUseCase {
  final InventoryRepository repository;

  const CreatePurchaseOrderUseCase({required this.repository});

  Future<PurchaseOrder> execute(
    String supplierId, {
    List<PurchaseOrderLineInput> items = const [],
    String? orderNumber,
    String? expectedDeliveryDate,
    String? notes,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(supplierId)
        ? 'supplierId'
        : items.any((line) => !InventoryValidation.isNonEmptyText(line.itemId))
        ? 'itemId'
        : items.any((line) => !InventoryValidation.isPositiveQty(line.quantity))
        ? 'quantity'
        : items.any((line) => !InventoryValidation.isNonNegative(line.unitCost))
        ? 'unitCost'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.createPurchaseOrder(
      supplierId,
      items: items,
      orderNumber: orderNumber,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
    );
  }
}
