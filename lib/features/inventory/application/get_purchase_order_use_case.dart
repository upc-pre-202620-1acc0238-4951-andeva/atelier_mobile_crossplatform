import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

class GetPurchaseOrderUseCase {
  final InventoryRepository repository;

  const GetPurchaseOrderUseCase({required this.repository});

  Future<PurchaseOrder> execute(String id) => repository.getPurchaseOrder(id);
}
