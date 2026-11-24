import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:decimal/decimal.dart';

/// Alta de repuesto en el catálogo (`inventory:parts:manage`). En línea: sin red lanza
/// `NetworkException`.
class CreatePartUseCase {
  final InventoryRepository repository;

  const CreatePartUseCase({required this.repository});

  Future<Part> execute({
    required String name,
    required String sku,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    String? unitOfMeasure = 'UNIT',
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(name)
        ? 'name'
        : !InventoryValidation.isSku(sku)
        ? 'sku'
        : !InventoryValidation.isNonNegative(basePrice)
        ? 'basePrice'
        : !InventoryValidation.isNonNegative(minimumStock)
        ? 'minimumStock'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.createPart(
      name: name,
      sku: sku,
      category: category,
      basePrice: basePrice,
      minimumStock: minimumStock,
      unitOfMeasure: unitOfMeasure,
    );
  }
}
