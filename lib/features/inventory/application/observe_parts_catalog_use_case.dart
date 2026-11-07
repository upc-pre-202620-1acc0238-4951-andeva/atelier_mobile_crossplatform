import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

class ObservePartsCatalogUseCase {
  final InventoryRepository repository;

  const ObservePartsCatalogUseCase({required this.repository});

  Stream<List<Part>> execute({ItemCategory? category}) {
    return repository.observeCatalog(category: category);
  }
}
