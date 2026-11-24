import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Cancelar una cita registrando el motivo (`POST /appointments/{id}/cancel`,
/// `crm:appointments:update`). En línea.
class CancelAppointmentUseCase {
  final ReceptionRepository repository;

  const CancelAppointmentUseCase({required this.repository});

  Future<Appointment> execute(
    String appointmentId,
    String cancellationReason,
  ) {
    if (appointmentId.trim().isEmpty) {
      throw const InvalidReceptionInputException('appointmentId');
    }
    if (!ReceptionValidation.isAppointmentCancelReason(cancellationReason)) {
      throw const InvalidReceptionInputException('cancellationReason');
    }
    return repository.cancelAppointment(
      appointmentId,
      cancellationReason.trim(),
    );
  }
}
