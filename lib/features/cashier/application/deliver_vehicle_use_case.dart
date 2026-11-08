import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US39 E2 (`operations:vehicle_handover:execute`). Libera la bahía; sin firma del cliente (H29).
class DeliverVehicleUseCase {
  final WorkOrderRepository repository;

  const DeliverVehicleUseCase({required this.repository});

  Future<WorkOrder> execute(WorkOrderId id) => repository.deliver(id);
}
