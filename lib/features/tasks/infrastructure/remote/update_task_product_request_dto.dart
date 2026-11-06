class UpdateTaskProductRequestDto {
  final double quantity;

  const UpdateTaskProductRequestDto({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity};
}
