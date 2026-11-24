import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';

/// Convierte una alerta predictiva en una cita preventiva de CRM con la fecha, duración y motivo acordados
/// con el cliente (`crm:appointments:create`, en línea).
class ConvertAlertToAppointmentUseCase {
  final DiagnosticsRepository repository;

  const ConvertAlertToAppointmentUseCase({required this.repository});

  Future<ConvertedAppointment> execute(
    String alertId, {
    DateTime? scheduledAt,
    int? estimatedDurationMinutes,
    String? reason,
  }) {
    return repository.convertAlertToAppointment(
      alertId,
      scheduledAt: scheduledAt,
      estimatedDurationMinutes: estimatedDurationMinutes,
      reason: reason,
    );
  }
}
