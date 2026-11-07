import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';

class RefreshPartBatchesUseCase {
  final InventoryRepository repository;

  const RefreshPartBatchesUseCase({required this.repository});

  Future<void> execute(String itemId, {bool force = false}) {
    return repository.refreshBatches(itemId, force: force);
  }
}
