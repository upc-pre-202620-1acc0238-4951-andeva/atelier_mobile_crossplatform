import 'package:atelier_mobile_crossplatform/features/inventory/domain/batch_allocation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:decimal/decimal.dart';

/// Descargo contable FIFO directo de stock (`inventory:batches:dispatch_fifo`).
class DispatchFifoBatchUseCase {
  final InventoryRepository repository;

  const DispatchFifoBatchUseCase({required this.repository});

  Future<StockAllocation> execute(
    String itemId, {
    required Decimal quantity,
    String? workOrderId,
    String? taskId,
  }) async {
    if (!InventoryValidation.isNonEmptyText(itemId)) {
      throw const InvalidInventoryInputException('itemId');
    }
    if (!InventoryValidation.isPositiveQty(quantity)) {
      throw const InvalidInventoryInputException('quantity');
    }
    return repository.dispatchFifoBatch(
      itemId,
      quantity: quantity,
      workOrderId: workOrderId,
      taskId: taskId,
    );
  }
}
