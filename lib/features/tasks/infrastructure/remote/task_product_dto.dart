class TaskProductDto {
  final String id;
  final String? taskId;
  final String productId;
  final String? productName;
  final double? quantity;
  final double? unitPrice;
  final double? totalAmount;
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
      productName: (json['productName'] ?? json['name']) as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}
