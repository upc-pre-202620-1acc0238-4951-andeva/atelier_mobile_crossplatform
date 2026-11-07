import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Leer es offline-first (06 §4): catálogo y lotes se guardan en `parts` y `batches`. Recibir una
/// compra es en línea y nunca se encola (06 §2).
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

  /// Sin `inventory:batches:read` no hace nada.
  Future<void> refreshBatches(String itemId, {bool force = false});

  /// Del más antiguo al más nuevo. Desde la caché no traen `initialQty`, proveedor ni comprobante.
  Stream<List<PartBatch>> observeBatches(String itemId);

  /// En línea; sin red se deriva de la caché con la misma regla del backend (H13).
  Future<List<StockAlert>> getStockAlerts();

  /// Sale de la caché `parts`, así que cambia solo al recargar el catálogo.
  Stream<List<Part>> observeLowStock();

  Future<InventoryValuation> getValuation();

  Future<List<PurchaseOrder>> getPurchaseOrders({PurchaseOrderStatus? status});

  Future<PurchaseOrder> getPurchaseOrder(String id);

  /// Sube el comprobante, recibe y recarga catálogo y lotes. Si ya estaba recibida devuelve la orden
  /// sin subir nada (H15).
  Future<PurchaseOrder> receivePurchaseOrder(
    String id,
    String receiptNumber,
    File photo, {
    DateTime? receivedAt,
  });
}
