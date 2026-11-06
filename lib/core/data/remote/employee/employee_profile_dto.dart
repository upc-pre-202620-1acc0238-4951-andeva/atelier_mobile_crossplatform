/// `EmployeeProfileResource` de docs/api/hr.md; por ahora solo se usan la sede y el turno.
class EmployeeProfileDto {
  final String id;
  final String? branchId;
  final String? assignedShiftId;

  const EmployeeProfileDto({
    required this.id,
    required this.branchId,
    required this.assignedShiftId,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String?,
      assignedShiftId: json['assignedShiftId'] as String?,
    );
  }
}
