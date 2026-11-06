import 'package:decimal/decimal.dart';

/// Sin `unitPrice` ni `currency`: el backend copia el `basePrice` del catálogo (US35 E1).
class AddTaskProductRequestDto {
  final String productId;
  final Decimal quantity;

  const AddTaskProductRequestDto({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity.toDouble(),
      };
}
