import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:decimal/decimal.dart';

/// Actualiza un repuesto (`inventory:parts:manage`). En línea: sin red lanza `NetworkException`.
class UpdatePartUseCase {
  final InventoryRepository repository;

  const UpdatePartUseCase({required this.repository});

  Future<Part> execute(
    String id, {
    required String name,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    PartStatus? status,
    String? unitOfMeasure,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(id)
        ? 'id'
        : !InventoryValidation.isNonEmptyText(name)
        ? 'name'
        : !InventoryValidation.isNonNegative(basePrice)
        ? 'basePrice'
        : !InventoryValidation.isNonNegative(minimumStock)
        ? 'minimumStock'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.updatePart(
      id,
      name: name,
      category: category,
      basePrice: basePrice,
      minimumStock: minimumStock,
      status: status,
      unitOfMeasure: unitOfMeasure,
    );
  }
}
