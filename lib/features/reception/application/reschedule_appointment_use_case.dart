import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Reprogramar una cita (`POST /appointments/{id}/reschedule`, `crm:appointments:update`). En línea.
class RescheduleAppointmentUseCase {
  final ReceptionRepository repository;

  const RescheduleAppointmentUseCase({required this.repository});

  Future<Appointment> execute(String appointmentId, DateTime newScheduledAt) {
    if (appointmentId.trim().isEmpty) {
      throw const InvalidReceptionInputException('appointmentId');
    }
    return repository.rescheduleAppointment(appointmentId, newScheduledAt);
  }
}
