import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Confirmar una cita pendiente (`POST /appointments/{id}/confirm`, `crm:appointments:update`). En línea.
class ConfirmAppointmentUseCase {
  final ReceptionRepository repository;

  const ConfirmAppointmentUseCase({required this.repository});

  Future<Appointment> execute(String appointmentId) {
    if (appointmentId.trim().isEmpty) {
      throw const InvalidReceptionInputException('appointmentId');
    }
    return repository.confirmAppointment(appointmentId);
  }
}
