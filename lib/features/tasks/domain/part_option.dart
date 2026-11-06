class PartOption {
  final String id;
  final String name;
  final String? sku;
  final String? category;
  final double? basePrice;
  final double totalStock;
  final String? unitOfMeasure;

  const PartOption({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.basePrice,
    required this.totalStock,
    this.unitOfMeasure,
  });

  bool get isAvailable => totalStock > 0;
}
