import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

/// `ServiceResource`.
class ServiceDto {
  final String id;
  final String? name;
  final Decimal? basePrice;
  final String? currency;
  final int? estimatedMinutes;

  const ServiceDto({
    required this.id,
    this.name,
    this.basePrice,
    this.currency,
    this.estimatedMinutes,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      basePrice: decimalFromJson(json['basePrice']),
      currency: json['currency'] as String?,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
    );
  }
}

/// `PartMovementResource`.
class PartMovementDto {
  final String allocationId;
  final String productId;
  final String? taskId;
  final String? batchId;
  final Decimal? chargedQuantity;
  final Decimal? returnedQuantity;
  final Decimal? unitCost;
  final String? currency;
  final String? chargedAt;
  final String? lastReturnedAt;
  final String? lastReturnedBy;
  final String? lastReturnReason;

  const PartMovementDto({
    required this.allocationId,
    required this.productId,
    this.taskId,
    this.batchId,
    this.chargedQuantity,
    this.returnedQuantity,
    this.unitCost,
    this.currency,
    this.chargedAt,
    this.lastReturnedAt,
    this.lastReturnedBy,
    this.lastReturnReason,
  });

  factory PartMovementDto.fromJson(Map<String, dynamic> json) {
    return PartMovementDto(
      allocationId: json['allocationId'] as String,
      productId: json['productId'] as String,
      taskId: json['taskId'] as String?,
      batchId: json['batchId'] as String?,
      chargedQuantity: decimalFromJson(json['chargedQuantity']),
      returnedQuantity: decimalFromJson(json['returnedQuantity']),
      unitCost: decimalFromJson(json['unitCost']),
      currency: json['currency'] as String?,
      chargedAt: json['chargedAt'] as String?,
      lastReturnedAt: json['lastReturnedAt'] as String?,
      lastReturnedBy: json['lastReturnedBy'] as String?,
      lastReturnReason: json['lastReturnReason'] as String?,
    );
  }
}

/// `WorkOrderProfitabilityResource`: un objeto, no un array.
class WorkOrderProfitabilityDto {
  final String workOrderId;
  final Decimal? laborRevenue;
  final Decimal? partsRevenue;
  final Decimal? partsCostOfSales;
  final Decimal? partsGrossProfit;
  final Decimal? subtotal;
  final String? currency;
  final List<PartProfitabilityDto>? lines;

  const WorkOrderProfitabilityDto({
    required this.workOrderId,
    this.laborRevenue,
    this.partsRevenue,
    this.partsCostOfSales,
    this.partsGrossProfit,
    this.subtotal,
    this.currency,
    this.lines,
  });

  factory WorkOrderProfitabilityDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderProfitabilityDto(
      workOrderId: json['workOrderId'] as String,
      laborRevenue: decimalFromJson(json['laborRevenue']),
      partsRevenue: decimalFromJson(json['partsRevenue']),
      partsCostOfSales: decimalFromJson(json['partsCostOfSales']),
      partsGrossProfit: decimalFromJson(json['partsGrossProfit']),
      subtotal: decimalFromJson(json['subtotal']),
      currency: json['currency'] as String?,
      lines: (json['lines'] as List?)
          ?.map((e) => PartProfitabilityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// `PartProfitabilityResource`.
class PartProfitabilityDto {
  final String? taskId;
  final String productId;
  final Decimal? quantity;
  final Decimal? unitPrice;
  final Decimal? revenue;
  final Decimal? costOfSales;
  final Decimal? grossProfit;

  const PartProfitabilityDto({
    this.taskId,
    required this.productId,
    this.quantity,
    this.unitPrice,
    this.revenue,
    this.costOfSales,
    this.grossProfit,
  });

  factory PartProfitabilityDto.fromJson(Map<String, dynamic> json) {
    return PartProfitabilityDto(
      taskId: json['taskId'] as String?,
      productId: json['productId'] as String,
      quantity: decimalFromJson(json['quantity']),
      unitPrice: decimalFromJson(json['unitPrice']),
      revenue: decimalFromJson(json['revenue']),
      costOfSales: decimalFromJson(json['costOfSales']),
      grossProfit: decimalFromJson(json['grossProfit']),
    );
  }
}
