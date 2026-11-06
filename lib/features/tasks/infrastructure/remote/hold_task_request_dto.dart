class HoldTaskRequestDto {
  final String missingItemDescription;
  final String? inventoryItemId;

  const HoldTaskRequestDto({
    required this.missingItemDescription,
    this.inventoryItemId,
  });

  Map<String, dynamic> toJson() => {
        'missingItemDescription': missingItemDescription,
        if (inventoryItemId != null) 'inventoryItemId': inventoryItemId,
      };
}
