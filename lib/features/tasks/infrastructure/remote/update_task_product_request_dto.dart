import 'package:decimal/decimal.dart';

class UpdateTaskProductRequestDto {
  final Decimal quantity;

  const UpdateTaskProductRequestDto({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity.toDouble()};
}
