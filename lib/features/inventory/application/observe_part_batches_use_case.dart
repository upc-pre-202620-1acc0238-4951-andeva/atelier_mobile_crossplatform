import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Lotes del más antiguo al más nuevo (US32).
class ObservePartBatchesUseCase {
  final InventoryRepository repository;

  const ObservePartBatchesUseCase({required this.repository});

  Stream<List<PartBatch>> execute(String itemId) {
    return repository.observeBatches(itemId);
  }
}
