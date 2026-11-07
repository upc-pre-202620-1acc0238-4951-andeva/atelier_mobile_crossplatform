import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';

/// `AppointmentStatus` de docs/api/README.md §8.
enum AppointmentStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  arrived('ARRIVED'),
  canceled('CANCELED');

  final String value;
  const AppointmentStatus(this.value);

  static AppointmentStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// Cita de la agenda de la sede (`AppointmentResource`). El backend solo manda ids: [plate] y
/// [customerName] salen de las cachés `vehicles` y `customers`, y son `null` hasta cargarlas.
class Appointment {
  final String id;
  final String branchId;
  final String customerId;
  final String vehicleId;
  final DateTime scheduledAt;
  final int? estimatedDurationMinutes;
  final String? reason;
  final AppointmentStatus? status;
  final String? plate;
  final String? customerName;

  const Appointment({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.vehicleId,
    required this.scheduledAt,
    this.estimatedDurationMinutes,
    this.reason,
    this.status,
    this.plate,
    this.customerName,
  });
}

/// Llegada de una cita (US11 E1, H10). El backend crea la orden después, de forma asíncrona:
/// [WorkOrderReady] si ya apareció, [WorkOrderPending] si aún no.
sealed class ArrivalResult {
  final Appointment appointment;

  const ArrivalResult(this.appointment);
}

final class WorkOrderReady extends ArrivalResult {
  final WorkOrderId workOrderId;

  const WorkOrderReady(super.appointment, this.workOrderId);
}

final class WorkOrderPending extends ArrivalResult {
  const WorkOrderPending(super.appointment);
}
