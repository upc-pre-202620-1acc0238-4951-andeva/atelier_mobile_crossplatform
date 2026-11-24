import 'package:atelier_mobile_crossplatform/features/inventory/domain/batch_allocation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:decimal/decimal.dart';

/// Reintegro de stock no usado al lote de origen (`inventory:batches:restore`).
class RestoreBatchUseCase {
  final InventoryRepository repository;

  const RestoreBatchUseCase({required this.repository});

  Future<BatchRestoreResult> execute(
    String itemId, {
    required Decimal quantity,
    String? batchId,
    String? reason,
    String? workOrderId,
  }) async {
    if (!InventoryValidation.isNonEmptyText(itemId)) {
      throw const InvalidInventoryInputException('itemId');
    }
    if (!InventoryValidation.isPositiveQty(quantity)) {
      throw const InvalidInventoryInputException('quantity');
    }
    return repository.restoreBatch(
      itemId,
      quantity: quantity,
      batchId: batchId,
      reason: reason,
      workOrderId: workOrderId,
    );
  }
}
