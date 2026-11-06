class PartItemDto {
  final String id;
  final String? tenantId;
  final String name;
  final String? sku;
  final String? category;
  final double? basePrice;
  final double? totalStock;
  final double? minimumStock;
  final String? unitOfMeasure;
  final String? status;

  const PartItemDto({
    required this.id,
    this.tenantId,
    required this.name,
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
      name: json['name'] as String,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      totalStock: (json['totalStock'] as num?)?.toDouble(),
      minimumStock: (json['minimumStock'] as num?)?.toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String?,
      status: json['status'] as String?,
    );
  }
}
