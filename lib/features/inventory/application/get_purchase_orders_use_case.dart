import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Por defecto, las emitidas: las que se pueden recibir (US34 E2). `null` lista todas.
class GetPurchaseOrdersUseCase {
  final InventoryRepository repository;

  const GetPurchaseOrdersUseCase({required this.repository});

  Future<List<PurchaseOrder>> execute({
    PurchaseOrderStatus? status = PurchaseOrderStatus.issued,
  }) {
    return repository.getPurchaseOrders(status: status);
  }
}
