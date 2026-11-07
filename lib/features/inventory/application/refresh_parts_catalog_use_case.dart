import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';

/// Carga el catálogo completo en la caché (US31). Si una página falla, se conserva la caché anterior.
class RefreshPartsCatalogUseCase {
  final InventoryRepository repository;

  const RefreshPartsCatalogUseCase({required this.repository});

  Future<void> execute({bool force = false}) {
    return repository.refreshCatalog(force: force);
  }
}
