import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_suspension.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US29: solicitudes de suspensión en espera. No hay endpoint que las liste (H5), así que consulta el detalle
/// de cada orden activa, una por una. En línea. Una orden que falla se omite: el resultado puede ser parcial.
class FindPendingSuspensionsUseCase {
  final WorkOrderRepository repository;

  const FindPendingSuspensionsUseCase({required this.repository});

  Future<List<PendingSuspension>> execute(List<WorkOrder> orders) async {
    final found = <PendingSuspension>[];
    for (final order in orders) {
      if (order.status != WorkOrderStatus.draft && order.status != WorkOrderStatus.inProgress) continue;
      try {
        final detail = await repository.getDetail(order.id);
        for (final TaskDetail task in detail.tasksAwaitingSuspensionReview) {
          found.add(PendingSuspension(order: order, task: task));
        }
      } on Exception {
        // Se sigue con las demás órdenes.
      }
    }
    return found;
  }
}
