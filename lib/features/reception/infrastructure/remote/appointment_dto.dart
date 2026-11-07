/// `AppointmentResource` de docs/api/crm.md. `scheduledAt` en UTC.
class AppointmentDto {
  final String id;
  final String branchId;
  final String customerId;
  final String vehicleId;
  final String scheduledAt;
  final int? estimatedDurationMinutes;
  final String? reason;
  final String? status;

  const AppointmentDto({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.vehicleId,
    required this.scheduledAt,
    this.estimatedDurationMinutes,
    this.reason,
    this.status,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    return AppointmentDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String,
      scheduledAt: json['scheduledAt'] as String,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)
          ?.toInt(),
      reason: json['reason'] as String?,
      status: json['status'] as String?,
    );
  }
}
