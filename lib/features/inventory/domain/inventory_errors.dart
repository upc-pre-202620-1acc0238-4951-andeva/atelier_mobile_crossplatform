import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Un dato no cumple `InventoryValidation`; [field] dice cuál (`sku`, `receiptNumber`, `photo`…).
class InvalidInventoryInputException implements Exception {
  final String field;

  const InvalidInventoryInputException(this.field);

  @override
  String toString() => 'InvalidInventoryInputException: $field';
}

/// Solo una orden `ISSUED` se recibe (H15). [status] es `null` si el backend envió un estado desconocido.
class PurchaseOrderNotReceivableException implements Exception {
  final PurchaseOrderStatus? status;

  const PurchaseOrderNotReceivableException(this.status);

  @override
  String toString() => 'PurchaseOrderNotReceivableException: ${status?.value}';
}
