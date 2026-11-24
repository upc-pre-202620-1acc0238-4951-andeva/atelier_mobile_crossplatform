import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Cancela una orden de compra pendiente antes de su recepción (`inventory:purchase_orders:create`).
class CancelPurchaseOrderUseCase {
  final InventoryRepository repository;

  const CancelPurchaseOrderUseCase({required this.repository});

  Future<PurchaseOrder> execute(String id, {String? reason}) async {
    if (!InventoryValidation.isNonEmptyText(id)) {
      throw const InvalidInventoryInputException('id');
    }
    return repository.cancelPurchaseOrder(id, reason: reason);
  }
}
