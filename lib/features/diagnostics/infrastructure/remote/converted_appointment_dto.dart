/// `AppointmentResponse` de `POST /iot/alerts/{id}/convert-to-appointment` (docs/api/iot.md).
class ConvertedAppointmentDto {
  final String appointmentId;
  final String? vehicleId;
  final String? customerId;
  final String? scheduledAt;
  final String? status;
  final String? notes;

  const ConvertedAppointmentDto({
    required this.appointmentId,
    this.vehicleId,
    this.customerId,
    this.scheduledAt,
    this.status,
    this.notes,
  });

  factory ConvertedAppointmentDto.fromJson(Map<String, dynamic> json) {
    return ConvertedAppointmentDto(
      appointmentId: json['appointmentId'] as String,
      vehicleId: json['vehicleId'] as String?,
      customerId: json['customerId'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
