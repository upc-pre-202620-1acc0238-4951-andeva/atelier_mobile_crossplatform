import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/inventory/domain/batch_allocation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:decimal/decimal.dart';

/// Leer es offline-first (06 §4): catálogo y lotes se guardan en `parts` y `batches`. Las
/// mutaciones (repuestos, lotes, proveedores y compras) son en línea y nunca se encolan (06 §2):
/// sin red lanzan `NetworkException`.
abstract class InventoryRepository {
  /// Catálogo completo, página por página. Respeta la vigencia de 1 h salvo [force]. Sin
  /// `inventory:parts:read` no hace nada.
  Future<void> refreshCatalog({bool force = false});

  Stream<List<Part>> observeCatalog({ItemCategory? category});

  /// En línea; sin red busca en la caché.
  Future<List<Part>> searchParts(String query, {ItemCategory? category});

  /// `null` si no existe. Sin red busca en la caché.
  Future<Part?> findBySku(String sku);

  Stream<Part?> observePart(String id);

  /// Sin `inventory:batches:read` va sin lotes. Sin red sale de la caché, si está.
  Future<PartDetail> getPartDetail(String id);

  /// Crea un repuesto (`inventory:parts:manage`) y lo guarda en la caché.
  Future<Part> createPart({
    required String name,
    required String sku,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    String? unitOfMeasure = 'UNIT',
  });

  /// Actualiza un repuesto (`inventory:parts:manage`) y la caché.
  Future<Part> updatePart(
    String id, {
    required String name,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    PartStatus? status,
    String? unitOfMeasure,
  });

  /// Sin `inventory:batches:read` no hace nada.
  Future<void> refreshBatches(String itemId, {bool force = false});

  /// Del más antiguo al más nuevo. Desde la caché no traen `initialQty`, proveedor ni comprobante.
  Stream<List<PartBatch>> observeBatches(String itemId);

  /// Ingreso físico directo de un lote (`inventory:batches:receive`). Recarga el repuesto y sus
  /// lotes, sin que un fallo de esa recarga vuelva un error el ingreso.
  Future<PartBatch> receiveDirectBatch(
    String itemId, {
    required String batchNumber,
    required Decimal quantity,
    required Decimal unitCost,
    DateTime? arrivalDate,
    String? supplierId,
  });

  /// Descargo FIFO estricto (`inventory:batches:dispatch_fifo`).
  Future<StockAllocation> dispatchFifoBatch(
    String itemId, {
    required Decimal quantity,
    String? workOrderId,
    String? taskId,
  });

  /// Reintegro de stock no usado a su lote de origen (`inventory:batches:restore`).
  Future<BatchRestoreResult> restoreBatch(
    String itemId, {
    required Decimal quantity,
    String? batchId,
    String? reason,
    String? workOrderId,
  });

  /// En línea; sin red se deriva de la caché con la misma regla del backend (H13).
  Future<List<StockAlert>> getStockAlerts();

  /// Sale de la caché `parts`, así que cambia solo al recargar el catálogo.
  Stream<List<Part>> observeLowStock();

  Future<InventoryValuation> getValuation();

  /// Proveedores (`inventory:suppliers:manage`).
  Future<List<Supplier>> getSuppliers({String? search, String? status});

  Future<Supplier> createSupplier({
    required String businessName,
    required String taxId,
    String? contactName,
    String? phone,
    String? email,
    String? address,
  });

  Future<Supplier> updateSupplier(
    String id, {
    String? businessName,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    bool? active,
  });

  Future<List<PurchaseOrder>> getPurchaseOrders({PurchaseOrderStatus? status});

  Future<PurchaseOrder> getPurchaseOrder(String id);

  /// Crea una orden en borrador (`inventory:purchase_orders:create`) en la sede de la sesión. Sin
  /// sede lanza `MissingBranchException` sin llamar. `expectedDeliveryDate` es `yyyy-MM-dd`.
  Future<PurchaseOrder> createPurchaseOrder(
    String supplierId, {
    List<PurchaseOrderLineInput> items = const [],
    String? orderNumber,
    String? expectedDeliveryDate,
    String? notes,
  });

  /// Agrega una línea a una orden en borrador (`inventory:purchase_orders:create`).
  Future<PurchaseOrder> addPurchaseOrderItem(
    String purchaseOrderId, {
    required String itemId,
    required Decimal quantity,
    required Decimal unitCost,
  });

  /// Emite un borrador al proveedor (`DRAFT` a `ISSUED`).
  Future<PurchaseOrder> issuePurchaseOrder(String id);

  /// Anula una orden pendiente (`CANCELED`).
  Future<PurchaseOrder> cancelPurchaseOrder(String id, {String? reason});

  /// Sube el comprobante, recibe y recarga catálogo y lotes. Si ya estaba recibida devuelve la orden
  /// sin subir nada (H15).
  Future<PurchaseOrder> receivePurchaseOrder(
    String id,
    String receiptNumber,
    File photo, {
    DateTime? receivedAt,
  });
}
