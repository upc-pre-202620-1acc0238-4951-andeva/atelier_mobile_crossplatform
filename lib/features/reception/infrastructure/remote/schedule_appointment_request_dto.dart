/// `ScheduleAppointmentResource` de docs/api/crm.md. `scheduledAt` en UTC.
class ScheduleAppointmentRequestDto {
  final String branchId;
  final String customerId;
  final String vehicleId;
  final String scheduledAt;
  final int? estimatedDurationMinutes;
  final String? reason;

  const ScheduleAppointmentRequestDto({
    required this.branchId,
    required this.customerId,
    required this.vehicleId,
    required this.scheduledAt,
    this.estimatedDurationMinutes,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'customerId': customerId,
    'vehicleId': vehicleId,
    'scheduledAt': scheduledAt,
    if (estimatedDurationMinutes != null)
      'estimatedDurationMinutes': estimatedDurationMinutes,
    if (reason != null) 'reason': reason,
  };
}
