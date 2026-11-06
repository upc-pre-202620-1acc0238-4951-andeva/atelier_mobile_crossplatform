class AddTaskProductRequestDto {
  final String productId;
  final double quantity;

  const AddTaskProductRequestDto({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
