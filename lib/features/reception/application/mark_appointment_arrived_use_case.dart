import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Registrar la llegada de una cita (US11 E1, US12 E1). El backend devuelve la cita y crea la orden
/// en borrador después, con kilometraje 0 (H10): se busca hasta [attempts] veces. Con
/// [WorkOrderReady], completarla con `UpdateWorkOrderUseCase`; con [WorkOrderPending], volver a
/// buscar con `FindDraftWorkOrderForVehicleUseCase`. En línea.
class MarkAppointmentArrivedUseCase {
  static const attempts = 3;
  static const retryDelay = Duration(seconds: 1);

  final ReceptionRepository receptionRepository;
  final WorkOrderRepository workOrderRepository;
  final Future<void> Function(Duration) delay;

  const MarkAppointmentArrivedUseCase({
    required this.receptionRepository,
    required this.workOrderRepository,
    this.delay = Future.delayed,
  });

  Future<ArrivalResult> execute(String appointmentId) async {
    final appointment = await receptionRepository.markArrived(appointmentId);
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (attempt > 0) await delay(retryDelay);
      try {
        final draft = await workOrderRepository.findDraftForVehicle(
          appointment.branchId,
          appointment.vehicleId,
        );
        if (draft != null) return WorkOrderReady(appointment, draft.id);
      } on ApiException {
        // La llegada ya quedó registrada: no se informa como fallida.
      } on NetworkException {
        // Igual.
      }
    }
    return WorkOrderPending(appointment);
  }
}
