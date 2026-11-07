import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Búsqueda por nombre o SKU (US31 E1). Sin red busca en la caché.
class SearchPartsCatalogUseCase {
  final InventoryRepository repository;

  const SearchPartsCatalogUseCase({required this.repository});

  Future<List<Part>> execute(String query, {ItemCategory? category}) {
    return repository.searchParts(query.trim(), category: category);
  }
}
