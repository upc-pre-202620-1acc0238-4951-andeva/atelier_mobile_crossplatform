import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
import 'package:decimal/decimal.dart';

/// Drift guarda montos y cantidades como texto decimal (06 §5); lo que falta queda en "".
extension PartItemDtoMapper on PartItemDto {
  PartEntity toEntity(int syncedAt) {
    return PartEntity(
      id: id,
      name: name ?? '',
      sku: sku ?? '',
      category: category ?? '',
      basePrice: basePrice?.toString() ?? '',
      totalStock: (totalStock ?? Decimal.zero).toString(),
      minimumStock: (minimumStock ?? Decimal.zero).toString(),
      unitOfMeasure: unitOfMeasure ?? '',
      status: status ?? '',
      syncedAt: syncedAt,
    );
  }
}

extension PartEntityMapper on PartEntity {
  /// Los precios del catálogo están en PEN (docs/api/README.md §6).
  Part toDomain() {
    return Part(
      id: id,
      name: name,
      sku: sku,
      category: ItemCategory.fromString(category),
      basePrice: _money(Decimal.tryParse(basePrice)),
      totalStock: Decimal.tryParse(totalStock) ?? Decimal.zero,
      minimumStock: Decimal.tryParse(minimumStock) ?? Decimal.zero,
      unitOfMeasure: unitOfMeasure.isEmpty ? null : unitOfMeasure,
      status: PartStatus.fromString(status),
    );
  }
}

extension BatchDtoMapper on BatchDto {
  /// Sin `itemId` en la respuesta se usa el repuesto consultado, para que caiga en su alcance
  /// `batches:{itemId}`. Sin fecha queda en 0, que vuelve como `null`.
  BatchEntity toEntity(String fallbackItemId, int syncedAt) {
    return BatchEntity(
      id: id,
      itemId: itemId ?? fallbackItemId,
      batchNumber: batchNumber ?? '',
      remainingQty: (remainingQty ?? Decimal.zero).toString(),
      unitCost: (unitCost ?? Decimal.zero).toString(),
      arrivalDate: _instant(arrivalDate)?.millisecondsSinceEpoch ?? 0,
      syncedAt: syncedAt,
    );
  }

  /// En línea llegan también los campos que la caché no guarda.
  PartBatch toDomain(String fallbackItemId) {
    return PartBatch(
      id: id,
      itemId: itemId ?? fallbackItemId,
      batchNumber: batchNumber ?? '',
      remainingQty: remainingQty ?? Decimal.zero,
      unitCost: _money(unitCost),
      arrivalDate: _instant(arrivalDate),
      initialQty: initialQty,
      supplierId: supplierId,
      purchaseOrderId: purchaseOrderId,
      receiptImageUrl: receiptImageUrl,
    );
  }
}

extension BatchEntityMapper on BatchEntity {
  PartBatch toDomain() {
    return PartBatch(
      id: id,
      itemId: itemId,
      batchNumber: batchNumber,
      remainingQty: Decimal.tryParse(remainingQty) ?? Decimal.zero,
      unitCost: _money(Decimal.tryParse(unitCost)),
      arrivalDate: arrivalDate > 0
          ? DateTime.fromMillisecondsSinceEpoch(arrivalDate, isUtc: true)
          : null,
    );
  }
}

extension StockAlertDtoMapper on StockAlertDto {
  StockAlert toDomain() {
    return StockAlert(
      itemId: itemId,
      name: name ?? '',
      sku: sku ?? '',
      category: ItemCategory.fromString(category),
      currentStock: currentStock ?? Decimal.zero,
      minimumStock: minimumStock ?? Decimal.zero,
      deficit: deficit ?? Decimal.zero,
    );
  }
}

extension PurchaseOrderDtoMapper on PurchaseOrderDto {
  PurchaseOrder toDomain() {
    return PurchaseOrder(
      id: id,
      orderNumber: orderNumber,
      supplierId: supplierId,
      branchId: branchId,
      status: PurchaseOrderStatus.fromString(status),
      totalCost: _money(totalCost),
      receiptNumber: receiptNumber,
      receiptImageUrl: receiptImageUrl,
      receivedAt: _instant(receivedAt),
      lines: (items ?? [])
          .map(
            (item) => PurchaseOrderLine(
              id: item.id,
              itemId: item.itemId,
              quantity: item.quantity ?? Decimal.zero,
              unitCost: _money(item.unitCost),
              totalCost: _money(item.totalCost),
            ),
          )
          .toList(),
    );
  }
}

DateTime? _instant(String? raw) => DateTime.tryParse(raw ?? '')?.toUtc();

/// El inventario se valoriza en PEN; `null` si falta el monto o es negativo.
Money? _money(Decimal? amount) => Money.orNull(amount, Money.pen);
