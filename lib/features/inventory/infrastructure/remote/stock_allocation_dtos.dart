import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

/// `BatchDeductionResource` de docs/api/inventory.md.
class BatchDeductionDto {
  final String batchId;
  final Decimal? quantityDeducted;
  final Decimal? unitCost;
  final Decimal? subtotal;

  const BatchDeductionDto({
    required this.batchId,
    this.quantityDeducted,
    this.unitCost,
    this.subtotal,
  });

  factory BatchDeductionDto.fromJson(Map<String, dynamic> json) {
    return BatchDeductionDto(
      batchId: json['batchId'] as String,
      quantityDeducted: decimalFromJson(json['quantityDeducted']),
      unitCost: decimalFromJson(json['unitCost']),
      subtotal: decimalFromJson(json['subtotal']),
    );
  }
}

/// `StockAllocationResource` de docs/api/inventory.md.
class StockAllocationDto {
  final String allocationId;
  final Decimal? allocatedQuantity;
  final Decimal? totalCogs;
  final List<BatchDeductionDto>? deductions;

  const StockAllocationDto({
    required this.allocationId,
    this.allocatedQuantity,
    this.totalCogs,
    this.deductions,
  });

  factory StockAllocationDto.fromJson(Map<String, dynamic> json) {
    return StockAllocationDto(
      allocationId: json['allocationId'] as String,
      allocatedQuantity: decimalFromJson(json['allocatedQuantity']),
      totalCogs: decimalFromJson(json['totalCogs']),
      deductions: (json['deductions'] as List?)
          ?.map((e) => BatchDeductionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Respuesta 200 de `POST /api/v1/inventory/batches/restore`.
class RestoreBatchResponseDto {
  final String? status;
  final String? message;
  final String? batchId;
  final Decimal? restoredQuantity;

  const RestoreBatchResponseDto({
    this.status,
    this.message,
    this.batchId,
    this.restoredQuantity,
  });

  factory RestoreBatchResponseDto.fromJson(Map<String, dynamic> json) {
    return RestoreBatchResponseDto(
      status: json['status'] as String?,
      message: json['message'] as String?,
      batchId: json['batchId'] as String?,
      restoredQuantity: decimalFromJson(json['restoredQuantity']),
    );
  }
}
