/// `EmployeeProfileResource` de docs/api/hr.md, con lo que usan las features.
class EmployeeProfileDto {
  final String id;
  final String? branchId;
  final String? assignedShiftId;
  final String? membershipId;
  final String? jobTitle;
  final String? employmentStatus;

  const EmployeeProfileDto({
    required this.id,
    required this.branchId,
    required this.assignedShiftId,
    this.membershipId,
    this.jobTitle,
    this.employmentStatus,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String?,
      assignedShiftId: json['assignedShiftId'] as String?,
      membershipId: json['membershipId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
    );
  }
}
