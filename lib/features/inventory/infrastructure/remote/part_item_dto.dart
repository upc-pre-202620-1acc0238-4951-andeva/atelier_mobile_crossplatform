import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

class PartItemDto {
  final String id;
  final String? tenantId;
  final String? name;
  final String? sku;
  final String? category;
  final Decimal? basePrice;
  final Decimal? totalStock;
  final Decimal? minimumStock;
  final String? unitOfMeasure;
  final String? status;

  const PartItemDto({
    required this.id,
    this.tenantId,
    this.name,
    this.sku,
    this.category,
    this.basePrice,
    this.totalStock,
    this.minimumStock,
    this.unitOfMeasure,
    this.status,
  });

  factory PartItemDto.fromJson(Map<String, dynamic> json) {
    return PartItemDto(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      basePrice: decimalFromJson(json['basePrice']),
      totalStock: decimalFromJson(json['totalStock']),
      minimumStock: decimalFromJson(json['minimumStock']),
      unitOfMeasure: json['unitOfMeasure'] as String?,
      status: json['status'] as String?,
    );
  }
}
