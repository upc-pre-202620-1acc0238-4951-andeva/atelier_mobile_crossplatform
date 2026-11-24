import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Agendar una cita en la sede de la sesión (`POST /appointments`, `crm:appointments:create`). En línea.
class CreateAppointmentUseCase {
  final ReceptionRepository repository;

  const CreateAppointmentUseCase({required this.repository});

  Future<Appointment> execute({
    required String customerId,
    required String vehicleId,
    required DateTime scheduledAt,
    int? estimatedDurationMinutes,
    String? reason,
  }) {
    if (customerId.trim().isEmpty) {
      throw const InvalidReceptionInputException('customerId');
    }
    if (vehicleId.trim().isEmpty) {
      throw const InvalidReceptionInputException('vehicleId');
    }
    if (!ReceptionValidation.isOptionalDurationMinutes(
      estimatedDurationMinutes,
    )) {
      throw const InvalidReceptionInputException('estimatedDurationMinutes');
    }
    if (!ReceptionValidation.isOptionalAppointmentReason(reason)) {
      throw const InvalidReceptionInputException('reason');
    }
    return repository.createAppointment(
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledAt: scheduledAt,
      estimatedDurationMinutes: estimatedDurationMinutes,
      reason: reason,
    );
  }
}
