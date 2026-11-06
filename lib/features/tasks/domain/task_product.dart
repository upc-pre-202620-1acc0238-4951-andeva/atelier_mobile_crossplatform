import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

class TaskProduct {
  final String id;
  final String productId;
  final String? productName;
  final Decimal quantity;
  final Money? unitPrice;
  final Money? totalAmount;

  const TaskProduct({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    this.unitPrice,
    this.totalAmount,
  });
}
