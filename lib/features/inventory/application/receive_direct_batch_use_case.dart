import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:decimal/decimal.dart';

/// Ingreso físico directo de un lote (`inventory:batches:receive`). En línea: sin red lanza
/// `NetworkException` y no se encola.
class ReceiveDirectBatchUseCase {
  final InventoryRepository repository;
  final DateTime Function() now;

  const ReceiveDirectBatchUseCase({
    required this.repository,
    this.now = DateTime.now,
  });

  Future<PartBatch> execute(
    String itemId, {
    required String batchNumber,
    required Decimal quantity,
    required Decimal unitCost,
    DateTime? arrivalDate,
    String? supplierId,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(itemId)
        ? 'itemId'
        : !InventoryValidation.isNonEmptyText(batchNumber)
        ? 'batchNumber'
        : !InventoryValidation.isPositiveQty(quantity)
        ? 'quantity'
        : !InventoryValidation.isNonNegative(unitCost)
        ? 'unitCost'
        : !InventoryValidation.isReceivedAt(arrivalDate, now())
        ? 'arrivalDate'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.receiveDirectBatch(
      itemId,
      batchNumber: batchNumber,
      quantity: quantity,
      unitCost: unitCost,
      arrivalDate: arrivalDate,
      supplierId: supplierId,
    );
  }
}
