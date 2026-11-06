class CompleteTaskRequestDto {
  final double actualLaborHours;
  final String? notes;

  const CompleteTaskRequestDto({
    required this.actualLaborHours,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'actualLaborHours': actualLaborHours,
        if (notes != null) 'notes': notes,
      };
}
