import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Lookup del lector de código o del SKU escrito (US31 E1). `null` si no existe.
class FindPartBySkuUseCase {
  final InventoryRepository repository;

  const FindPartBySkuUseCase({required this.repository});

  Future<Part?> execute(String sku) async {
    if (!InventoryValidation.isSku(sku)) {
      throw const InvalidInventoryInputException('sku');
    }
    return repository.findBySku(sku);
  }
}
