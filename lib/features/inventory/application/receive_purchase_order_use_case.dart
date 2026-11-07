import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Recibir una orden emitida con el número y la foto del comprobante (US34 E2): crea un lote por
/// línea, sube el stock y la alerta sale de la bandeja. En línea: sin red lanza `NetworkException` y
/// no se encola.
class ReceivePurchaseOrderUseCase {
  final InventoryRepository repository;
  final DateTime Function() now;

  const ReceivePurchaseOrderUseCase({
    required this.repository,
    this.now = DateTime.now,
  });

  Future<PurchaseOrder> execute(
    String id, {
    required String receiptNumber,
    required File? photo,
    DateTime? receivedAt,
  }) async {
    if (photo == null) throw const InvalidInventoryInputException('photo');
    if (!InventoryValidation.isReceiptNumber(receiptNumber)) {
      throw const InvalidInventoryInputException('receiptNumber');
    }
    if (!InventoryValidation.isReceivedAt(receivedAt, now())) {
      throw const InvalidInventoryInputException('receivedAt');
    }
    return repository.receivePurchaseOrder(
      id,
      receiptNumber.trim(),
      photo,
      receivedAt: receivedAt,
    );
  }
}
