import 'package:decimal/decimal.dart';

class PartOption {
  final String id;
  final String name;
  final String? sku;
  final String? category;
  final Decimal? basePrice;
  final Decimal totalStock;
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

  bool get isAvailable => totalStock > Decimal.zero;
}
