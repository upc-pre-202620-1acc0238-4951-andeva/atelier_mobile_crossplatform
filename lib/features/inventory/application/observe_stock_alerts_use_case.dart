import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Alertas desde la caché: se vacían solas al recibir la compra (US34 E2).
class ObserveStockAlertsUseCase {
  final InventoryRepository repository;

  const ObserveStockAlertsUseCase({required this.repository});

  Stream<List<StockAlert>> execute() {
    return repository.observeLowStock().map(
      (parts) => parts.map((part) => part.toStockAlert()).toList(),
    );
  }
}
