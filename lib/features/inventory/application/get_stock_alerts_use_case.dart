import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Bandeja de alertas (US34 E1). Sin red se deriva de la caché (H13).
class GetStockAlertsUseCase {
  final InventoryRepository repository;

  const GetStockAlertsUseCase({required this.repository});

  Future<List<StockAlert>> execute() => repository.getStockAlerts();
}
