import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Valorización en PEN. Exige `inventory:batches:read`.
class GetInventoryValuationUseCase {
  final InventoryRepository repository;

  const GetInventoryValuationUseCase({required this.repository});

  Future<InventoryValuation> execute() => repository.getValuation();
}
