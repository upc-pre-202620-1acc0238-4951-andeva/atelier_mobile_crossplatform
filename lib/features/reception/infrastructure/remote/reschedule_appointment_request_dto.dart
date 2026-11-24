/// `RescheduleAppointmentResource` de docs/api/crm.md. `newScheduledAt` en UTC.
class RescheduleAppointmentRequestDto {
  final String newScheduledAt;

  const RescheduleAppointmentRequestDto({required this.newScheduledAt});

  Map<String, dynamic> toJson() => {'newScheduledAt': newScheduledAt};
}
