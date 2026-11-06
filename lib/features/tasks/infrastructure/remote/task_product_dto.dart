import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

class TaskProductDto {
  final String id;
  final String? taskId;
  final String productId;
  final String? productName;
  final Decimal? quantity;
  final Decimal? unitPrice;
  final Decimal? totalAmount;
  final String? currency;

  const TaskProductDto({
    required this.id,
    this.taskId,
    required this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.totalAmount,
    this.currency,
  });

  factory TaskProductDto.fromJson(Map<String, dynamic> json) {
    return TaskProductDto(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      quantity: decimalFromJson(json['quantity']),
      unitPrice: decimalFromJson(json['unitPrice']),
      totalAmount: decimalFromJson(json['totalAmount']),
      currency: json['currency'] as String?,
    );
  }
}
