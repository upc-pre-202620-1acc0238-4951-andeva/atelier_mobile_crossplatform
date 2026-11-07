import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

/// Cambiar descripción, mecánico o precio de una tarea (US22 E2). Devuelve el detalle con los totales
/// recalculados. En línea.
class UpdateWorkOrderTaskUseCase {
  final WorkOrderRepository repository;

  const UpdateWorkOrderTaskUseCase({required this.repository});

  Future<WorkOrderDetail> execute(
    WorkOrderId id,
    TaskId taskId,
    WorkOrderTaskChanges changes,
  ) async {
    if (!WorkOrderValidation.isOptionalText(
      changes.description,
      WorkOrderValidation.taskDescriptionMax,
    )) {
      throw const InvalidWorkOrderInputException('description');
    }
    if (!WorkOrderValidation.isOptionalAmount(changes.price)) {
      throw const InvalidWorkOrderInputException('price');
    }
    return repository.updateTask(id, taskId, changes);
  }
}
