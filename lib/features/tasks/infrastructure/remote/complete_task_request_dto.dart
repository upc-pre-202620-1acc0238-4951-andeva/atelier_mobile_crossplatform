import 'package:decimal/decimal.dart';

class CompleteTaskRequestDto {
  final Decimal actualLaborHours;
  final String? notes;

  const CompleteTaskRequestDto({
    required this.actualLaborHours,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'actualLaborHours': actualLaborHours.toDouble(),
        if (notes != null) 'notes': notes,
      };
}
