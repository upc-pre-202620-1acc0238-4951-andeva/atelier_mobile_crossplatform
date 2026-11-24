import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Elimina una tarea no completada de una orden de trabajo y devuelve el detalle con totales
/// recalculados. En línea.
class RemoveWorkOrderTaskUseCase {
  final WorkOrderRepository repository;

  const RemoveWorkOrderTaskUseCase({required this.repository});

  Future<WorkOrderDetail> execute(WorkOrderId workOrderId, TaskId taskId) {
    return repository.removeTask(workOrderId, taskId);
  }
}
