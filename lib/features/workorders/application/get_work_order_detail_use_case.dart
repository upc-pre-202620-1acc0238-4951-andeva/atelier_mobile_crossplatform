import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Detalle con tareas, propuestas y fotos de recepción (US13 E2, US36). Las tareas se accionan con
/// los casos de uso de `tasks` (H5). En línea.
class GetWorkOrderDetailUseCase {
  final WorkOrderRepository repository;

  const GetWorkOrderDetailUseCase({required this.repository});

  Future<WorkOrderDetail> execute(WorkOrderId id) {
    return repository.getDetail(id);
  }
}
