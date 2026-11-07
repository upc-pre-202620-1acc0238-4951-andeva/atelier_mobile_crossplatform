import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
import 'package:decimal/decimal.dart';

/// `PartDetailResource`: los campos de `PartResource` más sus lotes.
class PartDetailDto {
  final PartItemDto part;
  final List<BatchDto>? batches;

  const PartDetailDto({required this.part, this.batches});

  factory PartDetailDto.fromJson(Map<String, dynamic> json) {
    return PartDetailDto(
      part: PartItemDto.fromJson(json),
      batches: (json['batches'] as List?)
          ?.map((e) => BatchDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BatchDto {
  final String id;
  final String? itemId;
  final String? supplierId;
  final String? purchaseOrderId;
  final String? batchNumber;
  final Decimal? initialQty;
  final Decimal? remainingQty;
  final Decimal? unitCost;
  final String? arrivalDate;
  final String? receiptImageUrl;

  const BatchDto({
    required this.id,
    this.itemId,
    this.supplierId,
    this.purchaseOrderId,
    this.batchNumber,
    this.initialQty,
    this.remainingQty,
    this.unitCost,
    this.arrivalDate,
    this.receiptImageUrl,
  });

  factory BatchDto.fromJson(Map<String, dynamic> json) {
    return BatchDto(
      id: json['id'] as String,
      itemId: json['itemId'] as String?,
      supplierId: json['supplierId'] as String?,
      purchaseOrderId: json['purchaseOrderId'] as String?,
      batchNumber: json['batchNumber'] as String?,
      initialQty: decimalFromJson(json['initialQty']),
      remainingQty: decimalFromJson(json['remainingQty']),
      unitCost: decimalFromJson(json['unitCost']),
      arrivalDate: json['arrivalDate'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
    );
  }
}

class StockAlertDto {
  final String itemId;
  final String? name;
  final String? sku;
  final String? category;
  final Decimal? currentStock;
  final Decimal? minimumStock;
  final Decimal? deficit;

  const StockAlertDto({
    required this.itemId,
    this.name,
    this.sku,
    this.category,
    this.currentStock,
    this.minimumStock,
    this.deficit,
  });

  factory StockAlertDto.fromJson(Map<String, dynamic> json) {
    return StockAlertDto(
      itemId: json['itemId'] as String,
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      currentStock: decimalFromJson(json['currentStock']),
      minimumStock: decimalFromJson(json['minimumStock']),
      deficit: decimalFromJson(json['deficit']),
    );
  }
}

class PurchaseOrderDto {
  final String id;
  final String? supplierId;
  final String? branchId;
  final String? orderNumber;
  final String? status;
  final Decimal? totalCost;
  final String? receiptImageUrl;
  final String? receiptNumber;
  final String? receivedAt;
  final List<PurchaseOrderItemDto>? items;

  const PurchaseOrderDto({
    required this.id,
    this.supplierId,
    this.branchId,
    this.orderNumber,
    this.status,
    this.totalCost,
    this.receiptImageUrl,
    this.receiptNumber,
    this.receivedAt,
    this.items,
  });

  factory PurchaseOrderDto.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDto(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String?,
      branchId: json['branchId'] as String?,
      orderNumber: json['orderNumber'] as String?,
      status: json['status'] as String?,
      totalCost: decimalFromJson(json['totalCost']),
      receiptImageUrl: json['receiptImageUrl'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      receivedAt: json['receivedAt'] as String?,
      items: (json['items'] as List?)
          ?.map((e) => PurchaseOrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PurchaseOrderItemDto {
  final String id;
  final String itemId;
  final Decimal? quantity;
  final Decimal? unitCost;
  final Decimal? totalCost;

  const PurchaseOrderItemDto({
    required this.id,
    required this.itemId,
    this.quantity,
    this.unitCost,
    this.totalCost,
  });

  factory PurchaseOrderItemDto.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemDto(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      quantity: decimalFromJson(json['quantity']),
      unitCost: decimalFromJson(json['unitCost']),
      totalCost: decimalFromJson(json['totalCost']),
    );
  }
}

class ReceivePurchaseOrderRequestDto {
  final String receiptImageUrl;
  final String receiptNumber;
  final DateTime? receivedAt;

  const ReceivePurchaseOrderRequestDto({
    required this.receiptImageUrl,
    required this.receiptNumber,
    this.receivedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiptImageUrl': receiptImageUrl,
      'receiptNumber': receiptNumber,
      if (receivedAt != null) 'receivedAt': receivedAt!.toUtc().toIso8601String(),
    };
  }
}
