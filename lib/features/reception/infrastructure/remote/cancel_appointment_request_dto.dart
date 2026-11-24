/// `CancelAppointmentResource` de docs/api/crm.md.
class CancelAppointmentRequestDto {
  final String cancellationReason;

  const CancelAppointmentRequestDto({required this.cancellationReason});

  Map<String, dynamic> toJson() => {'cancellationReason': cancellationReason};
}
