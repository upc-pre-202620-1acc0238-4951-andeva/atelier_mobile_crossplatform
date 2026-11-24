import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Emite una orden de compra en borrador al proveedor (`inventory:purchase_orders:create`).
class IssuePurchaseOrderUseCase {
  final InventoryRepository repository;

  const IssuePurchaseOrderUseCase({required this.repository});

  Future<PurchaseOrder> execute(String id) async {
    if (!InventoryValidation.isNonEmptyText(id)) {
      throw const InvalidInventoryInputException('id');
    }
    return repository.issuePurchaseOrder(id);
  }
}
